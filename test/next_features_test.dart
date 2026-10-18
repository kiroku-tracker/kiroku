import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kiroku/data/database/app_database.dart';
import 'package:kiroku/data/database/franchise_rules.dart';
import 'package:kiroku/data/database/library_repository.dart';
import 'package:kiroku/data/database/settings_repository.dart';
import 'package:kiroku/data/database/status_action.dart';
import 'package:kiroku/data/database/watch_status.dart';
import 'package:kiroku/data/providers.dart';
import 'package:kiroku/data/shikimori/anime_info.dart';
import 'package:kiroku/features/discover/discover_logic.dart';
import 'package:kiroku/features/library/library_filter.dart';

Anime _anime(int id, {String release = 'released', String? franchise}) => Anime(
  id: id,
  name: 'Name $id',
  russian: 'Тайтл $id',
  kind: 'tv',
  episodes: 12,
  episodesAired: release == 'anons' ? 0 : 12,
  releaseStatus: release,
  franchise: franchise,
  updatedAt: DateTime(2026),
);

LibraryItem _item(
  int id, {
  WatchStatus status = WatchStatus.completed,
  String release = 'released',
  String? franchise,
  bool favorite = false,
  int? score,
}) => LibraryItem(
  entry: LibraryEntry(
    id: 'e$id',
    animeId: id,
    status: status.name,
    score: score,
    note: '',
    addedAt: DateTime(2026),
    updatedAt: DateTime(2026),
    muted: false,
    alertsOn: false,
    favorite: favorite,
  ),
  anime: _anime(id, release: release, franchise: franchise),
);

Franchise _franchise(String key, {bool favorite = false}) => Franchise(
  key: key,
  muted: false,
  alertsOn: false,
  favorite: favorite,
  updatedAt: DateTime(2026),
);

void main() {
  test('невышедшая часть не считается в прогрессе франшизы', () {
    final unit = groupLibrary([
      _item(1, franchise: 'f'),
      _item(2, franchise: 'f'),
      _item(3, status: WatchStatus.planned, release: 'anons', franchise: 'f'),
    ], const {}).whereType<FranchiseUnit>().single;

    expect(unit.items, hasLength(3));
    expect(unit.completedCount, 2);
    expect(unit.releasedCount, 2);
    expect(unit.progress, 1);
  });

  test('избранное: франшиза целиком и отдельные тайтлы', () {
    final items = [
      _item(1, franchise: 'f'),
      _item(2, franchise: 'f'),
      _item(3, favorite: true),
      _item(4, franchise: 'g', favorite: true),
      _item(5, franchise: 'g'),
      _item(6),
    ];
    final franchises = {
      'f': _franchise('f', favorite: true),
      'g': _franchise('g'),
    };
    List<LibraryUnit> units({required bool group}) => libraryUnits(
      items,
      status: null,
      query: '',
      kind: KindFilter.all,
      sort: LibrarySort.title,
      groupFranchises: group,
      franchises: franchises,
      favorites: true,
    );

    final grouped = units(group: true);
    expect(grouped.whereType<FranchiseUnit>().single.key, 'f');
    expect(
      {for (final unit in grouped.whereType<TitleUnit>()) unit.item.anime.id},
      {3, 4},
    );
    expect(
      {
        for (final unit in units(group: false))
          (unit as TitleUnit).item.anime.id,
      },
      {1, 2, 3, 4},
    );
  });

  test('просмотры без дат добавляются и убираются', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final library = LibraryRepository(database);
    await library.add(
      const AnimeInfo(
        id: 7,
        name: 'Show',
        russian: 'Тайтл',
        kind: 'tv',
        episodes: 3,
        episodesAired: 3,
        releaseStatus: 'released',
      ),
      StatusAction.completed,
    );
    final journal = (await library.watchJournal().first).length;
    expect((await library.watchViews().first)[7], (views: 1, removable: 0));

    await library.addView(7);
    expect((await library.watchViews().first)[7], (views: 2, removable: 1));
    expect(await library.watchJournal().first, hasLength(journal));

    await library.removeView(7);
    await library.removeView(7);
    expect((await library.watchViews().first)[7], (views: 1, removable: 0));
  });

  test('продолжения франшиз: первая вышедшая непросмотренная часть', () {
    final order = WatchOrder(
      main: [
        _anime(1, franchise: 'f'),
        _anime(2, franchise: 'f'),
        _anime(3, franchise: 'f'),
        _anime(4, release: 'anons', franchise: 'f'),
      ],
      extra: const [],
    );
    final result = franchiseContinuations(
      [
        _item(1, franchise: 'f'),
        _item(3, status: WatchStatus.planned, franchise: 'f'),
      ],
      const {},
      (key) => key == 'f' ? order : null,
    );

    expect(result.single.anime.id, 2);
    expect(result.single.left, 2);
  });

  test('похожее: выше то, что похоже на несколько любимых', () {
    final best = _item(1, score: 10);
    final good = _item(2, score: 6);
    final ranked = rankSimilar(
      {
        best: [10, 11, 12],
        good: [11, 1],
      },
      {1, 2},
    );

    expect(ranked.first.id, 11);
    expect(ranked.first.because, ['Тайтл 1', 'Тайтл 2']);
    expect([for (final pick in ranked) pick.id], isNot(contains(1)));
  });

  test('«Не интересно» запоминается и возвращается', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(database)],
    );
    addTearDown(container.dispose);

    final hidden = container.read(discoverHiddenProvider.notifier);
    await container.read(discoverHiddenProvider.future);
    await hidden.hide(5);
    await hidden.hide(7);
    await hidden.unhide(5);

    final fresh = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(database)],
    );
    addTearDown(fresh.dispose);
    expect(await fresh.read(discoverHiddenProvider.future), {7});
  });

  test('«Хочу посмотреть»: доступно, выходит и не вышло', () {
    final items = [
      _item(1, status: WatchStatus.planned),
      _item(2, status: WatchStatus.planned, release: 'ongoing'),
      _item(3, status: WatchStatus.planned, release: 'anons', franchise: 'f'),
      _item(4, status: WatchStatus.planned, release: 'anons', franchise: 'f'),
      _item(5, franchise: 'f'),
      _item(6, status: WatchStatus.watching, release: 'ongoing'),
    ];
    expect(plannedCounts(items), {
      PlannedFilter.all: 4,
      PlannedFilter.available: 1,
      PlannedFilter.airing: 1,
      PlannedFilter.announced: 2,
    });
    List<LibraryUnit> units(PlannedFilter planned) => libraryUnits(
      items,
      status: WatchStatus.planned,
      query: '',
      kind: KindFilter.all,
      sort: LibrarySort.title,
      groupFranchises: true,
      franchises: const {},
      planned: planned,
    );
    int single(PlannedFilter planned) =>
        (units(planned).single as TitleUnit).item.anime.id;

    expect(single(PlannedFilter.available), 1);
    expect(single(PlannedFilter.airing), 2);
    final announced = units(PlannedFilter.announced).single as FranchiseUnit;
    expect({for (final item in announced.items) item.anime.id}, {3, 4});
    expect(units(PlannedFilter.all), hasLength(3));
  });

  test('у пунктов «Хочу посмотреть» своя сортировка', () {
    const prefs = LibraryPrefs(planned: PlannedFilter.airing);
    expect(prefs.sortIn(WatchStatus.planned), LibrarySort.nextEpisode);
    expect(prefs.sortIn(WatchStatus.watching), LibrarySort.updated);

    final changed = prefs.withSort(WatchStatus.planned, LibrarySort.title);
    expect(changed.sortIn(WatchStatus.planned), LibrarySort.title);
    expect(changed.sort, LibrarySort.updated);

    final restored = LibraryPrefs.fromSettings({
      'library.planned': 'airing',
      'library.sort.airing': 'title',
    });
    expect(restored.sortIn(WatchStatus.planned), LibrarySort.title);
  });

  test('дата премьеры без месяца и дня', () {
    expect(premiereAt('2027'), DateTime(2027, 12, 31));
    expect(premiereAt('2027-02'), DateTime(2027, 2, 28));
    expect(premiereAt('2027-10-03'), DateTime(2027, 10, 3));
    expect(premiereAt(null), isNull);
  });
}
