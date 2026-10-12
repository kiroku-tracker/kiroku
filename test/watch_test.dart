import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:kiroku/data/database/app_database.dart';
import 'package:kiroku/data/database/settings_repository.dart';
import 'package:kiroku/data/watch/watch_links_repository.dart';
import 'package:kiroku/data/watch/watch_sources.dart';
import 'package:kiroku/data/yummy/yummy_client.dart';
import 'package:kiroku/features/autotrack/recognition.dart';

void main() {
  late AppDatabase database;
  late SettingsRepository settings;
  var requests = 0;

  /// Заглушка API YummyAnime.
  YummyClient client({bool broken = false}) => YummyClient(
    httpClient: MockClient((request) async {
      requests++;
      if (broken) return http.Response('', 500);
      final id = request.url.queryParameters['shikimori_ids'];
      final found = id == '38671';
      return http.Response.bytes(
        utf8.encode(
          jsonEncode({
            'response': found
                ? [
                    {'anime_url': 'plamennaya-brigada-pozharnyh'},
                  ]
                : [],
          }),
        ),
        200,
      );
    }),
  );

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    settings = SettingsRepository(database);
    requests = 0;
  });
  tearDown(() => database.close());

  group('YummyAnime', () {
    test(
      'найденный тайтл: страница в выбранном дизайне, адрес запомнен',
      () async {
        final source = YummyAnimeSource(
          client: client(),
          settings: settings,
          host: YummyHost.old,
        );
        final target = await source.resolve(
          shikimoriId: 38671,
          title: 'Пламенная бригада пожарных',
        );
        expect(target.found, isTrue);
        expect(
          target.uri.toString(),
          'https://old.yummyani.me/catalog/item/plamennaya-brigada-pozharnyh',
        );
        await source.resolve(shikimoriId: 38671, title: '');
        expect(requests, 1);
        expect(
          (await settings.readAll())['yummy.plamennaya-brigada-pozharnyh'],
          '38671',
        );
      },
    );

    test(
      'тайтла нет — поиск по названию, «не найдено» не запоминается',
      () async {
        final ru = YummyAnimeSource(
          client: client(),
          settings: settings,
          host: YummyHost.ru,
        );
        final target = await ru.resolve(shikimoriId: 1, title: 'Фрирен');
        expect(target.found, isFalse);
        expect(target.uri.host, 'ru.yummyani.me');
        expect(target.uri.path, '/catalog');
        expect(target.uri.queryParameters['q'], 'Фрирен');
        await ru.resolve(shikimoriId: 1, title: 'Фрирен');
        expect(requests, 2);

        final old = YummyAnimeSource(
          client: client(),
          settings: settings,
          host: YummyHost.old,
        );
        final oldTarget = await old.resolve(shikimoriId: 1, title: 'Фрирен');
        expect(oldTarget.uri.path, '/search');
        expect(oldTarget.uri.queryParameters['word'], 'Фрирен');
      },
    );

    test('сайт не отвечает', () async {
      final source = YummyAnimeSource(
        client: client(broken: true),
        settings: settings,
        host: YummyHost.ru,
      );
      final target = await source.resolve(shikimoriId: 38671, title: 'Т');
      expect(target.found, isFalse);
    });

    test('дизайн сайта', () {
      final session = MediaSession(
        app: 'vivaldi.exe',
        title: 'Тайтл — смотреть аниме онлайн на YummyAnime',
        status: 4,
        position: 0,
        duration: 1440,
        documents: [
          (
            name: '',
            url: 'https://old.yummyani.me/catalog/item/plamennaya-brigada-pozharnyh',
          ),
        ],
      );
      final result = recognizeYummy(session)!;
      expect(result.host, 'old.yummyani.me');
      expect(YummyHost.ofDomain(result.host!), YummyHost.old);
    });
  });

  test('свои ссылки', () async {
    final links = WatchLinksRepository(database);
    await links.add(1, 'Озвучка', 'https://example.com/a');
    await links.add(1, 'Субтитры', 'https://example.com/b');
    var list = await links.watchLinks(1).first;
    expect(list.map((link) => link.label), ['Озвучка', 'Субтитры']);

    await links.edit(list.first.id, 'AniLibria', 'https://example.com/c');
    list = await links.watchLinks(1).first;
    expect(list.first.label, 'AniLibria');

    final undo = await links.remove(list.first.id);
    expect((await links.watchLinks(1).first).single.label, 'Субтитры');
    await undo();
    expect(await links.watchLinks(1).first, hasLength(2));
    expect(await links.watchLinks(2).first, isEmpty);
  });
}
