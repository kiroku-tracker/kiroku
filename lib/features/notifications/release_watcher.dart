import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../data/database/franchise_rules.dart';
import '../../data/database/settings_repository.dart';
import '../../data/providers.dart';
import '../../data/shikimori/shikimori_client.dart';
import '../../data/watch/dubbing_rules.dart';
import '../../system/notifications.dart';
import 'alert_rules.dart';
import 'release_events.dart';

/// Проверка новых серий и сезонов.
class ReleaseWatcher {
  ReleaseWatcher(this._ref);

  final Ref _ref;
  Timer? _timer;
  Future<List<ReleaseEvent>>? _running;

  static const interval = Duration(hours: 1);

  static const _summaryFrom = 5;

  void start() {
    _timer ??= Timer.periodic(interval, (_) => check());
    check();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<List<ReleaseEvent>> check() =>
      _running ??= _check().whenComplete(() => _running = null);

  Future<List<ReleaseEvent>> _check() async {
    final library = _ref.read(libraryRepositoryProvider);
    final franchises = _ref.read(franchiseRepositoryProvider);
    final shikimori = _ref.read(shikimoriClientProvider);
    final prefs = await _ref.read(appPrefsProvider.future);
    final events = <ReleaseEvent>[];

    try {
      final ids = await library.idsToRefresh();
      final fresh = <String>{};
      if (ids.isNotEmpty) {
        final tracked = await library.trackedIds(
          byDefault: prefs.notifyEpisodes,
        );
        final before = await library.animesByIds(ids);
        for (final info in await shikimori.getAnimes(ids)) {
          final old = before[info.id];
          if (old != null && tracked.contains(info.id)) {
            events.addAll(releaseEvents(old, info));
          }
          final key = info.franchise ?? '';
          if (old != null && (old.franchise ?? '').isEmpty && key.isNotEmpty) {
            fresh.add(key);
          }
          await library.saveAnime(info);
        }
      }

      for (final animeId in await franchises.franchisesToLoad()) {
        final parts = await shikimori.getFranchise(animeId);
        if (parts == null) continue;
        events.addAll(
          await saveFranchise(parts, fresh: fresh.contains(parts.key)),
        );
      }
    } catch (_) {}

    final bySite = <int>{};
    events.addAll(await _siteEvents(prefs, bySite));

    final shown = [
      for (final event in events)
        if (switch (event) {
          NewFranchisePart() || SeasonStarted() || EpisodesOnSite() => true,
          _ => !bySite.contains(event.animeId),
        })
          event,
    ];
    await _deliver(shown);
    return shown;
  }

  /// Загружает франшизу со страницы и сообщает о новых сезонах.
  Future<void> loadFranchise(String key) async {
    if (isCustomFranchise(key)) return;
    final franchises = _ref.read(franchiseRepositoryProvider);
    if (!await franchises.needsLoading(key)) return;
    final parts = await franchises.watchParts(key).first;
    if (parts.isEmpty) return;
    final loaded = await _ref
        .read(shikimoriClientProvider)
        .getFranchise(parts.first.id);
    if (loaded != null) await _deliver(await saveFranchise(loaded));
  }

  /// Новые серии на YummyAnime.
  Future<List<ReleaseEvent>> _siteEvents(
    AppPrefs prefs,
    Set<int> bySite,
  ) async {
    final library = _ref.read(libraryRepositoryProvider);
    final site = _ref.read(siteEpisodesRepositoryProvider);
    final tracked = await library.trackedIds(byDefault: prefs.notifyEpisodes);
    final franchises = await _ref
        .read(franchiseRepositoryProvider)
        .watchFranchises()
        .first;
    final events = <ReleaseEvent>[];
    for (final item in await library.watchItems().first) {
      final anime = item.anime;
      if (!tracked.contains(anime.id)) continue;
      final dubbing = effectiveDubbing(
        item.entry,
        franchises[franchiseKeyOf(item.entry, anime)],
      )?.name;
      if (dubbing == null && prefs.episodeAlert == EpisodeAlert.air) continue;
      bySite.add(anime.id);
      final release = anime.release;
      if (release.availableEpisodes == 0) continue;
      final known = await site.read(anime.id);
      final progress = siteProgress(known, dubbing: dubbing);
      final behind =
          known.checked && progress.episodes < release.availableEpisodes;
      if (!release.isOngoing && !behind) continue;
      try {
        final result = await site.refresh(anime.id);
        events.addAll(
          siteEvents(
            animeId: anime.id,
            title: anime.title,
            before: result.before,
            after: result.after,
            dubbing: dubbing,
          ),
        );
      } catch (_) {}
    }
    return events;
  }

  /// Сохраняет части франшизы и возвращает новости о её сезонах.
  Future<List<ReleaseEvent>> saveFranchise(
    FranchiseParts parts, {
    bool fresh = false,
  }) async {
    final repository = _ref.read(franchiseRepositoryProvider);
    final added = await repository.saveParts(parts, fresh: fresh);
    return _seasonEvents(parts.key, {for (final part in added) part.id});
  }

  /// Анонсы и начало показа частей франшизы, которых нет в библиотеке.
  Future<List<ReleaseEvent>> _seasonEvents(String key, Set<int> added) async {
    final repository = _ref.read(franchiseRepositoryProvider);
    final library = _ref.read(libraryRepositoryProvider);
    final settings = _ref.read(settingsRepositoryProvider);
    final prefs = await _ref.read(appPrefsProvider.future);
    final items = await library.watchItems().first;
    final own = [
      for (final item in items)
        if (franchiseKeyOf(item.entry, item.anime) == key) item,
    ];
    if (own.isEmpty) return const [];

    final row = (await repository.watchFranchises().first)[key];
    final on = seasonAlerts(row, prefs);
    final separately = row?.alertsOn ?? false;
    final announce = on && (separately || prefs.notifySeasonAnnounce);
    final start = on && (separately || prefs.notifySeasonStart);

    final order = buildWatchOrder(
      await repository.watchParts(key).first,
      await repository.watchRelations(key).first,
    );
    final name = franchiseName(row, own);
    final owned = {for (final item in items) item.anime.id};
    final saved = await settings.readAll();
    final events = <ReleaseEvent>[];
    for (final part in order.main) {
      final status = part.releaseStatus;
      if (owned.contains(part.id) || status == null) continue;
      final was = saved['season.${part.id}'];
      if (status != was) await settings.write('season.${part.id}', status);
      if (added.contains(part.id)) {
        if ((status == 'anons' && announce) || (status == 'ongoing' && start)) {
          events.add(
            NewFranchisePart(
              animeId: part.id,
              title: part.title,
              franchise: name,
              releaseStatus: status,
              airedOn: part.airedOn,
            ),
          );
        }
      } else if (was == 'anons' && status != 'anons' && start) {
        events.add(
          SeasonStarted(animeId: part.id, title: part.title, franchise: name),
        );
      }
    }
    return events;
  }

  /// Сохраняет уведомления в центр уведомлений и показывает их.
  Future<void> _deliver(List<ReleaseEvent> events) async {
    if (events.isEmpty) return;
    await _ref.read(noticesRepositoryProvider).add([
      for (final event in events)
        (
          category: NoticeCategory.of(event).name,
          animeId: event.animeId,
          title: notificationText(event).title,
          body: notificationText(event).body,
        ),
    ]);
    await _notify(events);
  }

  Future<void> _notify(List<ReleaseEvent> events) async {
    final notifications = _ref.read(notificationServiceProvider);
    if (events.length >= _summaryFrom) {
      final text = summaryText(events);
      await notifications.show(
        title: text.title,
        body: text.body,
        command: NotificationCommand.openLibrary,
      );
      return;
    }
    for (final event in events) {
      final text = notificationText(event);
      await notifications.show(
        title: text.title,
        body: text.body,
        command: NotificationCommand.openTitle(event.animeId),
        buttons: [
          if (event is NewFranchisePart || event is SeasonStarted)
            NotificationButton(
              command: NotificationCommand.planTitle(event.animeId),
              label: 'В «Хочу посмотреть»',
            ),
          if (event is EpisodesOnSite)
            NotificationButton(
              command: NotificationCommand.watchTitle(event.animeId),
              label: 'Смотреть',
            ),
        ],
      );
    }
  }
}

abstract final class NotificationCommand {
  static const openLibrary = 'library';
  static String openTitle(int animeId) => 'title:$animeId';
  static String planTitle(int animeId) => 'plan:$animeId';
  static String watchTitle(int animeId) => 'watch:$animeId';

  /// Номер тайтла из команды.
  static int? animeIdOf(String command, String prefix) =>
      command.startsWith('$prefix:')
      ? int.tryParse(command.substring(prefix.length + 1))
      : null;
}

final releaseWatcherProvider = Provider<ReleaseWatcher>((ref) {
  final watcher = ReleaseWatcher(ref);
  ref.onDispose(watcher.stop);
  return watcher;
});

/// Загрузка частей франшизы для её страницы.
final franchiseLoadProvider = FutureProvider.family<void, String>(
  (ref, key) => ref.read(releaseWatcherProvider).loadFranchise(key),
);
