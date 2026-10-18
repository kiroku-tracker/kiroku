import 'package:flutter_test/flutter_test.dart';

import 'package:kiroku/data/database/app_database.dart';
import 'package:kiroku/data/database/library_repository.dart';
import 'package:kiroku/data/database/settings_repository.dart';
import 'package:kiroku/data/database/watch_status.dart';
import 'package:kiroku/features/library/library_filter.dart';

LibraryItem _item(
  int id,
  String title, {
  WatchStatus status = WatchStatus.watching,
  String kind = 'tv',
  int episodes = 12,
  int aired = 12,
  String release = 'released',
  int watched = 0,
  int nextEpisode = 1,
  int? score,
  String note = '',
  DateTime? nextAt,
  int addedDay = 1,
  int updatedDay = 1,
}) {
  return LibraryItem(
    entry: LibraryEntry(
      id: 'e$id',
      animeId: id,
      status: status.name,
      score: score,
      note: note,
      addedAt: DateTime(2026, 1, addedDay),
      updatedAt: DateTime(2026, 1, updatedDay),
      muted: false,
      alertsOn: false,
      favorite: false,
    ),
    anime: Anime(
      id: id,
      name: 'Name $id',
      russian: title,
      kind: kind,
      episodes: episodes,
      episodesAired: aired,
      releaseStatus: release,
      nextEpisodeAt: nextAt,
      updatedAt: DateTime(2026),
    ),
    progress: WatchProgress(watched: watched, nextEpisode: nextEpisode),
  );
}

List<String> _titles(List<LibraryItem> items) => [
  for (final item in items) item.anime.russian,
];

void main() {
  final items = [
    _item(1, 'Ёсино', status: WatchStatus.watching, updatedDay: 3, score: 7),
    _item(2, 'Атака', status: WatchStatus.completed, kind: 'movie', score: 9),
    _item(
      3,
      'Берсерк',
      status: WatchStatus.planned,
      kind: 'ova',
      note: 'посмотреть с друзьями',
      addedDay: 5,
    ),
    _item(4, 'Ванпанчмен', status: WatchStatus.dropped, kind: 'music'),
  ];

  List<String> run({
    WatchStatus? status,
    String query = '',
    KindFilter kind = KindFilter.all,
    LibrarySort sort = LibrarySort.title,
  }) => _titles(
    filterLibrary(items, status: status, query: query, kind: kind, sort: sort),
  );

  test('вкладки', () {
    expect(run(status: WatchStatus.completed), ['Атака']);
    expect(run(), ['Атака', 'Берсерк', 'Ванпанчмен', 'Ёсино']);
  });

  test('поиск', () {
    expect(run(query: 'есино'), ['Ёсино']);
    expect(run(query: 'ДРУЗЬЯМИ'), ['Берсерк']);
    expect(run(query: 'брошено'), ['Ванпанчмен']);
    expect(run(query: 'name 2'), ['Атака']);
  });

  test('фильтр по типу', () {
    expect(run(kind: KindFilter.movie), ['Атака']);
    expect(run(kind: KindFilter.other), ['Ванпанчмен']);
  });

  test('сортировки', () {
    expect(run(sort: LibrarySort.score).take(2), ['Атака', 'Ёсино']);
    expect(run(sort: LibrarySort.updated).first, 'Ёсино');
    expect(run(sort: LibrarySort.added).first, 'Берсерк');
  });

  test('по дате следующей серии', () {
    final soon = _item(
      10,
      'Скоро',
      release: 'ongoing',
      nextAt: DateTime(2026, 1, 10),
    );
    final later = _item(
      11,
      'Позже',
      release: 'ongoing',
      nextAt: DateTime(2026, 2, 10),
    );
    final sorted = filterLibrary(
      [later, items.first, soon],
      status: null,
      query: '',
      kind: KindFilter.all,
      sort: LibrarySort.nextEpisode,
    );
    expect(_titles(sorted), ['Скоро', 'Позже', 'Ёсино']);
  });

  test(
    '«Продолжить просмотр»: только «Смотрю» с вышедшими непросмотренными',
    () {
      final behind = _item(
        20,
        'Отстал',
        release: 'ongoing',
        episodes: 12,
        aired: 7,
        watched: 5,
        nextEpisode: 6,
      );
      final caughtUp = _item(
        21,
        'Догнал',
        release: 'ongoing',
        aired: 7,
        watched: 7,
        nextEpisode: 8,
      );
      final planned = _item(
        22,
        'Хочу',
        status: WatchStatus.planned,
        watched: 0,
      );
      final result = continueWatching([behind, caughtUp, planned]);
      expect(_titles(result), ['Отстал']);
      expect(unwatchedAired(behind), 2);
      expect(unwatchedAired(caughtUp), 0);
    },
  );

  test('счётчики вкладок', () {
    final counts = countByStatus(items);
    expect(counts[null], 4);
    expect(counts[WatchStatus.watching], 1);
    expect(counts[WatchStatus.paused], isNull);
  });
}
