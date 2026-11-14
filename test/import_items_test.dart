import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kiroku/data/database/app_database.dart';
import 'package:kiroku/data/database/library_repository.dart';
import 'package:kiroku/data/database/watch_status.dart';
import 'package:kiroku/data/import/import_plan.dart';
import 'package:kiroku/data/import/shikimori_plan.dart';
import 'package:kiroku/data/shikimori/anime_info.dart';
import 'package:kiroku/data/shikimori/user_rate.dart';

const _frieren = AnimeInfo(
  id: 52991,
  name: 'Sousou no Frieren',
  russian: 'Фрирен',
  episodes: 28,
  episodesAired: 28,
  releaseStatus: 'released',
);
const _other = AnimeInfo(
  id: 3,
  name: 'Other',
  russian: 'Другой',
  episodes: 12,
  episodesAired: 12,
  releaseStatus: 'released',
);

final _day = DateTime(2025, 3, 4, 12);

void main() {
  late AppDatabase database;
  late LibraryRepository library;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    library = LibraryRepository(database);
  });
  tearDown(() => database.close());

  Future<List<WatchEvent>> events() =>
      database.select(database.watchEvents).get();
  Future<List<WatchCycle>> cycles() =>
      database.select(database.watchCycles).get();
  Future<LibraryEntry?> entry(int animeId) => (database.select(
    database.libraryEntries,
  )..where((row) => row.animeId.equals(animeId))).getSingleOrNull();

  ImportItem dated(AnimeInfo anime, {bool favorite = false}) => ImportItem(
    sourceTitle: anime.title,
    anime: anime,
    status: WatchStatus.watching,
    favorite: favorite,
    viewings: [
      ImportViewing(
        completed: false,
        episodes: [ImportEpisode(1, _day), const ImportEpisode(2)],
      ),
    ],
  );

  test('Shikimori: пересмотры дают завершённые циклы и активный', () async {
    final items = shikimoriItems(const [
      UserRate(
        anime: _frieren,
        status: 'completed',
        episodes: 28,
        rewatches: 1,
      ),
      UserRate(anime: _other, status: 'watching', episodes: 5),
    ]);
    final result = await library.importItems(items, replace: false);
    expect(result.added, 2);

    final frierenEntry = (await entry(52991))!;
    final frierenCycles = (await cycles())
        .where((cycle) => cycle.entryId == frierenEntry.id)
        .toList();
    expect(frierenCycles.map((cycle) => cycle.state), [
      'completed',
      'completed',
    ]);
    final all = await events();
    expect(all.length, 28 * 2 + 5);
    expect(
      all.every((event) => event.source == 'import' && event.bulk),
      isTrue,
    );
  });

  test('даты серий записываются, без даты ставится текущее время', () async {
    await library.importItems([dated(_other)], replace: false);
    final all = await events()
      ..sort((a, b) => a.episode.compareTo(b.episode));
    expect(all[0].watchedAt?.toUtc(), _day.toUtc());
    expect(all[0].markedAt.toUtc(), _day.toUtc());
    expect(all[1].watchedAt, isNull);
    expect(
      DateTime.now().difference(all[1].markedAt).inMinutes.abs() < 5,
      isTrue,
    );
  });

  test('сердечко ставится добавленному тайтлу', () async {
    await library.importItems([dated(_other, favorite: true)], replace: false);
    expect((await entry(3))!.favorite, isTrue);
  });

  test('тайтл, который уже есть, не меняется без замены', () async {
    await library.importItems([dated(_other)], replace: false);
    final before = (await entry(3))!;
    final result = await library.importItems([
      dated(_other, favorite: true).withStatus(WatchStatus.dropped),
    ], replace: false);
    expect((result.added, result.skipped), (0, 1));
    final after = (await entry(3))!;
    expect(after.status, before.status);
    expect(after.favorite, before.favorite);
  });

  test('замена убирает старые серии и считается заменой', () async {
    await library.importItems([dated(_other)], replace: false);
    final result = await library.importItems([
      dated(_other).withEpisodeCount(1),
    ], replace: true);
    expect(result.replaced, 1);
    final live = (await events()).where((e) => e.deletedAt == null).toList();
    expect(live.length, 1);
  });

  test('один номер Shikimori дважды записывается один раз', () async {
    final result = await library.importItems([
      dated(_other),
      dated(_other),
    ], replace: false);
    expect(result.added, 1);
    expect((await events()).length, 2);
  });

  test('удалённая запись возвращается как добавленная', () async {
    await library.importItems([dated(_other)], replace: false);
    final id = (await entry(3))!.id;
    await (database.update(database.libraryEntries)
          ..where((row) => row.id.equals(id)))
        .write(LibraryEntriesCompanion(deletedAt: Value(DateTime.now())));
    final result = await library.importItems([dated(_other)], replace: false);
    expect(result.added, 1);
    expect((await entry(3))!.deletedAt, isNull);
  });

  test('элементы без тайтла пропускаются молча', () async {
    final result = await library.importItems([
      const ImportItem(sourceTitle: 'Неизвестный'),
    ], replace: false);
    expect((result.added, result.replaced, result.skipped), (0, 0, 0));
    expect(await entry(3), isNull);
  });

  test('отмена возвращает базу, как была', () async {
    final result = await library.importItems([
      dated(_other, favorite: true),
    ], replace: false);
    expect(await entry(3), isNotNull);
    await result.undo();
    expect(await entry(3), isNull);
    expect((await events()), isEmpty);
  });
}
