import 'package:flutter_test/flutter_test.dart';

import 'package:kiroku/data/database/app_database.dart';
import 'package:kiroku/data/database/settings_repository.dart';
import 'package:kiroku/data/shikimori/anime_info.dart';
import 'package:kiroku/data/watch/site_episodes_repository.dart';
import 'package:kiroku/features/notifications/release_events.dart';

typedef _State = ({String status, int aired, DateTime? nextAt});

_State _s(String status, int aired, [DateTime? nextAt]) =>
    (status: status, aired: aired, nextAt: nextAt);

AnimeInfo _info(_State state) => AnimeInfo(
  id: 1,
  name: 'Show',
  russian: 'Тайтл',
  episodes: 12,
  episodesAired: state.aired,
  releaseStatus: state.status,
  nextEpisodeAt: state.nextAt,
);

Anime _row(AnimeInfo info) => Anime(
  id: info.id,
  name: info.name,
  russian: info.russian,
  episodes: info.episodes,
  episodesAired: info.episodesAired,
  releaseStatus: info.releaseStatus,
  nextEpisodeAt: info.nextEpisodeAt,
  updatedAt: DateTime(2026),
);

/// Уведомления за проверки по очереди: «заголовок / текст».
List<String> _delivered(
  int checks,
  List<ReleaseEvent> Function(int check) eventsAt,
) {
  final shown = <String>[];
  var last = <int, ({String title, String body})>{};
  for (var check = 1; check < checks; check++) {
    for (final event in withoutRepeats(eventsAt(check), last)) {
      final text = notificationText(event);
      last = {...last, event.animeId: text};
      shown.add('${text.title} / ${text.body}');
    }
  }
  return shown;
}

/// Уведомления о сериях по данным Shikimori.
List<String> _air(List<_State> states, EpisodeAlertMode mode) => _delivered(
  states.length,
  (check) => eventsForMode(
    releaseEvents(_row(_info(states[check - 1])), _info(states[check])),
    mode,
  ),
);

/// Уведомления о сериях на YummyAnime.
List<String> _site(List<int> counts, EpisodeAlertMode mode) {
  SiteEpisodesInfo info(int count) =>
      SiteEpisodesInfo(byDubbing: {'AniDUB': count}, checkedAt: DateTime(2026));
  return _delivered(
    counts.length,
    (check) => eventsForMode(
      siteEvents(
        animeId: 1,
        title: 'Тайтл',
        before: info(counts[check - 1]),
        after: info(counts[check]),
        dubbing: 'AniDUB',
        total: 12,
      ),
      mode,
    ),
  );
}

void main() {
  final monday = DateTime.utc(2026, 10, 19, 15);
  final nextMonday = DateTime.utc(2026, 10, 26, 15);

  group('о каждой серии', () {
    test('по уведомлению на серию, конец сезона вместе с последней', () {
      expect(
        _air([
          _s('ongoing', 10),
          _s('ongoing', 11),
          _s('ongoing', 12),
          _s('released', 12),
        ], EpisodeAlertMode.episodes),
        [
          'Вышла 11-я серия / «Тайтл»',
          'Вышла 12-я серия / «Тайтл» · сезон завершён',
        ],
      );
    });

    test('скачок числа серий на Shikimori не повторяет уведомление', () {
      expect(
        _air([
          _s('ongoing', 7),
          _s('ongoing', 8),
          _s('ongoing', 7),
          _s('ongoing', 8),
        ], EpisodeAlertMode.episodes),
        ['Вышла 8-я серия / «Тайтл»'],
      );
    });

    test('перенос серии один раз, после последней серии переносов нет', () {
      expect(
        _air([
          _s('ongoing', 7, monday),
          _s('ongoing', 7, nextMonday),
          _s('ongoing', 7, nextMonday),
        ], EpisodeAlertMode.episodes),
        hasLength(1),
      );
      expect(
        _air([
          _s('ongoing', 12, monday),
          _s('ongoing', 12, nextMonday),
        ], EpisodeAlertMode.episodes),
        isEmpty,
      );
    });

    test('YummyAnime: пропавшая и вернувшаяся серия не повторяется', () {
      expect(_site([4, 5, 4, 5, 6], EpisodeAlertMode.episodes), [
        '5-я серия на YummyAnime / «Тайтл» · AniDUB',
        '6-я серия на YummyAnime / «Тайтл» · AniDUB',
      ]);
    });
  });

  group('о премьере', () {
    test('одно уведомление за весь сезон', () {
      expect(
        _air([
          _s('anons', 0),
          _s('ongoing', 1),
          _s('ongoing', 2),
          _s('released', 12),
        ], EpisodeAlertMode.premiere),
        ['Премьера: вышла 1-я серия / «Тайтл»'],
      );
      expect(_site([0, 1, 2, 3], EpisodeAlertMode.premiere), hasLength(1));
    });
  });

  group('когда выйдут все серии', () {
    test('одно уведомление, даже если статус сменился позже', () {
      expect(
        _air([
          _s('ongoing', 10),
          _s('ongoing', 11),
          _s('ongoing', 12),
          _s('released', 12),
        ], EpisodeAlertMode.finished),
        ['Вышли все серии / «Тайтл» · 12 серий'],
      );
    });

    test('сезон вышел сразу целиком', () {
      expect(
        _air([
          _s('ongoing', 10),
          _s('released', 12),
        ], EpisodeAlertMode.finished),
        hasLength(1),
      );
    });

    test('YummyAnime: одно уведомление на последней серии', () {
      expect(_site([10, 11, 12, 12], EpisodeAlertMode.finished), [
        'Все серии на YummyAnime / «Тайтл» · AniDUB',
      ]);
    });
  });

  test('не уведомлять: ни одного уведомления', () {
    expect(
      _air([
        _s('anons', 0),
        _s('ongoing', 1),
        _s('released', 12),
      ], EpisodeAlertMode.off),
      isEmpty,
    );
  });
}
