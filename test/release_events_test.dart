import 'package:flutter_test/flutter_test.dart';

import 'package:kiroku/data/database/app_database.dart';
import 'package:kiroku/data/shikimori/anime_info.dart';
import 'package:kiroku/features/notifications/release_events.dart';

Anime _before({
  String status = 'ongoing',
  int episodes = 12,
  int aired = 7,
  DateTime? nextAt,
}) => Anime(
  id: 1,
  name: 'Show',
  russian: 'Тайтл',
  episodes: episodes,
  episodesAired: aired,
  releaseStatus: status,
  nextEpisodeAt: nextAt,
  updatedAt: DateTime(2026),
);

AnimeInfo _after({
  String status = 'ongoing',
  int episodes = 12,
  int aired = 7,
  DateTime? nextAt,
}) => AnimeInfo(
  id: 1,
  name: 'Show',
  russian: 'Тайтл',
  episodes: episodes,
  episodesAired: aired,
  releaseStatus: status,
  nextEpisodeAt: nextAt,
);

void main() {
  test('вышла новая серия', () {
    final events = releaseEvents(_before(), _after(aired: 8));
    final event = events.single as NewEpisodes;
    expect((event.from, event.to, event.premiere), (8, 8, false));
    expect(notificationText(event).title, 'Вышла 8-я серия');
    expect(notificationText(event).body, '«Тайтл»');
  });

  test('несколько серий', () {
    final event =
        releaseEvents(
              _before(aired: 9),
              _after(status: 'released', aired: 0),
            ).single
            as NewEpisodes;
    expect((event.from, event.to, event.finished), (10, 12, true));
    expect(notificationText(event).title, 'Вышли серии 10–12');
    expect(notificationText(event).body, '«Тайтл» · сезон завершён');
  });

  test('премьера анонса', () {
    final event =
        releaseEvents(
              _before(status: 'anons', aired: 0),
              _after(aired: 1),
            ).single
            as NewEpisodes;
    expect(event.premiere, isTrue);
    expect(notificationText(event).title, 'Премьера: вышла 1-я серия');
  });

  test('конец сезона', () {
    final event =
        releaseEvents(
              _before(aired: 12),
              _after(status: 'released', aired: 0),
            ).single
            as SeasonFinished;
    expect(notificationText(event).body, '«Тайтл»: вышли все 12 серий');
  });

  test('перенос серии', () {
    final at = DateTime.utc(2026, 10, 18, 12);
    expect(
      releaseEvents(
        _before(nextAt: at),
        _after(nextAt: at.add(const Duration(hours: 3))),
      ),
      isEmpty,
    );
    final event =
        releaseEvents(
              _before(nextAt: at),
              _after(nextAt: at.add(const Duration(days: 7))),
            ).single
            as EpisodeRescheduled;
    expect(event.episode, 8);
    expect(notificationText(event).title, 'Серия 8 перенесена');
  });

  test('вышедший тайтл', () {
    expect(
      releaseEvents(
        _before(status: 'released', aired: 0),
        _after(status: 'released', episodes: 13, aired: 0),
      ),
      isEmpty,
    );
  });

  test('сводка', () {
    final events = [
      for (var i = 0; i < 5; i++)
        NewEpisodes(animeId: i, title: 'Т$i', from: 2, to: 2),
    ];
    final text = summaryText(events);
    expect(text.title, 'Новое у 5 тайтлов');
    expect(text.body, '«Т0», «Т1», «Т2» и ещё 2');
  });
}
