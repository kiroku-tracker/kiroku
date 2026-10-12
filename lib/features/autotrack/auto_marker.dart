import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../data/database/franchise_rules.dart';
import '../../data/database/library_repository.dart';
import '../../data/database/settings_repository.dart';
import '../../data/database/status_action.dart';
import '../../data/database/watch_status.dart';
import '../../data/providers.dart';
import '../../data/yummy/yummy_client.dart';
import '../../system/notifications.dart';
import '../library/library_filter.dart';
import 'recognition.dart';

class AutoMarker {
  AutoMarker(this._ref);

  final Ref _ref;
  static const _channel = MethodChannel('kiroku/media');
  static const _interval = Duration(seconds: 5);

  static const _minDuration = 5 * 60.0;

  bool _running = false;

  final _handled = <String>{};

  final _lastRecognized = <String, Recognized>{};

  final _durations = <String, double>{};

  final _slugCache = <String, int?>{};

  final _learned = <String>{};
  final _undos = <String, Future<void> Function()>{};

  final _added = <int>{};
  int _nextToken = 1;

  Future<void> start() async {
    if (_running) return;
    _running = true;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'update' && call.arguments is List) {
        await _onSnapshot(call.arguments as List);
      }
    });
    await _channel.invokeMethod('start', {
      'intervalMs': _interval.inMilliseconds,
      'keywords': yummyKeywords,
    });
  }

  Future<void> stop() async {
    if (!_running) return;
    _running = false;
    await _channel.invokeMethod('stop');
  }

  /// Включает или выключает автоотметку.
  Future<void> apply(AppPrefs prefs) => prefs.autoMark ? start() : stop();

  MediaSession? _embedded;
  DateTime? _embeddedAt;

  /// Просмотр во встроенном плеере Kiroku.
  void reportEmbedded(MediaSession? session) {
    _embedded = session;
    _embeddedAt = DateTime.now();
  }

  Future<void> _onSnapshot(List raw) async {
    final prefs = await _ref.read(appPrefsProvider.future);
    if (!prefs.autoMark) return;
    final sessions = [
      for (final item in raw)
        if (item is Map)
          if (MediaSession.fromMap(item) case final session
              when !session.app.toLowerCase().contains('kiroku'))
            session,
    ];
    final embedded = _embedded;
    final embeddedAt = _embeddedAt;
    if (embedded != null &&
        embeddedAt != null &&
        DateTime.now().difference(embeddedAt) < const Duration(seconds: 8)) {
      sessions.add(embedded);
    }
    var seen = false;
    for (final session in sessions) {
      final now = recognizeYummy(session);
      if (now == null || session.duration < _minDuration) continue;
      final key = '${session.app}|${session.title}';
      if (!sameVideo(session, _durations[key])) continue;
      if (session.documents.isNotEmpty) _durations[key] = session.duration;
      seen = true;
      if (kDebugMode) {
        debugPrint(
          'Автоотметка: «${now.title}» серия ${now.episode} '
          'shikimori ${now.shikimoriId} slug ${now.slug} '
          '${(session.ratio * 100).toStringAsFixed(1)}% '
          '${session.playing ? "играет" : "пауза"} '
          'документов ${session.documents.length}',
        );
      }

      final recognized = now.episode != null
          ? (_lastRecognized[key] = now)
          : (_lastRecognized[key] ?? now);

      final host = now.host == null ? null : YummyHost.ofDomain(now.host!);
      if (prefs.yummyHost == null && host != null) {
        await _ref
            .read(appPrefsProvider.notifier)
            .change((prefs) => prefs.copyWith(yummyHost: host));
      }

      int? animeId;
      try {
        animeId = recognized.shikimoriId ?? await _idBySlug(recognized.slug);
      } catch (_) {}
      if (animeId != null && session.playing) {
        if (prefs.autoAdd) {
          await _addOnStart(animeId, recognized.title);
        }
        unawaited(_learnDubbing(animeId, recognized.player));
      }
      _ref
          .read(nowPlayingProvider.notifier)
          .set(
            NowPlaying(
              animeId: animeId,
              title: recognized.title,
              episode: recognized.episode,
              ratio: session.ratio,
              playing: session.playing,
              position: session.position,
              duration: session.duration,
            ),
          );
      if (session.ratio * 100 < prefs.autoMarkThreshold) continue;
      try {
        await _onWatched(recognized);
      } catch (_) {}
    }
    if (!seen) _ref.read(nowPlayingProvider.notifier).set(null);
  }

  /// Добавляет тайтл в начале просмотра.
  Future<void> _addOnStart(int animeId, String title) async {
    if (!_added.add(animeId)) return;
    try {
      final library = _ref.read(libraryRepositoryProvider);
      if (await library.watchEntry(animeId).first != null) return;
      final info = await _ref.read(shikimoriClientProvider).getAnime(animeId);
      if (info == null) return;
      final change = await library.add(info, StatusAction.watching);
      final token = '${_nextToken++}';
      _undos[token] = change.undo;
      await _notifications.show(
        title: 'Добавлено в «Смотрю»',
        body: '«${info.title}»',
        command: 'title:$animeId',
        buttons: [
          NotificationButton(command: 'undo:$token', label: 'Отменить'),
        ],
      );
    } catch (_) {
      _added.remove(animeId);
    }
  }

  Future<void> _onWatched(Recognized recognized) async {
    final episode = recognized.episode;
    final id = recognized.shikimoriId ?? await _idBySlug(recognized.slug);
    final key = id != null && episode != null
        ? '$id:$episode'
        : 'title:${recognized.title}';
    if (_handled.contains(key)) return;
    _handled.add(key);

    final library = _ref.read(libraryRepositoryProvider);
    final item = id != null
        ? await _itemById(library, id)
        : await _itemByTitle(library, recognized.title);

    if (item == null) {
      if (id == null || episode == null) return;
      await _notifications.show(
        title: 'Добавить в Kiroku?',
        body: '«${recognized.title}» · досмотрена $episode-я серия',
        command: 'title:$id',
        buttons: [
          NotificationButton(
            command: 'track:$id:$episode',
            label: 'Добавить и отметить',
          ),
        ],
      );
      return;
    }

    final animeId = item.anime.id;
    if (episode == null) {
      final next = item.progress.nextEpisode;
      await _notifications.show(
        title: 'Отметить $next-ю серию?',
        body: '«${item.anime.title}»: похоже, серия досмотрена',
        command: 'title:$animeId',
        buttons: [
          NotificationButton(command: 'mark:$animeId:$next', label: 'Отметить'),
        ],
      );
      return;
    }
    await _mark(item.anime, episode, source: 'auto');
  }

  Future<void> _mark(Anime anime, int episode, {String? source}) async {
    final library = _ref.read(libraryRepositoryProvider);
    final entry = await library.watchEntry(anime.id).first;
    if (entry == null) return;
    final viewing = CurrentViewing.of(
      await library.watchHistory(anime.id).first,
      WatchStatus.fromName(entry.status),
    );
    if (viewing.events.containsKey(episode)) return;

    final change = await library.toggleEpisode(
      anime.id,
      episode,
      source: source,
    );
    var undo = change.undo;
    var note = '';
    if (change.finished) {
      final step = await _ref
          .read(queueRepositoryProvider)
          .onFinished(anime.id);
      if (step != null) {
        undo = () async {
          await step.undo();
          await change.undo();
        };
        note = step.finished
            ? ' · франшиза досмотрена по порядку'
            : ' · дальше «${step.next!.title}»';
      }
    }
    final token = '${_nextToken++}';
    _undos[token] = undo;
    await _notifications.show(
      title: change.finished
          ? 'Отмечена $episode-я серия, тайтл просмотрен'
          : 'Отмечена $episode-я серия',
      body: '«${anime.title}»$note',
      command: 'title:${anime.id}',
      buttons: [NotificationButton(command: 'undo:$token', label: 'Отменить')],
    );
  }

  /// Отмечает серию, которая сейчас играет.
  Future<void> markNowPlaying() async {
    final now = _ref.read(nowPlayingProvider);
    final animeId = now?.animeId;
    final episode = now?.episode;
    if (animeId == null || episode == null) return;
    _handled.add('$animeId:$episode');
    await handleCommand('track:$animeId:$episode');
  }

  /// Обрабатывает нажатия на уведомления автоотметки.
  Future<bool> handleCommand(String command) async {
    final parts = command.split(':');
    switch (parts) {
      case ['undo', final token]:
        final undo = _undos.remove(token);
        if (undo != null) {
          await undo();
          await _notifications.show(title: 'Отменено', body: 'Всё как было');
        }
        return true;
      case ['mark', final id, final episode]:
        final animeId = int.tryParse(id);
        final number = int.tryParse(episode);
        if (animeId == null || number == null) return true;
        final anime = (await _ref.read(libraryRepositoryProvider).animesByIds([
          animeId,
        ]))[animeId];
        if (anime != null) await _mark(anime, number);
        return true;
      case ['track', final id, final episode]:
        final animeId = int.tryParse(id);
        final number = int.tryParse(episode);
        if (animeId == null || number == null) return true;
        final library = _ref.read(libraryRepositoryProvider);
        if (await library.watchEntry(animeId).first != null) {
          final anime = (await library.animesByIds([animeId]))[animeId];
          if (anime != null) await _mark(anime, number);
          return true;
        }
        final info = await _ref.read(shikimoriClientProvider).getAnime(animeId);
        if (info == null) return true;
        await library.add(info, StatusAction.watching);
        final anime = (await library.animesByIds([animeId]))[animeId];
        if (anime != null) await _mark(anime, number);
        return true;
    }
    return false;
  }

  /// Запоминает озвучку, в которой смотрят тайтл.
  Future<void> _learnDubbing(int animeId, String? player) async {
    final key = player == null ? null : YummyClient.playerKey(player);
    if (key == null || !_learned.add('$animeId|$key')) return;
    try {
      final library = _ref.read(libraryRepositoryProvider);
      final entry = await library.watchEntry(animeId).first;
      if (entry == null) {
        _learned.remove('$animeId|$key');
        return;
      }
      var dubbing = YummyClient.dubbingInPlayerUrl(player!);
      if (dubbing == null) {
        final yummyId = await _ref
            .read(siteEpisodesRepositoryProvider)
            .yummyId(animeId);
        if (yummyId != null) {
          dubbing = await _ref
              .read(yummyClientProvider)
              .dubbingOfPlayer(yummyId, player);
        }
      }
      if (dubbing == null) return;
      if (kDebugMode) debugPrint('Автоотметка: озвучка «$dubbing»');
      if (entry.dubbingSeen != dubbing) {
        await library.setDubbingSeen(animeId, dubbing);
      }
      final anime = (await library.animesByIds([animeId]))[animeId];
      final franchise = anime == null ? null : franchiseKeyOf(entry, anime);
      if (franchise != null) {
        await _ref
            .read(franchiseRepositoryProvider)
            .setDubbingSeen(franchise, dubbing);
      }
    } catch (_) {
      _learned.remove('$animeId|$key');
    }
  }

  NotificationService get _notifications =>
      _ref.read(notificationServiceProvider);

  /// Номер Shikimori по адресу YummyAnime.
  Future<int?> _idBySlug(String? slug) async {
    if (slug == null) return null;
    if (_slugCache.containsKey(slug)) return _slugCache[slug];
    final settings = _ref.read(settingsRepositoryProvider);
    final saved = int.tryParse((await settings.readAll())['yummy.$slug'] ?? '');
    if (saved != null) return _slugCache[slug] = saved;
    final id = await YummyClient().shikimoriIdBySlug(slug);
    if (id != null) await settings.write('yummy.$slug', '$id');
    return _slugCache[slug] = id;
  }

  /// Тайтл библиотеки по номеру.
  Future<LibraryItem?> _itemById(LibraryRepository library, int id) async {
    final entry = await library.watchEntry(id).first;
    if (entry == null) return null;
    final items = _ref.read(libraryItemsProvider).value ?? const [];
    final shown = items.where((item) => item.anime.id == id).firstOrNull;
    if (shown != null) return shown;
    final anime = (await library.animesByIds([id]))[id];
    return anime == null ? null : LibraryItem(entry: entry, anime: anime);
  }

  /// Тайтл библиотеки по названию.
  Future<LibraryItem?> _itemByTitle(
    LibraryRepository library,
    String title,
  ) async {
    final needle = normalizeSearch(title);
    final items = _ref.read(libraryItemsProvider).value ?? const [];
    return items
        .where(
          (item) =>
              normalizeSearch(item.anime.russian) == needle ||
              normalizeSearch(item.anime.name) == needle,
        )
        .firstOrNull;
  }
}

/// Что сейчас играет.
class NowPlaying {
  const NowPlaying({
    this.animeId,
    required this.title,
    required this.episode,
    required this.ratio,
    required this.playing,
    this.position = 0,
    this.duration = 0,
    this.site = 'YummyAnime',
  });

  final int? animeId;
  final String title;
  final int? episode;
  final double ratio;
  final bool playing;
  final double position;
  final double duration;
  final String site;
}

class NowPlayingNotifier extends Notifier<NowPlaying?> {
  @override
  NowPlaying? build() => null;

  void set(NowPlaying? value) => state = value;
}

final nowPlayingProvider = NotifierProvider<NowPlayingNotifier, NowPlaying?>(
  NowPlayingNotifier.new,
);

final autoMarkerProvider = Provider<AutoMarker>((ref) {
  final marker = AutoMarker(ref);
  ref.onDispose(marker.stop);
  return marker;
});
