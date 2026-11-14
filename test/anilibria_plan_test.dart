import 'package:flutter_test/flutter_test.dart';

import 'package:kiroku/data/anilibria/anilibria_client.dart';
import 'package:kiroku/data/anilibria/anilibria_plan.dart';
import 'package:kiroku/data/database/watch_status.dart';
import 'package:kiroku/data/import/import_plan.dart';
import 'package:kiroku/data/shikimori/anime_info.dart';

AnimeInfo _info(int id) => AnimeInfo(
  id: id,
  name: 'Anime $id',
  russian: 'Аниме $id',
  episodes: 12,
  episodesAired: 12,
  releaseStatus: 'released',
);

Future<Map<int, AnimeInfo>> _lookup(List<int> ids) async => {
  for (final id in ids)
    if (id < 900) id: _info(id),
};

AniLibriaCollectionItem _col(int release, int? shiki, String type) =>
    AniLibriaCollectionItem(
      releaseId: release,
      shikimoriId: shiki,
      title: 'Релиз $release',
      episodesTotal: 12,
      collection: type,
    );

AniLibriaFavorite _fav(int release, int? shiki) => AniLibriaFavorite(
  releaseId: release,
  shikimoriId: shiki,
  title: 'Релиз $release',
  episodesTotal: 12,
);

AniLibriaView _view(
  int release,
  int? shiki,
  num ordinal, {
  bool watched = true,
  int day = 1,
}) => AniLibriaView(
  releaseId: release,
  shikimoriId: shiki,
  title: 'Релиз $release',
  episodesTotal: 12,
  ordinal: ordinal,
  watched: watched,
  updatedAt: DateTime.utc(2025, 1, day),
);

Future<List<ImportItem>> _plan({
  List<AniLibriaCollectionItem> collections = const [],
  List<AniLibriaFavorite> favorites = const [],
  List<AniLibriaView> history = const [],
}) => aniLibriaItems(
  collections: collections,
  favorites: favorites,
  history: history,
  lookup: _lookup,
);

ImportItem _by(List<ImportItem> items, int shikimoriId) =>
    items.singleWhere((item) => item.shikimoriId == shikimoriId);

void main() {
  test('коллекции соответствуют статусам Kiroku', () async {
    final items = await _plan(
      collections: [
        _col(1, 1, 'WATCHING'),
        _col(2, 2, 'PLANNED'),
        _col(3, 3, 'WATCHED'),
        _col(4, 4, 'POSTPONED'),
        _col(5, 5, 'ABANDONED'),
      ],
    );
    expect(_by(items, 1).status, WatchStatus.watching);
    expect(_by(items, 2).status, WatchStatus.planned);
    expect(_by(items, 3).status, WatchStatus.completed);
    expect(_by(items, 4).status, WatchStatus.paused);
    expect(_by(items, 5).status, WatchStatus.dropped);
  });

  test('релиз в нескольких коллекциях: берётся по приоритету', () async {
    final items = await _plan(
      collections: [
        _col(1, 1, 'PLANNED'),
        _col(1, 1, 'WATCHED'),
        _col(1, 1, 'POSTPONED'),
      ],
    );
    expect(items.length, 1);
    expect(items.single.status, WatchStatus.completed);
    final watching = await _plan(
      collections: [_col(1, 1, 'WATCHED'), _col(1, 1, 'WATCHING')],
    );
    expect(watching.single.status, WatchStatus.watching);
  });

  test(
    'избранное: сердечко; только избранное даёт «Хочу посмотреть»',
    () async {
      final items = await _plan(
        collections: [_col(1, 1, 'WATCHING')],
        favorites: [_fav(1, 1), _fav(2, 2)],
      );
      expect(_by(items, 1).favorite, isTrue);
      expect(_by(items, 1).status, WatchStatus.watching);
      expect(_by(items, 2).favorite, isTrue);
      expect(_by(items, 2).status, WatchStatus.planned);
    },
  );

  test('только в истории: часть серий — «Смотрю» с датами', () async {
    final items = await _plan(
      history: [
        _view(1, 1, 1, day: 3),
        _view(1, 1, 2, day: 4),
        _view(1, 1, 3, watched: false),
      ],
    );
    final item = _by(items, 1);
    expect(item.status, WatchStatus.watching);
    expect(item.viewings.single.completed, isFalse);
    expect(item.viewings.single.episodes.map((e) => e.number), [1, 2]);
    expect(item.viewings.single.episodes[0].at, DateTime.utc(2025, 1, 3));
  });

  test('только в истории: все серии — «Просмотрено»', () async {
    final items = await _plan(
      history: [for (var n = 1; n <= 12; n++) _view(1, 1, n)],
    );
    final item = _by(items, 1);
    expect(item.status, WatchStatus.completed);
    expect(item.viewings.last.completed, isTrue);
    expect(item.viewings.last.episodes.length, 12);
  });

  test('только в истории и ничего не досмотрено: тайтла нет в плане', () async {
    final items = await _plan(history: [_view(1, 1, 1, watched: false)]);
    expect(items, isEmpty);
  });

  test('«Просмотрено»: все серии, даты у тех, что в истории', () async {
    final items = await _plan(
      collections: [_col(1, 1, 'WATCHED')],
      history: [_view(1, 1, 2, day: 9)],
    );
    final last = _by(items, 1).viewings.last;
    expect(last.completed, isTrue);
    expect(last.episodes.length, 12);
    expect(last.episodes[1].at, DateTime.utc(2025, 1, 9));
    expect(last.episodes[0].at, isNull);
  });

  test(
    '«Смотрю»: серии только из истории, непросмотренные не отмечаются',
    () async {
      final items = await _plan(
        collections: [_col(1, 1, 'WATCHING')],
        history: [_view(1, 1, 1), _view(1, 1, 2, watched: false)],
      );
      expect(_by(items, 1).viewings.single.episodes.map((e) => e.number), [1]);
    },
  );

  test('дробный номер пропускается, 5.0 считается пятой серией', () async {
    final items = await _plan(
      collections: [_col(1, 1, 'WATCHING')],
      history: [_view(1, 1, 5.5), _view(1, 1, 5.0)],
    );
    expect(_by(items, 1).viewings.single.episodes.map((e) => e.number), [5]);
  });

  test(
    'избранное и история без коллекции: правило истории и сердечко',
    () async {
      final items = await _plan(
        favorites: [_fav(1, 1)],
        history: [_view(1, 1, 1)],
      );
      expect(_by(items, 1).status, WatchStatus.watching);
      expect(_by(items, 1).favorite, isTrue);
    },
  );

  test(
    'без номера Shikimori или без ответа Shikimori: тайтл не найден',
    () async {
      final items = await _plan(
        collections: [_col(1, null, 'WATCHING'), _col(2, 999, 'PLANNED')],
      );
      expect(items.length, 2);
      expect(items.every((item) => item.anime == null), isTrue);
      expect(items.map((item) => item.sourceTitle), ['Релиз 1', 'Релиз 2']);
    },
  );

  test(
    'два релиза с одним номером Shikimori остаются двумя элементами',
    () async {
      final items = await _plan(
        collections: [_col(1, 7, 'WATCHING'), _col(2, 7, 'PLANNED')],
      );
      expect(items.where((item) => item.shikimoriId == 7).length, 2);
    },
  );
}
