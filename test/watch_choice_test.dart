import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiroku/data/database/app_database.dart';
import 'package:kiroku/data/database/library_repository.dart';
import 'package:kiroku/data/database/status_action.dart';
import 'package:kiroku/data/shikimori/anime_info.dart';
import 'package:kiroku/features/player/watch_choice.dart';

void main() {
  late AppDatabase database;
  late LibraryRepository library;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    library = LibraryRepository(database);
  });

  tearDown(() => database.close());

  Future<LibraryItem> item(
    StatusAction action, {
    int next = 1,
    String status = 'released',
  }) async {
    await library.add(
      AnimeInfo(
        id: 1,
        name: 'Show',
        russian: 'Шоу',
        episodes: 12,
        episodesAired: status == 'released' ? 12 : 8,
        releaseStatus: status,
      ),
      action,
    );
    final row = (await library.watchItems().first).single;
    return LibraryItem(
      entry: row.entry,
      anime: row.anime,
      progress: WatchProgress(watched: next - 1, nextEpisode: next),
    );
  }

  test('следующая серия и озвучка просмотра', () async {
    await library.add(
      const AnimeInfo(id: 1, name: 'Show', russian: 'Шоу', episodes: 12),
      StatusAction.watching,
    );
    await library.setDubbingSeen(1, 'AniDUB');
    final row = (await library.watchItems().first).single;
    final choice = watchChoice(
      LibraryItem(
        entry: row.entry,
        anime: row.anime,
        progress: const WatchProgress(watched: 4, nextEpisode: 5),
      ),
      null,
    );
    expect(choice.episode, 5);
    expect(choice.dubbing, 'AniDUB');
  });

  test('выбранная озвучка важнее просмотренной', () async {
    final watching = await item(StatusAction.watching, next: 3);
    await library.setDubbingSeen(1, 'AniDUB');
    await library.setDubbing(1, 'AniLibria');
    final row = (await library.watchItems().first).single;
    final choice = watchChoice(
      LibraryItem(
        entry: row.entry,
        anime: row.anime,
        progress: watching.progress,
      ),
      null,
    );
    expect(choice.dubbing, 'AniLibria');
  });

  test('просмотренный сезон с первой серии', () async {
    final completed = await item(StatusAction.completed, next: 13);
    expect(watchChoice(completed, null).episode, 1);
  });

  test('догнанный онгоинг на последней вышедшей', () async {
    final ongoing = await item(
      StatusAction.watching,
      next: 9,
      status: 'ongoing',
    );
    expect(watchChoice(ongoing, null).episode, 8);
  });

  test('подпись озвучки на сайте', () {
    expect(siteDubbingLabel('AniDUB'), 'Озвучка AniDUB');
    expect(siteDubbingLabel('Субтитры SubVost'), 'Субтитры SubVost');
  });
}
