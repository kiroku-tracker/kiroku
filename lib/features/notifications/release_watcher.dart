import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../data/database/franchise_rules.dart';
import '../../data/database/settings_repository.dart';
import '../../data/providers.dart';
import '../../data/watch/dubbing_rules.dart';
import '../../system/notifications.dart';
import 'release_events.dart';

/// Проверка новых серий.
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
      if (ids.isNotEmpty) {
        final tracked = await library.trackedIds();
        final before = await library.animesByIds(ids);
        for (final info in await shikimori.getAnimes(ids)) {
          final old = before[info.id];
          if (old != null && tracked.contains(info.id)) {
            events.addAll(releaseEvents(old, info));
          }
          await library.saveAnime(info);
        }
      }

      for (final animeId in await franchises.franchisesToLoad()) {
        final parts = await shikimori.getFranchise(animeId);
        if (parts == null) continue;
        final added = await franchises.saveParts(parts);
        if (added.isEmpty) continue;
        events.addAll(
          await _newParts(parts.key, {for (final a in added) a.id}),
        );
      }
    } catch (_) {}

    final bySite = <int>{};
    events.addAll(await _siteEvents(prefs, bySite));

    final shown = [
      for (final event in events)
        if (switch (event) {
          NewFranchisePart() => prefs.notifyFranchises,
          EpisodesOnSite() => prefs.notifyEpisodes,
          _ => prefs.notifyEpisodes && !bySite.contains(event.animeId),
        })
          event,
    ];
    await _notify(shown);
    return shown;
  }

  /// Новые серии на YummyAnime.
  Future<List<ReleaseEvent>> _siteEvents(
    AppPrefs prefs,
    Set<int> bySite,
  ) async {
    final library = _ref.read(libraryRepositoryProvider);
    final site = _ref.read(siteEpisodesRepositoryProvider);
    final tracked = await library.trackedIds();
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

  /// Новые части франшизы.
  Future<List<NewFranchisePart>> _newParts(String key, Set<int> added) async {
    final repository = _ref.read(franchiseRepositoryProvider);
    final library = _ref.read(libraryRepositoryProvider);
    final items = await library.watchItems().first;
    final own = [
      for (final item in items)
        if (franchiseKeyOf(item.entry, item.anime) == key) item,
    ];
    if (own.isEmpty || own.every((item) => item.entry.muted)) return const [];

    final order = buildWatchOrder(
      await repository.watchParts(key).first,
      await repository.watchRelations(key).first,
    );
    final row = (await repository.watchFranchises().first)[key];
    final name = franchiseName(row, own);
    final owned = {for (final item in items) item.anime.id};
    return [
      for (final part in order.main)
        if (added.contains(part.id) &&
            !owned.contains(part.id) &&
            (part.releaseStatus == 'anons' || part.releaseStatus == 'ongoing'))
          NewFranchisePart(
            animeId: part.id,
            title: part.title,
            franchise: name,
            releaseStatus: part.releaseStatus,
            airedOn: part.airedOn,
          ),
    ];
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
          if (event is NewFranchisePart)
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
