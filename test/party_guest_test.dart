import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kiroku/data/database/app_database.dart';
import 'package:kiroku/data/providers.dart';
import 'package:kiroku/features/party/party_controller.dart';
import 'package:kiroku/features/party/party_server.dart';
import 'package:kiroku/features/player/player_session.dart';

class _Sessions extends PlayerSessionNotifier {
  final opened = <({Uri uri, int? episode})>[];

  @override
  void open(
    Uri uri, {
    required String title,
    int? animeId,
    int? episode,
    String? dubbing,
    String? player,
  }) => opened.add((uri: uri, episode: episode));
}

void main() {
  test('гостю серия комнаты не открывается сама', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final server = await PartyServer.start(0);
    addTearDown(server.close);
    final host = await WebSocket.connect('ws://127.0.0.1:${server.port}/');
    host.listen((_) {});
    addTearDown(host.close);
    final sessions = _Sessions();
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(database),
        playerSessionProvider.overrideWith(() => sessions),
      ],
    );
    addTearDown(container.dispose);

    final party = container.read(partyProvider.notifier);
    await party.join('127.0.0.1:${server.port}');
    expect(container.read(partyProvider).role, PartyRole.guest);

    const uri = 'https://ru.yummyani.me/catalog/item/x';
    host.add(
      jsonEncode({
        't': 'open',
        'target': {'uri': uri, 'title': 'Тайтл', 'episode': 3},
      }),
    );
    for (var i = 0; i < 100; i++) {
      if (container.read(partyProvider).target != null) break;
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
    final target = container.read(partyProvider).target;
    expect(target?.title, 'Тайтл');
    expect(target?.episode, 3);
    expect(sessions.opened, isEmpty);

    party.watch();
    expect(sessions.opened.single, (uri: Uri.parse(uri), episode: 3));
  });

  test('создатель закрыл комнату', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final server = await PartyServer.start(0);
    final host = await WebSocket.connect('ws://127.0.0.1:${server.port}/');
    host.listen((_) {});
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(database)],
    );
    addTearDown(container.dispose);

    await container
        .read(partyProvider.notifier)
        .join('127.0.0.1:${server.port}');
    expect(container.read(partyProvider).role, PartyRole.guest);
    await server.close();
    await host.close();
    await _until(() => !container.read(partyProvider).active);
    expect(container.read(partyProvider).error, 'Создатель закрыл комнату');
  });

  test('после обрыва связи Kiroku возвращается в комнату', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    var connections = 0;
    server.listen((request) async {
      final socket = await WebSocketTransformer.upgrade(request);
      connections++;
      socket.add(jsonEncode({'t': 'welcome', 'id': connections}));
      socket.listen((_) {});
      if (connections == 1) {
        await Future<void>.delayed(const Duration(milliseconds: 300));
        await socket.close();
      }
    });
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(database)],
    );
    addTearDown(container.dispose);

    await container
        .read(partyProvider.notifier)
        .join('127.0.0.1:${server.port}');
    await _until(() => container.read(partyProvider).reconnecting);
    await _until(
      () => connections == 2 && !container.read(partyProvider).reconnecting,
    );
    expect(container.read(partyProvider).role, PartyRole.guest);
  });
}

/// Ждёт условия до 10 секунд.
Future<void> _until(bool Function() done) async {
  for (var i = 0; i < 500 && !done(); i++) {
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
  expect(done(), isTrue);
}
