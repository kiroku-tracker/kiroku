import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kiroku/data/database/app_database.dart';
import 'package:kiroku/data/database/library_repository.dart';
import 'package:kiroku/data/database/status_action.dart';
import 'package:kiroku/data/database/watch_status.dart';
import 'package:kiroku/data/shikimori/anime_info.dart';

void main() {
  late AppDatabase database;
  late LibraryRepository repository;

  const released = AnimeInfo(
    id: 52991,
    name: 'Sousou no Frieren',
    russian: 'Провожающая в последний путь Фрирен',
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
  const announced = AnimeInfo(
    id: 2,
    name: 'Anons',
    russian: 'Анонс',
    releaseStatus: 'anons',
  );

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = LibraryRepository(database);
  });

  tearDown(() => database.close());

  Future<LibraryItem> single() async {
    final items = await repository.watchItems().first;
    final progress = await repository.watchProgress().first;
    final item = items.single;
    return LibraryItem(
      entry: item.entry,
      anime: item.anime,
      progress: progress[item.entry.id] ?? const WatchProgress(),
    );
  }

  group('доступные статусы', () {
    test('анонс', () {
      expect(StatusAction.availableFor(announced.release), [
        StatusAction.planned,
      ]);
    });

    test('онгоинг', () {
      final actions = StatusAction.availableFor(ongoing.release);
      expect(actions, contains(StatusAction.caughtUp));
      expect(actions, isNot(contains(StatusAction.completed)));
      expect(actions.first, StatusAction.watching);
    });

    test('вышедший сезон', () {
      expect(StatusAction.availableFor(released.release), [
        StatusAction.watching,
        StatusAction.planned,
        StatusAction.completed,
        StatusAction.paused,
        StatusAction.dropped,
      ]);
    });
  });

  test('добавление в планы', () async {
    await repository.add(released, StatusAction.planned);

    final item = await single();
    expect(item.status, WatchStatus.planned);
    expect(item.progress.watched, 0);
    expect(item.anime.title, 'Провожающая в последний путь Фрирен');
  });

  test(
    'добавление как «Просмотрено» отмечает все серии и закрывает просмотр',
    () async {
      final change = await repository.add(released, StatusAction.completed);

      expect(change.markedEpisodes, 28);
      final item = await single();
      expect(item.status, WatchStatus.completed);
      expect(item.progress.watched, 28);
      final cycles = await database.select(database.watchCycles).get();
      expect(cycles.single.state, 'completed');
      final events = await database.select(database.watchEvents).get();
      expect(
        events.every((event) => event.bulk && event.watchedAt == null),
        isTrue,
      );
    },
  );

  test(
    '«Всё вышедшее просмотрено» у онгоинга — «Смотрю» и отметки вышедших',
    () async {
      final change = await repository.add(ongoing, StatusAction.caughtUp);

      expect(change.markedEpisodes, 7);
      final item = await single();
      expect(item.status, WatchStatus.watching);
      expect(item.progress.watched, 7);
    },
  );

  test('отмена добавления', () async {
    final change = await repository.add(released, StatusAction.completed);
    await change.undo();

    expect(await repository.watchItems().first, isEmpty);
    expect(await database.select(database.watchCycles).get(), isEmpty);
    expect(await database.select(database.watchEvents).get(), isEmpty);
  });

  test('повторный просмотр', () async {
    await repository.add(released, StatusAction.completed);

    final change = await repository.applyAction(
      released.id,
      StatusAction.watching,
    );
    expect(change.startedRewatch, isTrue);
    var item = await single();
    expect(item.status, WatchStatus.watching);
    expect(item.progress.cycleNumber, 2);
    expect(item.progress.watched, 0);

    await change.undo();
    item = await single();
    expect(item.status, WatchStatus.completed);
    expect(item.progress.cycleNumber, 1);
    expect(item.progress.watched, 28);
  });

  test('отложено и брошено', () async {
    await repository.add(ongoing, StatusAction.caughtUp);
    await repository.applyAction(ongoing.id, StatusAction.paused);

    final item = await single();
    expect(item.status, WatchStatus.paused);
    expect(item.progress.watched, 7);
  });

  test('без дублей', () async {
    await repository.add(released, StatusAction.watching);
    await repository.add(released, StatusAction.planned);

    expect(await repository.watchItems().first, hasLength(1));
  });

  test('возврат убранного тайтла', () async {
    await repository.add(released, StatusAction.completed);
    final firstId = (await single()).entry.id;

    final removal = await repository.remove(released.id);
    expect(await repository.watchItems().first, isEmpty);
    expect(await repository.watchStatuses().first, isEmpty);

    await removal.undo();
    final restored = await single();
    expect(restored.entry.id, firstId);
    expect(restored.status, WatchStatus.completed);
    expect(restored.progress.watched, 28);

    await repository.remove(released.id);
    await repository.add(released, StatusAction.planned);
    final readded = await single();
    expect(readded.entry.id, firstId);
    expect(readded.status, WatchStatus.planned);
  });

  test('описание сохраняется', () async {
    await repository.saveAnime(
      const AnimeInfo(
        id: 52991,
        name: 'Sousou no Frieren',
        russian: 'Фрирен',
        details: AnimeDetails(
          description: 'Описание',
          genres: ['Приключения', 'Фэнтези'],
        ),
      ),
    );
    await repository.saveAnime(released);

    final anime = await repository.watchAnime(52991).first;
    expect(anime!.description, 'Описание');
    expect(anime.genreList, ['Приключения', 'Фэнтези']);
    expect(anime.episodes, 28);
  });

  group('следующая серия', () {
    const short = AnimeInfo(
      id: 3,
      name: 'Short',
      russian: 'Короткий',
      episodes: 2,
      episodesAired: 2,
      releaseStatus: 'released',
    );

    test('по порядку', () async {
      await repository.add(short, StatusAction.planned);

      final first = await repository.markNextEpisode(short.id);
      expect(first.episode, 1);
      expect(first.finished, isFalse);
      expect((await single()).status, WatchStatus.watching);
      expect(
        (await repository.watchHistory(short.id).first).last.events.keys
            .toSet(),
        {1},
      );

      final second = await repository.markNextEpisode(short.id);
      expect(second.episode, 2);
      expect(second.finished, isTrue);
      final item = await single();
      expect(item.status, WatchStatus.completed);
      expect(item.progress.watched, 2);
      final events = await database.select(database.watchEvents).get();
      expect(events.every((event) => event.watchedAt != null), isTrue);

      await second.undo();
      expect((await single()).status, WatchStatus.watching);
      expect(
        (await repository.watchHistory(short.id).first).last.events.keys
            .toSet(),
        {1},
      );
    });

    test('догнанный онгоинг', () async {
      await repository.add(ongoing, StatusAction.caughtUp);

      final change = await repository.markNextEpisode(ongoing.id);
      expect(change.episode, isNull);
      expect((await single()).progress.watched, 7);
    });

    test('смотреть заново', () async {
      await repository.add(short, StatusAction.completed);
      await repository.applyAction(short.id, StatusAction.watching);
      expect(await repository.watchHistory(short.id).first, hasLength(1));
      expect((await single()).progress.cycleNumber, 2);

      final change = await repository.markNextEpisode(short.id);
      expect(change.episode, 1);
      final item = await single();
      expect(item.progress.cycleNumber, 2);
      expect(item.status, WatchStatus.watching);
    });
  });

  group('серии', () {
    const three = AnimeInfo(
      id: 4,
      name: 'Three',
      russian: 'Три серии',
      episodes: 3,
      episodesAired: 3,
      releaseStatus: 'released',
    );

    Future<CycleHistory> current(int animeId) async =>
        (await repository.watchHistory(animeId).first).last;

    test('отметка серии', () async {
      await repository.add(three, StatusAction.paused);

      final mark = await repository.toggleEpisode(three.id, 2);
      expect(mark.markedEpisodes, 1);
      expect((await single()).status, WatchStatus.watching);
      expect((await current(three.id)).events.keys, [2]);
      expect((await current(three.id)).events[2]!.watchedAt, isNotNull);

      final unmark = await repository.toggleEpisode(three.id, 2);
      expect(unmark.markedEpisodes, 0);
      expect((await current(three.id)).events, isEmpty);

      await unmark.undo();
      expect((await current(three.id)).events.keys, [2]);
    });

    test('все серии отмечены', () async {
      await repository.add(three, StatusAction.watching);
      await repository.markRange(three.id, 1, 2);
      final last = await repository.toggleEpisode(three.id, 3);
      expect(last.finished, isTrue);
      expect((await single()).status, WatchStatus.completed);
      expect((await current(three.id)).isCompleted, isTrue);

      await repository.toggleEpisode(three.id, 1);
      expect((await single()).status, WatchStatus.watching);
      expect((await current(three.id)).isCompleted, isFalse);
    });

    test('диапазон', () async {
      await repository.add(three, StatusAction.watching);
      await repository.toggleEpisode(three.id, 2);
      final range = await repository.markRange(three.id, 1, 3);
      expect(range.markedEpisodes, 2);
      final events = (await current(three.id)).events;
      expect(events[1]!.watchedAt, isNull);
      expect(events[2]!.watchedAt, isNotNull);

      await repository.unmarkRange(three.id, 2, 3);
      expect((await current(three.id)).events.keys, [1]);
    });

    test('серия до эфира', () async {
      await repository.add(ongoing, StatusAction.watching);
      await repository.toggleEpisode(ongoing.id, 9);
      final events = (await current(ongoing.id)).events;
      expect(events[9]!.beforeAired, isTrue);
    });

    test('дата серии', () async {
      await repository.add(three, StatusAction.watching);
      await repository.toggleEpisode(three.id, 1);
      final cycleId = (await current(three.id)).cycle.id;
      final date = DateTime(2026, 3, 15, 21, 40);

      await repository.setEpisodeDate(three.id, cycleId, 1, date);
      expect((await current(three.id)).events[1]!.watchedAt, date);

      final clear = await repository.setEpisodeDate(three.id, cycleId, 1, null);
      expect((await current(three.id)).events[1]!.watchedAt, isNull);
      await clear.undo();
      expect((await current(three.id)).events[1]!.watchedAt, date);
    });

    test('начать заново', () async {
      await repository.add(three, StatusAction.watching);
      await repository.toggleEpisode(three.id, 1);
      await repository.restartViewing(three.id);

      var history = await repository.watchHistory(three.id).first;
      expect(history, hasLength(1));
      expect(history.single.isUnfinished, isTrue);
      expect(history.single.events.keys, [1]);
      var progress = (await single()).progress;
      expect(progress.cycleNumber, 2);
      expect(progress.watched, 0);

      await repository.toggleEpisode(three.id, 2);
      history = await repository.watchHistory(three.id).first;
      expect(history, hasLength(2));
      expect(history.last.events.keys, [2]);
      progress = (await single()).progress;
      expect(progress.cycleNumber, 2);
      expect(progress.watched, 1);
    });

    test('номер просмотра', () async {
      await repository.add(three, StatusAction.completed);
      await repository.applyAction(three.id, StatusAction.watching);
      await repository.toggleEpisode(three.id, 1);
      expect((await single()).progress.cycleNumber, 2);

      final history = await repository.watchHistory(three.id).first;
      await repository.deleteCycle(three.id, history.first.cycle.id);
      expect((await single()).progress.cycleNumber, 1);
    });

    test(
      'удаление просмотра пересчитывает статус, отмена возвращает',
      () async {
        await repository.add(three, StatusAction.completed);
        await repository.applyAction(three.id, StatusAction.watching);
        await repository.toggleEpisode(three.id, 1);
        var history = await repository.watchHistory(three.id).first;
        expect(history, hasLength(2));

        final removal = await repository.deleteCycle(
          three.id,
          history.last.cycle.id,
        );
        history = await repository.watchHistory(three.id).first;
        expect(history, hasLength(1));
        expect((await single()).status, WatchStatus.completed);

        await removal.undo();
        history = await repository.watchHistory(three.id).first;
        expect(history, hasLength(2));
        expect((await single()).status, WatchStatus.watching);

        await repository.deleteCycle(three.id, history.last.cycle.id);
        await repository.deleteCycle(three.id, history.first.cycle.id);
        expect((await single()).status, WatchStatus.planned);
      },
    );

    test('оценка и заметка', () async {
      await repository.add(three, StatusAction.watching);
      await repository.setScore(three.id, 9);
      await repository.setNote(three.id, 'Пересмотреть с друзьями');
      final entry = (await single()).entry;
      expect(entry.score, 9);
      expect(entry.note, 'Пересмотреть с друзьями');
    });
  });

  test('очистка описания', () {
    expect(
      cleanDescription(
        '[character=184947]Фрирен[/character] — эльфийка.\r\n\r\n\r\nКонец',
      ),
      'Фрирен — эльфийка.\n\nКонец',
    );
  });

  test('удаление франшизы', () async {
    await repository.add(released, StatusAction.completed);
    await repository.add(ongoing, StatusAction.watching);
    await repository.toggleEpisode(ongoing.id, 1);

    final change = await repository.removeMany([released.id, ongoing.id]);
    expect(await repository.watchStatuses().first, isEmpty);

    await change.undo();
    final statuses = await repository.watchStatuses().first;
    expect(statuses[released.id], WatchStatus.completed);
    expect(statuses[ongoing.id], WatchStatus.watching);
  });
}
