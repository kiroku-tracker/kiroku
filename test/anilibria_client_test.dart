import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:kiroku/data/anilibria/anilibria_client.dart';

Map<String, dynamic> _release(int id, int? shikimori, String name) => {
  'id': id,
  'name': {'main': name},
  'shikimori': shikimori == null ? null : {'id': shikimori},
  'episodes_total': 12,
};

http.Response _json(Object body, [int status = 200]) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

Map<String, dynamic> _page(
  List<Map<String, dynamic>> data,
  int page,
  int pages,
) => {
  'data': data,
  'meta': {
    'pagination': {'current_page': page, 'total_pages': pages},
  },
};

void main() {
  test('requestCode отправляет device_id и разбирает код', () async {
    late http.Request seen;
    final client = AniLibriaClient(
      httpClient: MockClient((request) async {
        seen = request;
        return _json({
          'otp': {'code': '058701', 'expired_at': '2026-11-14T10:00:00+00:00'},
          'remaining_time': 120,
        });
      }),
    );
    final otp = await client.requestCode('dev-1');
    expect(
      seen.url.toString(),
      'https://anilibria.top/api/v1/accounts/otp/get',
    );
    expect(jsonDecode(seen.body), {'device_id': 'dev-1'});
    expect(otp.code, '058701');
    expect(otp.lifetime, const Duration(seconds: 120));
  });

  test('requestCode без remaining_time даёт две минуты', () async {
    final client = AniLibriaClient(
      httpClient: MockClient(
        (request) async => _json({
          'otp': {'code': '058701'},
        }),
      ),
    );
    expect(
      (await client.requestCode('dev-1')).lifetime,
      const Duration(minutes: 2),
    );
  });

  test('страницы идут по счёту клиента, а не по ответу сервера', () async {
    var requests = 0;
    final client = AniLibriaClient(
      httpClient: MockClient((request) async {
        requests++;
        return _json(
          _page([_release(requests, 50 + requests, 'Любимое')], 1, 3),
        );
      }),
    );
    final favorites = await client.favorites('tok');
    expect(requests, 3);
    expect(favorites.length, 3);
  });

  test('пустая страница останавливает загрузку', () async {
    var requests = 0;
    final client = AniLibriaClient(
      httpClient: MockClient((request) async {
        requests++;
        final page = int.parse(request.url.queryParameters['page']!);
        return _json(
          _page(page == 1 ? [_release(1, 51, 'Любимое')] : [], page, 99),
        );
      }),
    );
    await client.favorites('tok');
    expect(requests, 2);
  });

  test('числа-строки в ответе не ломают загрузку', () async {
    final client = AniLibriaClient(
      httpClient: MockClient((request) async {
        final page = int.parse(request.url.queryParameters['page']!);
        return _json({
          'data': [
            {
              'id': '${page + 6}',
              'name': {'main': 'Любимое'},
              'shikimori': {'id': '${page + 50}'},
              'episodes_total': '12',
            },
          ],
          'meta': {
            'pagination': {'current_page': '$page', 'total_pages': '2'},
          },
        });
      }),
    );
    final favorites = await client.favorites('tok');
    expect(favorites.map((f) => f.releaseId), [7, 8]);
    expect(favorites.map((f) => f.shikimoriId), [51, 52]);
    expect(favorites.first.episodesTotal, 12);
  });

  test(
    'login: токен, пока код не принят null, сеть падает исключением',
    () async {
      var step = 0;
      final client = AniLibriaClient(
        httpClient: MockClient((request) async {
          step++;
          if (step == 1) return _json({'message': 'not accepted'}, 422);
          if (step == 2) return _json({'token': 'abc'});
          throw http.ClientException('offline');
        }),
      );
      expect(await client.login('058701', 'dev-1'), isNull);
      expect(await client.login('058701', 'dev-1'), 'abc');
      expect(
        () => client.login('058701', 'dev-1'),
        throwsA(isA<AniLibriaException>()),
      );
    },
  );

  test('profileName берёт ник, а без него логин', () async {
    final withNick = AniLibriaClient(
      httpClient: MockClient(
        (request) async => _json({'nickname': 'Вася', 'login': 'vasya'}),
      ),
    );
    expect(await withNick.profileName('t'), 'Вася');
    final noNick = AniLibriaClient(
      httpClient: MockClient((request) async => _json({'login': 'vasya'})),
    );
    expect(await noNick.profileName('t'), 'vasya');
  });

  test('collections проходит 5 типов и все страницы', () async {
    final seen = <String>[];
    final client = AniLibriaClient(
      httpClient: MockClient((request) async {
        seen.add(request.url.query);
        expect(request.headers['Authorization'], 'Bearer tok');
        final type = request.url.queryParameters['type_of_collection'];
        final page = int.parse(request.url.queryParameters['page'] ?? '1');
        if (type == 'WATCHED') {
          return _json(
            _page(
              [_release(page * 10, 100 + page, 'Просмотрено $page')],
              page,
              2,
            ),
          );
        }
        if (type == 'WATCHING') {
          return _json(_page([_release(1, null, 'Без номера')], 1, 1));
        }
        return _json(_page([], 1, 1));
      }),
    );
    final items = await client.collections('tok');
    expect(items.where((i) => i.collection == 'WATCHED').length, 2);
    expect(
      items.where((i) => i.collection == 'WATCHED').map((i) => i.shikimoriId),
      [101, 102],
    );
    final watching = items.singleWhere((i) => i.collection == 'WATCHING');
    expect(watching.shikimoriId, isNull);
    expect(watching.title, 'Без номера');
    expect(watching.episodesTotal, 12);
    expect(seen.length, 5 + 1);
  });

  test('favorites проходит страницы', () async {
    final client = AniLibriaClient(
      httpClient: MockClient((request) async {
        final page = int.parse(request.url.queryParameters['page'] ?? '1');
        return _json(
          _page([_release(page, 50 + page, 'Любимое $page')], page, 2),
        );
      }),
    );
    final favorites = await client.favorites('tok');
    expect(favorites.map((f) => f.shikimoriId), [51, 52]);
  });

  test('history разбирает серии, дробные номера и даты', () async {
    final client = AniLibriaClient(
      httpClient: MockClient(
        (request) async => _json(
          _page(
            [
              {
                'is_watched': true,
                'time': 100.5,
                'updated_at': '2025-06-23T14:00:00+00:00',
                'release_episode': {
                  'ordinal': 5.5,
                  'release': _release(7, 70, 'Спешл'),
                },
              },
              {
                'is_watched': false,
                'updated_at': '2025-06-24T14:00:00+00:00',
                'release_episode': {
                  'ordinal': 3,
                  'release': _release(7, 70, 'Спешл'),
                },
              },
            ],
            1,
            1,
          ),
        ),
      ),
    );
    final views = await client.history('tok');
    expect(views.length, 2);
    expect(views[0].ordinal, 5.5);
    expect(views[0].watched, isTrue);
    expect(views[0].shikimoriId, 70);
    expect(views[0].updatedAt.toUtc(), DateTime.utc(2025, 6, 23, 14));
    expect(views[1].watched, isFalse);
  });

  test('401 даёт исключение с unauthorized', () async {
    final client = AniLibriaClient(
      httpClient: MockClient((request) async => _json({'message': 'x'}, 401)),
    );
    await expectLater(
      client.favorites('bad'),
      throwsA(
        isA<AniLibriaException>().having(
          (e) => e.unauthorized,
          'unauthorized',
          isTrue,
        ),
      ),
    );
  });

  test('обрыв на второй странице не возвращает неполный список', () async {
    final client = AniLibriaClient(
      httpClient: MockClient((request) async {
        final page = int.parse(request.url.queryParameters['page'] ?? '1');
        if (page == 2) throw http.ClientException('offline');
        return _json(_page([_release(1, 51, 'Любимое')], 1, 2));
      }),
    );
    await expectLater(
      client.favorites('tok'),
      throwsA(isA<AniLibriaException>()),
    );
  });
}
