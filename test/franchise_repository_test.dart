import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kiroku/data/database/app_database.dart';
import 'package:kiroku/data/database/franchise_repository.dart';
import 'package:kiroku/data/database/franchise_rules.dart';
import 'package:kiroku/data/database/library_repository.dart';
import 'package:kiroku/data/database/queue_repository.dart';
import 'package:kiroku/data/database/status_action.dart';
import 'package:kiroku/data/database/user_groups_repository.dart';
import 'package:kiroku/data/database/watch_status.dart';
import 'package:kiroku/data/shikimori/anime_info.dart';
import 'package:kiroku/data/shikimori/shikimori_client.dart';

AnimeInfo _part(
  int id,
  String title,
  String airedOn, {
  List<RelatedAnime> relations = const [],
}) => AnimeInfo(
  id: id,
  name: 'Name $id',
  russian: title,
  kind: 'tv',
  episodes: 12,
  episodesAired: 12,
  releaseStatus: 'released',
  airedOn: airedOn,
  franchise: 'show',
  relations: relations,
);

void main() {
  late AppDatabase database;
  late LibraryRepository library;
  late FranchiseRepository franchises;

  final s1 = _part(
    1,
    'Сезон 1',
    '2015',
    relations: const [RelatedAnime(relatedId: 2, relation: 'sequel')],
  );
  final s2 = _part(
    2,
    'Сезон 2',
    '2017',
    relations: const [RelatedAnime(relatedId: 1, relation: 'prequel')],
  );
  final s3 = _part(3, 'Сезон 3', '2019');

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    library = LibraryRepository(database);
    franchises = FranchiseRepository(database, library);
  });
  tearDown(() => database.close());

  Future<List<LibraryUnit>> units() async => groupLibrary(
    await library.watchItems().first,
    await franchises.watchFranchises().first,
  );

  test('сохранение частей', () async {
    await franchises.saveParts(FranchiseParts(key: 'show', parts: [s2, s1]));
    final row = (await franchises.watchFranchises().first)['show']!;
    expect(row.autoName, 'Сезон 1');
    expect(row.partsLoadedAt, isNotNull);
    expect(await franchises.needsLoading('show'), isFalse);
    expect((await franchises.watchRelations('show').first).length, 2);
  });

  test('франшизы для загрузки', () async {
    await library.add(s1, StatusAction.planned);
    expect(await franchises.franchisesToLoad(), [1]);
    expect(
      await franchises.saveParts(FranchiseParts(key: 'show', parts: [s1])),
      isEmpty,
    );
    expect(await franchises.franchisesToLoad(), isEmpty);
    final added = await franchises.saveParts(
      FranchiseParts(key: 'show', parts: [s1, s2]),
    );
    expect(added.map((anime) => anime.id), [2]);
  });

  test('вынести и перенести часть', () async {
    await library.add(s1, StatusAction.planned);
    await library.add(s2, StatusAction.planned);
    await library.add(s3, StatusAction.planned);
    expect((await units()).single, isA<FranchiseUnit>());

    final undoRemove = await franchises.setOverride(3, '');
    var current = await units();
    expect(current.whereType<FranchiseUnit>().single.items, hasLength(2));
    expect(current.whereType<TitleUnit>().single.item.anime.id, 3);
    await undoRemove();
    expect((await units()).single, isA<FranchiseUnit>());

    final key = await franchises.createCustom('Своя');
    await franchises.setOverride(2, key);
    await franchises.setOverride(3, key);
    current = await units();
    final custom = current.whereType<FranchiseUnit>().single;
    expect(custom.name, 'Своя');
    expect(custom.items.map((item) => item.anime.id), [2, 3]);
    expect(current.whereType<TitleUnit>().single.item.anime.id, 1);
  });

  test('название и обложка', () async {
    await library.add(s1, StatusAction.planned);
    await library.add(s2, StatusAction.planned);
    final undoName = await franchises.rename('show', 'Моё название');
    final undoCover = await franchises.setCover('show', 2);
    var unit = (await units()).single as FranchiseUnit;
    expect(unit.name, 'Моё название');
    expect(unit.cover.anime.id, 2);
    await undoCover();
    await undoName();
    unit = (await units()).single as FranchiseUnit;
    expect(unit.name, 'Сезон 1');
    expect(unit.cover.anime.id, 1);
  });

  test('группы', () async {
    final groups = UserGroupsRepository(database);
    final id = await groups.create('Лучшее');
    final undoAdd = await groups.setMember(id, 'f:show', member: true);
    expect((await groups.watchMembers().first)[id], {'f:show'});
    final undoRemove = await groups.setMember(id, 'f:show', member: false);
    expect((await groups.watchMembers().first)[id], isNull);
    await undoRemove();
    expect((await groups.watchMembers().first)[id], {'f:show'});
    await undoAdd();
    expect((await groups.watchMembers().first)[id], isNull);

    await groups.rename(id, 'Самое лучшее');
    final undoDelete = await groups.delete(id);
    expect(await groups.watchGroups().first, isEmpty);
    await undoDelete();
    expect((await groups.watchGroups().first).single.name, 'Самое лучшее');
  });

  group('очередь', () {
    late QueueRepository queues;
    setUp(() => queues = QueueRepository(database, library));

    Future<WatchStatus> status(int id) async =>
        WatchStatus.fromName((await library.watchEntry(id).first)!.status);
    Future<ActiveQueue?> active() async =>
        (await queues.watchActive().first)['show'];

    test('переход к следующей части', () async {
      await library.add(s1, StatusAction.completed);
      await library.add(s2, StatusAction.planned);
      final undoStart = await queues.start('show', [
        QueuePlanItem(anime: s1, inLibrary: true, mode: 'continue', done: true),
        QueuePlanItem(anime: s2, inLibrary: true, mode: 'continue'),
        QueuePlanItem(anime: s3, inLibrary: false, mode: 'continue'),
      ]);
      expect((await active())!.active!.animeId, 2);
      expect(await status(2), WatchStatus.watching);
      expect(await status(3), WatchStatus.planned);

      await library.markRange(2, 1, 12);
      final step = (await queues.onFinished(2))!;
      expect(step.next!.id, 3);
      expect((await active())!.active!.animeId, 3);
      expect(await status(3), WatchStatus.watching);

      await step.undo();
      expect((await active())!.active!.animeId, 2);
      expect(await status(3), WatchStatus.planned);

      expect(await queues.onFinished(1), isNull);

      final undoStop = await queues.stop('show');
      expect(await active(), isNull);
      await undoStop();
      expect(await active(), isNotNull);
      await undoStart();
      expect(await active(), isNull);
      expect(await library.watchEntry(3).first, isNull);
    });

    test('конец очереди', () async {
      await library.add(s1, StatusAction.planned);
      await queues.start('show', [
        QueuePlanItem(anime: s1, inLibrary: true, mode: 'continue'),
      ]);
      await library.markRange(1, 1, 12);
      final step = (await queues.onFinished(1))!;
      expect(step.finished, isTrue);
      expect(await active(), isNull);
    });

    test('пересмотр', () async {
      await library.add(s1, StatusAction.completed);
      await library.add(s2, StatusAction.completed);
      await queues.start('show', [
        QueuePlanItem(anime: s1, inLibrary: true, mode: 'restart'),
        QueuePlanItem(anime: s2, inLibrary: true, mode: 'restart'),
      ]);
      expect(await status(1), WatchStatus.watching);
      expect(await status(2), WatchStatus.completed);
      final progress = (await library.watchProgress().first).values;
      expect(progress.map((p) => p.cycleNumber), contains(2));
    });
  });
}
