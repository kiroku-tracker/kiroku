import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kiroku/data/database/app_database.dart';
import 'package:kiroku/data/database/notices_repository.dart';
import 'package:kiroku/data/database/settings_repository.dart';
import 'package:kiroku/data/database/status_action.dart';
import 'package:kiroku/data/providers.dart';
import 'package:kiroku/data/shikimori/anime_info.dart';
import 'package:kiroku/data/shikimori/shikimori_client.dart';
import 'package:kiroku/features/notifications/alert_rules.dart';
import 'package:kiroku/features/notifications/release_events.dart';
import 'package:kiroku/features/notifications/release_watcher.dart';

AnimeInfo _part(int id, String status) => AnimeInfo(
  id: id,
  name: 'Name $id',
  russian: 'Сезон $id',
  kind: 'tv',
  episodes: 12,
  episodesAired: status == 'anons' ? 0 : 12,
  releaseStatus: status,
  airedOn: '20${10 + id}',
  franchise: 'show',
  relations: [
    if (id > 1) RelatedAnime(relatedId: id - 1, relation: 'prequel'),
    RelatedAnime(relatedId: id + 1, relation: 'sequel'),
  ],
);

LibraryEntry _entry({
  String status = 'watching',
  bool muted = false,
  bool alertsOn = false,
}) => LibraryEntry(
  id: 'e',
  animeId: 1,
  status: status,
  note: '',
  addedAt: DateTime(2026),
  updatedAt: DateTime(2026),
  muted: muted,
  alertsOn: alertsOn,
);

void main() {
  group('правила уведомлений', () {
    const prefs = AppPrefs();
    const off = AppPrefs(notifyEpisodes: false, notifyFranchises: false);

    test('серии тайтла', () {
      expect(episodeAlerts(_entry(), prefs), isTrue);
      expect(episodeAlerts(_entry(status: 'completed'), prefs), isFalse);
      expect(episodeAlerts(_entry(muted: true), prefs), isFalse);
      expect(episodeAlerts(_entry(), off), isFalse);
      expect(episodeAlerts(_entry(alertsOn: true), off), isTrue);
      expect(
        episodeAlerts(_entry(status: 'completed', alertsOn: true), prefs),
        isTrue,
      );
    });

    test('флаги', () {
      expect(alertFlags(on: true, byDefault: true), (
        muted: false,
        alertsOn: false,
      ));
      expect(alertFlags(on: false, byDefault: true), (
        muted: true,
        alertsOn: false,
      ));
      expect(alertFlags(on: true, byDefault: false), (
        muted: false,
        alertsOn: true,
      ));
    });
  });

  group('центр уведомлений', () {
    late AppDatabase database;
    late NoticesRepository notices;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      notices = NoticesRepository(database);
    });
    tearDown(() => database.close());

    test('непрочитанные и лишние', () async {
      await notices.add([
        for (var i = 0; i < NoticesRepository.keep + 5; i++)
          (category: 'episodes', animeId: i, title: 'Серия $i', body: ''),
      ]);
      expect(await notices.watchUnread().first, NoticesRepository.keep);
      final all = await notices.watchAll().first;
      expect(all, hasLength(NoticesRepository.keep));
      expect(all.first.animeId, NoticesRepository.keep + 4);
      await notices.markAllRead();
      expect(await notices.watchUnread().first, 0);
    });
  });

  group('новые сезоны', () {
    late AppDatabase database;
    late ProviderContainer container;
    late ReleaseWatcher watcher;

    setUp(() async {
      database = AppDatabase(NativeDatabase.memory());
      container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(database)],
      );
      watcher = container.read(releaseWatcherProvider);
      await container
          .read(libraryRepositoryProvider)
          .add(_part(1, 'released'), StatusAction.completed);
    });
    tearDown(() async {
      container.dispose();
      await database.close();
    });

    Future<List<ReleaseEvent>> save(
      List<AnimeInfo> parts, {
      bool fresh = false,
    }) => watcher.saveFranchise(
      FranchiseParts(key: 'show', parts: parts),
      fresh: fresh,
    );

    Future<void> prefs(AppPrefs Function(AppPrefs) edit) =>
        container.read(appPrefsProvider.notifier).change(edit);

    test('анонс и начало показа', () async {
      expect(await save([_part(1, 'released'), _part(2, 'anons')]), isEmpty);

      final started = await save([_part(1, 'released'), _part(2, 'ongoing')]);
      expect(started.single, isA<SeasonStarted>());
      expect(started.single.animeId, 2);
      expect(await save([_part(1, 'released'), _part(2, 'ongoing')]), isEmpty);

      final announced = await save([
        _part(1, 'released'),
        _part(2, 'ongoing'),
        _part(3, 'anons'),
      ]);
      expect(announced.single, isA<NewFranchisePart>());
      expect(announced.single.animeId, 3);
    });

    test('франшиза только что появилась у тайтла', () async {
      final events = await save([
        _part(1, 'released'),
        _part(2, 'anons'),
      ], fresh: true);
      expect(events.single, isA<NewFranchisePart>());
    });

    test('франшиза выключена или включена отдельно', () async {
      await save([_part(1, 'released'), _part(2, 'anons')]);
      final franchises = container.read(franchiseRepositoryProvider);

      await franchises.setAlerts('show', muted: true, alertsOn: false);
      expect(await save([_part(1, 'released'), _part(2, 'ongoing')]), isEmpty);

      await franchises.setAlerts('show', muted: false, alertsOn: true);
      await prefs((prefs) => prefs.copyWith(notifyFranchises: false));
      expect(
        (await save([
          _part(1, 'released'),
          _part(2, 'ongoing'),
          _part(3, 'anons'),
        ])).single.animeId,
        3,
      );
    });

    test('начало показа выключено в настройках', () async {
      await save([_part(1, 'released'), _part(2, 'anons')]);
      await prefs((prefs) => prefs.copyWith(notifySeasonStart: false));
      expect(await save([_part(1, 'released'), _part(2, 'ongoing')]), isEmpty);
    });
  });
}
