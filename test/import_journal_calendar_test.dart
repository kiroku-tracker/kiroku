import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:kiroku/core/labels.dart';
import 'package:kiroku/data/database/app_database.dart';
import 'package:kiroku/data/database/franchise_repository.dart';
import 'package:kiroku/data/database/library_repository.dart';
import 'package:kiroku/data/database/settings_repository.dart';
import 'package:kiroku/data/database/status_action.dart';
import 'package:kiroku/data/database/watch_status.dart';
import 'package:kiroku/data/shikimori/anime_info.dart';
import 'package:kiroku/data/shikimori/shikimori_client.dart';
import 'package:kiroku/data/shikimori/user_rate.dart';
import 'package:kiroku/data/watch/dubbing_rules.dart';
import 'package:kiroku/data/watch/site_episodes_repository.dart';
import 'package:kiroku/data/yummy/yummy_client.dart';
import 'package:kiroku/features/calendar/calendar_model.dart';
import 'package:kiroku/features/journal/journal_model.dart';
import 'package:kiroku/features/notifications/release_events.dart';

void main() {
  late AppDatabase database;
  late LibraryRepository library;

  const frieren = AnimeInfo(
    id: 52991,
    name: 'Sousou no Frieren',
    russian: 'Фрирен',
    kind: 'tv',
    episodes: 28,
    episodesAired: 28,
    releaseStatus: 'released',
  );
  const ongoing = AnimeInfo(
    id: 1,
    name: 'Ongoing',
    russian: 'Онгоинг',
    episodes: 12,
    episodesAired: 7,
    releaseStatus: 'ongoing',
  );
  const other = AnimeInfo(
    id: 3,
    name: 'Other',
    russian: 'Другой',
    episodes: 12,
    episodesAired: 12,
    releaseStatus: 'released',
  );

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    library = LibraryRepository(database);
  });
  tearDown(() => database.close());

  Future<Map<int, LibraryItem>> items() async {
    final rows = await library.watchItems().first;
    final progress = await library.watchProgress().first;
    return {
      for (final row in rows)
        row.anime.id: LibraryItem(
          entry: row.entry,
          anime: row.anime,
          progress: progress[row.entry.id] ?? const WatchProgress(),
        ),
    };
  }

  group('импорт из Shikimori', () {
    test('импорт', () async {
      final result = await library.importRates([
        const UserRate(
          anime: frieren,
          status: 'completed',
          score: 10,
          episodes: 28,
          rewatches: 1,
          text: 'Лучшее',
        ),
        const UserRate(anime: ongoing, status: 'watching', episodes: 5),
        const UserRate(anime: other, status: 'on_hold', episodes: 3),
      ], replace: false);
      expect(result.added, 3);

      final all = await items();
      expect(all[52991]!.status, WatchStatus.completed);
      expect(all[52991]!.entry.score, 10);
      expect(all[52991]!.entry.note, 'Лучшее');
      final history = await library.watchHistory(52991).first;
      expect(history, hasLength(2));
      expect(history.every((cycle) => cycle.isCompleted), isTrue);
      expect(history.first.events, hasLength(28));

      expect(all[1]!.status, WatchStatus.watching);
      expect(all[1]!.progress.watched, 5);
      expect(all[1]!.progress.nextEpisode, 6);
      expect(all[3]!.status, WatchStatus.paused);

      expect(await library.watchJournal().first, isEmpty);
    });

    test('пересмотр', () async {
      await library.importRates([
        const UserRate(anime: frieren, status: 'rewatching', episodes: 4),
      ], replace: false);
      final history = await library.watchHistory(52991).first;
      expect(history.map((cycle) => cycle.cycle.state), [
        'completed',
        'active',
      ]);
      expect((await items())[52991]!.progress.cycleNumber, 2);
    });

    test('повторный импорт', () async {
      await library.add(ongoing, StatusAction.watching);
      await library.toggleEpisode(1, 1);

      final skip = await library.importRates([
        const UserRate(anime: ongoing, status: 'dropped', episodes: 2),
        const UserRate(anime: other, status: 'planned'),
      ], replace: false);
      expect((skip.added, skip.skipped), (1, 1));
      expect((await items())[1]!.status, WatchStatus.watching);
      await skip.undo();
      expect((await items()).keys, [1]);

      final replace = await library.importRates([
        const UserRate(anime: ongoing, status: 'dropped', episodes: 2),
      ], replace: true);
      expect(replace.replaced, 1);
      var item = (await items())[1]!;
      expect(item.status, WatchStatus.dropped);
      expect(item.progress.watched, 2);

      await replace.undo();
      item = (await items())[1]!;
      expect(item.status, WatchStatus.watching);
      expect(item.progress.watched, 1);
    });

    test('ник из ссылки', () {
      expect(ShikimoriClient.nicknameOf('RLTEX'), 'RLTEX');
      expect(
        ShikimoriClient.nicknameOf('https://shikimori.one/RLTEX/list/anime'),
        'RLTEX',
      );
      expect(ShikimoriClient.nicknameOf('shikimori.io/Some%20One'), 'Some One');
    });
  });

  group('журнал', () {
    test('строки журнала', () async {
      await library.add(ongoing, StatusAction.watching);
      await library.toggleEpisode(1, 1);
      await library.toggleEpisode(1, 2);
      await library.toggleEpisode(1, 3, source: 'auto');
      await library.add(frieren, StatusAction.watching);
      await library.toggleEpisode(52991, 1);
      final ongoingCycle = (await library.watchHistory(1).first).single.cycle;
      final frierenCycle =
          (await library.watchHistory(52991).first).single.cycle;
      await library.setEpisodesDate(1, ongoingCycle.id, [
        1,
        2,
      ], DateTime(2026, 10, 1, 20));
      await library.setEpisodesDate(1, ongoingCycle.id, [
        3,
      ], DateTime(2026, 10, 1, 21));
      await library.setEpisodesDate(52991, frierenCycle.id, [
        1,
      ], DateTime(2026, 10, 1, 22));

      final days = groupJournal(await library.watchJournal().first);
      expect(days, hasLength(1));
      final rows = days.single.rows;
      expect(rows.map((row) => '${row.anime.id} ${row.episodes} ${row.auto}'), [
        '52991 [1] false',
        '1 [3] true',
        '1 [1, 2] false',
      ]);
    });

    test('правка из журнала', () async {
      await library.add(ongoing, StatusAction.watching);
      await library.markRange(1, 1, 3);
      final cycle = (await library.watchHistory(1).first).single.cycle;
      final date = DateTime(2026, 10, 1, 21, 30);
      await library.setEpisodesDate(1, cycle.id, [1, 2], date);
      final events = (await library.watchHistory(1).first).single.events;
      expect(events[1]!.watchedAt, date);
      expect(events[3]!.watchedAt, isNull);

      final undo = await library.unmarkEpisodes(1, cycle.id, [2, 3]);
      expect((await items())[1]!.progress.watched, 1);
      await undo.undo();
      expect((await items())[1]!.progress.watched, 3);
    });

    test('диапазоны серий', () {
      expect(episodeRanges([7, 5, 6, 3]), '3, 5–7');
      expect(episodesWord([4]), 'Серия 4');
      expect(episodesWord([1, 2]), 'Серии 1–2');
    });
  });

  group('календарь', () {
    LibraryItem item(
      AnimeInfo info, {
      DateTime? next,
      String status = 'watching',
    }) => LibraryItem(
      entry: LibraryEntry(
        id: 'e${info.id}',
        animeId: info.id,
        status: status,
        note: '',
        addedAt: DateTime(2026),
        updatedAt: DateTime(2026),
        muted: false,
      ),
      anime: Anime(
        id: info.id,
        name: info.name,
        russian: info.russian,
        episodes: info.episodes,
        episodesAired: info.episodesAired,
        releaseStatus: info.releaseStatus,
        nextEpisodeAt: next,
        airedOn: info.airedOn,
        updatedAt: DateTime(2026),
      ),
    );

    test('серии недели', () {
      final now = DateTime(2026, 10, 12, 12);
      final next = DateTime(2026, 10, 14, 1, 10);
      final week = buildCalendarWeek([
        item(ongoing, next: next),
        item(other),
        item(
          const AnimeInfo(
            id: 9,
            name: 'A',
            russian: 'Анонс',
            releaseStatus: 'anons',
            airedOn: '2027-10',
          ),
          status: 'planned',
        ),
        item(ongoing, next: next, status: 'dropped'),
      ], now: now);
      expect(week.start, DateTime(2026, 10, 12));
      expect(week.days[2].single.episode, 8);
      expect(week.days[2].single.estimated, isFalse);
      expect(week.days.where((day) => day.isNotEmpty), hasLength(1));
      expect(week.announced.single.anime.id, 9);
      expect(formatAiredOn('2027-10'), 'октябрь 2027');

      final nextWeek = buildCalendarWeek(
        [item(ongoing, next: next)],
        now: now,
        weekOffset: 1,
      );
      expect(nextWeek.days[2].single.episode, 9);
      expect(nextWeek.days[2].single.estimated, isTrue);

      final lastWeek = buildCalendarWeek(
        [item(ongoing, next: next)],
        now: now,
        weekOffset: -1,
      );
      expect(lastWeek.days[2].single.episode, 7);
    });

    test('онгоинг без даты', () {
      final now = DateTime(2026, 10, 12, 12);
      const last = AnimeInfo(
        id: 5,
        name: 'L',
        russian: 'Последняя',
        episodes: 8,
        episodesAired: 7,
        releaseStatus: 'ongoing',
      );
      final week = buildCalendarWeek(
        [item(ongoing), item(last, next: DateTime(2026, 10, 13, 18))],
        now: now,
        weekOffset: 1,
      );
      expect(week.undated.single.anime.id, 1);
      expect(week.days.every((day) => day.isEmpty), isTrue);
    });
  });

  group('серии на YummyAnime', () {
    SiteEpisodesInfo info(Map<String, int> map) =>
        SiteEpisodesInfo(byDubbing: map, checkedAt: DateTime(2026));

    test('число серий', () {
      final site = info({'AniLibria': 6, 'AniDUB': 7, 'Субтитры SubVost': 8});
      expect(siteProgress(site), (episodes: 8, dubbing: 'Субтитры SubVost'));
      expect(siteProgress(site, dubbing: 'AniLibria'), (
        episodes: 6,
        dubbing: 'AniLibria',
      ));
      expect(siteProgress(site, dubbing: 'Кураж'), (
        episodes: 0,
        dubbing: 'Кураж',
      ));
    });

    test('выбор озвучки', () {
      LibraryEntry entry({String? dubbing, String? seen}) => LibraryEntry(
        id: 'e',
        animeId: 1,
        status: 'watching',
        note: '',
        addedAt: DateTime(2026),
        updatedAt: DateTime(2026),
        muted: false,
        dubbing: dubbing,
        dubbingSeen: seen,
      );
      Franchise franchise({String? dubbing, String? seen}) => Franchise(
        key: 'f',
        dubbing: dubbing,
        dubbingSeen: seen,
        updatedAt: DateTime(2026),
      );
      String? pick(LibraryEntry e, [Franchise? f]) {
        final choice = effectiveDubbing(e, f);
        return choice == null ? null : '${choice.name}/${choice.source.name}';
      }

      expect(pick(entry()), isNull);
      expect(pick(entry(), franchise(seen: 'AniDUB')), 'AniDUB/franchiseSeen');
      expect(
        pick(entry(seen: 'AniLibria'), franchise(seen: 'AniDUB')),
        'AniLibria/seen',
      );
      expect(
        pick(entry(seen: 'AniLibria'), franchise(dubbing: 'Dream Cast')),
        'Dream Cast/franchise',
      );
      expect(
        pick(entry(dubbing: 'JAM', seen: 'AniLibria'), franchise(dubbing: 'X')),
        'JAM/title',
      );
      expect(pick(entry(dubbing: '', seen: 'AniLibria')), isNull);
      expect(pick(entry(seen: 'A'), franchise(dubbing: '')), isNull);
    });

    test('сохранение озвучки', () async {
      await library.add(ongoing, StatusAction.watching);
      await library.setDubbingSeen(1, 'AniLibria');
      final franchises = FranchiseRepository(database, library);
      await franchises.setDubbingSeen('k', 'AniDUB');
      await franchises.setDubbingSeen('k', 'JAM');
      final undo = await franchises.setDubbing('k', 'Dream Cast');
      var row = (await franchises.watchFranchises().first)['k']!;
      expect((row.dubbing, row.dubbingSeen), ('Dream Cast', 'JAM'));
      await undo();
      row = (await franchises.watchFranchises().first)['k']!;
      expect((row.dubbing, row.dubbingSeen), (null, 'JAM'));
      final entry = (await library.watchEntry(1).first)!;
      expect((entry.dubbing, entry.dubbingSeen), (null, 'AniLibria'));
    });

    test('озвучка по адресу плеера', () {
      const kodik =
          'https://kodikplayer.com/season/116916/feb419343c39fb54f0478680a99eab1b/'
          '720p?translations=false&only_episode=true&episode=4';
      expect(
        YummyClient.playerKey(kodik),
        YummyClient.playerKey(
          '//kodikplayer.com/season/116916/feb419343c39fb54f0478680a99eab1b/'
          '720p?translations=false&episode=1',
        ),
      );
      expect(
        YummyClient.playerKey(
          'https://ru.yummyani.me/iframeCVH.html?dubbing_code=AnilibriaTV&'
          'anime_id=38671&episode=10',
        ),
        'cvh:AnilibriaTV',
      );
      expect(
        YummyClient.dubbingInPlayerUrl(
          '//ru.yummyani.me/iframeCVH.html?dubbing_code=AniLiberty&anime_id='
          '59978&episode=2&dubbing=%D0%9E%D0%B7%D0%B2%D1%83%D1%87%D0%BA%D0%B0'
          '+AniLibria',
        ),
        'AniLibria',
      );
      expect(YummyClient.dubbingInPlayerUrl(kodik), isNull);
    });

    test('уведомления о сайте', () {
      final before = info({'AniLibria': 6});
      final after = info({'AniLibria': 8});
      expect(
        siteEvents(
          animeId: 1,
          title: 'Т',
          before: const SiteEpisodesInfo(),
          after: after,
          dubbing: 'AniLibria',
        ),
        isEmpty,
      );
      final events = siteEvents(
        animeId: 1,
        title: 'Т',
        before: before,
        after: after,
        dubbing: 'AniLibria',
      );
      final event = events.single as EpisodesOnSite;
      expect((event.from, event.to, event.dubbing), (7, 8, 'AniLibria'));
      expect(notificationText(event).title, 'Серии 7–8 на YummyAnime');
    });

    test('серии по озвучкам', () async {
      final client = YummyClient(
        httpClient: MockClient((request) async {
          final body = request.url.path.endsWith('/videos')
              ? {
                  'response': [
                    for (final (number, dubbing) in [
                      ('1', 'Озвучка AniLibria'),
                      ('2', 'Озвучка AniLibria'),
                      ('3', 'Субтитры SubVost'),
                      ('x', 'Озвучка AniLibria'),
                    ])
                      {
                        'number': number,
                        'data': {'dubbing': dubbing, 'player': 'Плеер Kodik'},
                      },
                  ],
                }
              : {
                  'response': [
                    {'anime_url': 'slug', 'anime_id': 15084},
                  ],
                };
          return http.Response.bytes(utf8.encode(jsonEncode(body)), 200);
        }),
      );
      final repository = SiteEpisodesRepository(
        database,
        SettingsRepository(database),
        client,
      );
      final result = await repository.refresh(59978);
      expect(result.before.checked, isFalse);
      expect(result.after.byDubbing, {'AniLibria': 2, 'Субтитры SubVost': 3});
      final stored = await repository.read(59978);
      expect(stored.checked, isTrue);
      expect(stored.byDubbing, result.after.byDubbing);
      expect(
        (await SettingsRepository(database).readAll())['yummy.aid.59978'],
        '15084',
      );
    });
  });

  test('сохранение настроек', () {
    const prefs = AppPrefs(
      yummyHost: YummyHost.old,
      episodeAlert: EpisodeAlert.site,
      showContinue: false,
      autoAdd: false,
    );
    final restored = AppPrefs.fromSettings(prefs.toSettings());
    expect(restored.showContinue, isFalse);
    expect(restored.autoAdd, isFalse);
    expect(AppPrefs.fromSettings(const {}).autoAdd, isTrue);
    expect(AppPrefs.fromSettings(const {}).showContinue, isTrue);
    expect(restored.yummyHost, YummyHost.old);
    expect(restored.episodeAlert, EpisodeAlert.site);
    expect(AppPrefs.fromSettings(const {}).episodeAlert, EpisodeAlert.air);
  });
}
