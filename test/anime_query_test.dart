import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:kiroku/data/shikimori/anime_query.dart';
import 'package:kiroku/data/shikimori/rate_limiter.dart';
import 'package:kiroku/data/shikimori/shikimori_client.dart';

void main() {
  group('сезоны', () {
    test('текущий сезон и смена года', () {
      final fall = AnimeSeason.of(DateTime(2026, 10, 12));
      expect(fall.code, 'fall_2026');
      expect(fall.label, 'Осень 2026');
      expect(fall.shift(1).code, 'winter_2027');
      expect(fall.shift(-4).code, 'fall_2025');
      expect(AnimeSeason.of(DateTime(2026, 3, 31)).code, 'winter_2026');
      expect(AnimeSeason.of(DateTime(2026, 4, 1)).code, 'spring_2026');
    });

    test('список лет', () {
      final years = SearchYear.options(DateTime(2026, 10, 12));
      expect(years.first, SearchYear.any);
      expect(years[1].code, '2027');
      expect(years.map((year) => year.code), contains('2000'));
      expect(years.last.code, '1917_1979');
    });
  });

  group('каталог Shikimori', () {
    late Map<String, dynamic> sent;
    final client = ShikimoriClient(
      rateLimiter: RateLimiter(interval: Duration.zero),
      httpClient: MockClient((request) async {
        sent = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'data': {
                'animes': <Object>[],
                'genres': [
                  {'id': '10', 'russian': 'Фэнтези'},
                  {'id': '1', 'russian': 'Экшен'},
                  {'id': '2', 'russian': 'Приключения'},
                ],
              },
            }),
          ),
          200,
        );
      }),
    );

    test('сезон без фильтров', () async {
      await client.browseAnimes(const AnimeQuery(season: 'fall_2026'));
      final query = sent['query'] as String;
      expect(query, contains('season: "fall_2026"'));
      expect(query, contains('order: popularity'));
      expect(query, contains('page: 1'));
      expect(query, isNot(contains('search')));
      expect(query, isNot(contains('kind:')));
      expect(query, isNot(contains('genre:')));
      expect(sent['variables'], isEmpty);
    });

    test('поиск с фильтрами', () async {
      await client.browseAnimes(
        const AnimeQuery(
          search: 'фрирен',
          season: '2023',
          kind: SearchKind.special,
          status: SearchStatus.released,
          genre: AnimeGenre(id: 10, name: 'Фэнтези'),
          order: SearchOrder.ranked,
        ),
        page: 2,
      );
      final query = sent['query'] as String;
      expect(query, contains(r'search: $search'));
      expect(query, contains('kind: "special,tv_special"'));
      expect(query, contains('status: "released"'));
      expect(query, contains('genre: "10"'));
      expect(query, contains('season: "2023"'));
      expect(query, contains('order: ranked'));
      expect(query, contains('page: 2'));
      expect(sent['variables'], {'search': 'фрирен'});
    });

    test('жанры по алфавиту', () async {
      final genres = await client.animeGenres();
      expect(genres.map((genre) => genre.name), [
        'Приключения',
        'Фэнтези',
        'Экшен',
      ]);
    });
  });
}
