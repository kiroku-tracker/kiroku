import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:kiroku/data/shikimori/rate_limiter.dart';
import 'package:kiroku/data/shikimori/shikimori_client.dart';

Map<String, dynamic> _anime(String id, String russian, int popularity) => {
  'id': id,
  'name': 'Name $id',
  'russian': russian,
  'kind': 'tv',
  'score': 8.6,
  'episodes': 12,
  'episodesAired': 7,
  'status': 'ongoing',
  'nextEpisodeAt': '2026-10-17T18:30:00+03:00',
  'airedOn': {'year': 2026, 'month': 7, 'day': null},
  'poster': {'mainUrl': 'https://shikimori.io/poster/$id.jpg'},
  'statusesStats': [
    {'status': 'watching', 'count': popularity},
  ],
};

void main() {
  test('поиск', () async {
    late http.Request sentRequest;
    final client = ShikimoriClient(
      rateLimiter: RateLimiter(interval: Duration.zero),
      httpClient: MockClient((request) async {
        sentRequest = request;
        return http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'data': {
                'animes': [
                  _anime('1', 'Менее популярное', 10),
                  _anime('2', 'Популярное', 500),
                ],
              },
            }),
          ),
          200,
        );
      }),
    );

    final results = await client.searchAnimes('фрирен');

    expect(sentRequest.headers['User-Agent'], 'Kiroku');
    expect(jsonDecode(sentRequest.body)['variables']['search'], 'фрирен');
    expect(results.map((anime) => anime.id), [2, 1]);
    final first = results.first;
    expect(first.title, 'Популярное');
    expect(first.episodesAired, 7);
    expect(first.releaseStatus, 'ongoing');
    expect(first.airedOn, '2026-07');
    expect(first.year, 2026);
    expect(first.nextEpisodeAt, DateTime.parse('2026-10-17T15:30:00Z'));
  });

  test('ошибка GraphQL', () async {
    final client = ShikimoriClient(
      rateLimiter: RateLimiter(interval: Duration.zero),
      httpClient: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'errors': [
              {'message': 'bad query'},
            ],
          }),
          200,
        ),
      ),
    );

    expect(client.searchAnimes('x'), throwsA(isA<ShikimoriException>()));
  });

  test('интервал запросов', () async {
    final limiter = RateLimiter(interval: const Duration(milliseconds: 100));
    final starts = <DateTime>[];
    await Future.wait([
      for (var i = 0; i < 3; i++)
        limiter.run(() async => starts.add(DateTime.now())),
    ]);
    expect(
      starts[2].difference(starts[0]).inMilliseconds,
      greaterThanOrEqualTo(190),
    );
  });
}
