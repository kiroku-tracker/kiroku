import 'package:flutter_test/flutter_test.dart';

import 'package:kiroku/data/database/app_database.dart';
import 'package:kiroku/data/database/franchise_rules.dart';
import 'package:kiroku/data/database/library_repository.dart';
import 'package:kiroku/data/database/settings_repository.dart';
import 'package:kiroku/data/database/user_groups_repository.dart';
import 'package:kiroku/data/database/watch_status.dart';
import 'package:kiroku/features/library/library_filter.dart';

Anime _anime(
  int id,
  String title, {
  String kind = 'tv',
  String airedOn = '2020-01-01',
  String? franchise = 'f',
}) => Anime(
  id: id,
  name: 'Name $id',
  russian: title,
  kind: kind,
  episodes: 12,
  episodesAired: 12,
  releaseStatus: 'released',
  airedOn: airedOn,
  franchise: franchise,
  updatedAt: DateTime(2026),
);

LibraryItem _item(
  Anime anime, {
  WatchStatus status = WatchStatus.planned,
  int? score,
  String? override,
  int updatedDay = 1,
}) => LibraryItem(
  entry: LibraryEntry(
    id: 'e${anime.id}',
    animeId: anime.id,
    status: status.name,
    score: score,
    note: '',
    addedAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, updatedDay),
    franchiseOverride: override,
    muted: false,
  ),
  anime: anime,
);

AnimeRelation _rel(int from, int to, String relation) =>
    AnimeRelation(animeId: from, relatedId: to, relation: relation);

void main() {
  group('порядок просмотра', () {
    test('основная линия', () {
      final parts = [
        _anime(1, 'Сезон 1', airedOn: '2013-04-07'),
        _anime(2, 'Сезон 2', airedOn: '2017-04-01'),
        _anime(3, 'Пересказ', kind: 'movie', airedOn: '2014-11-22'),
        _anime(4, 'Спин-офф', airedOn: '2015-10-04'),
        _anime(5, 'Клип', kind: 'music', airedOn: '2018-01-01'),
        _anime(6, 'Анонс', airedOn: '2027'),
      ];
      final order = buildWatchOrder(parts, [
        _rel(1, 2, 'sequel'),
        _rel(2, 1, 'prequel'),
        _rel(2, 6, 'sequel'),
        _rel(6, 2, 'prequel'),
        _rel(3, 1, 'full_story'),
        _rel(1, 3, 'summary'),
        _rel(4, 1, 'parent_story'),
        _rel(1, 4, 'spin_off'),
        _rel(5, 1, 'other'),
      ]);
      expect(order.main.map((a) => a.id), [1, 2, 6]);
      expect(order.extra.map((a) => a.id), [3, 4]);
    });

    test('ремейк в основной линии', () {
      final order = buildWatchOrder(
        [
          _anime(1, 'Алхимик', airedOn: '2003-10-04'),
          _anime(2, 'Фильм', kind: 'movie', airedOn: '2005-07-23'),
          _anime(3, 'Братство', airedOn: '2009-04-05'),
          _anime(4, 'Спецвыпуск', kind: 'special', airedOn: '2009-08-26'),
        ],
        [
          _rel(1, 2, 'sequel'),
          _rel(2, 1, 'prequel'),
          _rel(3, 1, 'alternative_version'),
          _rel(4, 3, 'parent_story'),
        ],
      );
      expect(order.main.map((a) => a.id), [1, 2, 3]);
      expect(order.extra.map((a) => a.id), [4]);
    });

    test('без цепочек', () {
      final order = buildWatchOrder([
        _anime(1, 'Сериал'),
        _anime(2, 'OVA-спецвыпуск', kind: 'special'),
      ], const []);
      expect(order.main.map((a) => a.id), [1]);
      expect(order.extra.map((a) => a.id), [2]);
    });
  });

  group('франшизы в библиотеке', () {
    final s1 = _anime(1, 'Сезон 1', airedOn: '2013');
    final s2 = _anime(2, 'Сезон 2', airedOn: '2017');
    final solo = _anime(3, 'Одиночный', franchise: '');
    final lone = _anime(4, 'Один из франшизы', franchise: 'g');

    test('группировка', () {
      final units = groupLibrary([
        _item(s2, status: WatchStatus.watching, score: 8),
        _item(s1, status: WatchStatus.completed, score: 9),
        _item(solo),
        _item(lone),
      ], const {});
      final franchise = units.whereType<FranchiseUnit>().single;
      expect(franchise.items.map((i) => i.anime.id), [1, 2]);
      expect(franchise.name, 'Сезон 1');
      expect(franchise.averageScore, 8.5);
      expect(franchise.completedCount, 1);
      expect(units.whereType<TitleUnit>().length, 2);
    });

    test('вынесенная часть', () {
      final units = groupLibrary([
        _item(s1),
        _item(s2, override: ''),
      ], const {});
      expect(units.whereType<FranchiseUnit>(), isEmpty);
    });

    test('франшиза во вкладке', () {
      List<LibraryUnit> units(WatchStatus? status, {String query = ''}) =>
          libraryUnits(
            [
              _item(s1, status: WatchStatus.completed),
              _item(s2, status: WatchStatus.watching),
              _item(solo, status: WatchStatus.planned),
            ],
            status: status,
            query: query,
            kind: KindFilter.all,
            sort: LibrarySort.title,
            groupFranchises: true,
            franchises: const {},
          );
      expect(units(WatchStatus.watching).single, isA<FranchiseUnit>());
      expect(units(WatchStatus.completed).single, isA<FranchiseUnit>());
      expect(units(WatchStatus.planned).single, isA<TitleUnit>());
      expect(units(null).length, 2);
      final found = units(null, query: 'сезон 2').single as TitleUnit;
      expect(found.item.anime.id, 2);
      expect(found.franchiseName, 'Сезон 1');
    });
  });

  group('группы', () {
    final s1 = _anime(1, 'Сезон 1');
    final s2 = _anime(2, 'Сезон 2');
    final solo = _anime(3, 'Одиночный', franchise: '');

    test('тайтл из франшизы', () {
      expect(memberKeyOf(_item(s1)), 'f:f');
      expect(memberKeyOf(_item(solo)), 'a:3');
    });

    test('содержимое группы', () {
      final library = [_item(s1), _item(s2), _item(solo)];
      expect(groupItems(library, {'f:f'}).map((i) => i.anime.id), [1, 2]);
      expect(groupItems(library, {'a:2'}).map((i) => i.anime.id), [1, 2]);
      expect(groupItems(library, {'a:3'}).map((i) => i.anime.id), [3]);
      expect(
        groupsOf(_item(s2), {
          'g1': {'f:f'},
          'g2': {'a:3'},
        }),
        {'g1'},
      );
    });
  });
}
