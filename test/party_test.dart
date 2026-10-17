import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:kiroku/data/database/settings_repository.dart';
import 'package:kiroku/features/party/party_address.dart';
import 'package:kiroku/features/party/party_server.dart';
import 'package:kiroku/features/party/party_sync.dart';

PartyMember _member(
  int id, {
  double position = 0,
  bool ready = true,
  bool watching = true,
  int? episode = 3,
}) => PartyMember(id: id)
  ..name = 'Участник $id'
  ..position = position
  ..ready = ready
  ..watching = watching
  ..episode = episode
  ..playing = true;

/// Участник комнаты для проверки: сообщения от сервера по типам.
class _Client {
  _Client(this.socket) {
    socket.listen((data) {
      final message = jsonDecode('$data') as Map;
      messages.add(message);
      _changes.add(null);
    });
  }

  final WebSocket socket;
  final messages = <Map<dynamic, dynamic>>[];
  final _changes = StreamController<void>.broadcast();

  static Future<_Client> connect(int port) async =>
      _Client(await WebSocket.connect('ws://127.0.0.1:$port/'));

  void send(Map<String, Object?> message) => socket.add(jsonEncode(message));

  Future<Map<dynamic, dynamic>> next(String type, {bool? on}) async {
    bool match(Map<dynamic, dynamic> message) =>
        message['t'] == type && (on == null || message['on'] == on);
    final found = messages.where(match).firstOrNull;
    if (found != null) {
      messages.remove(found);
      return found;
    }
    await _changes.stream
        .firstWhere((_) => messages.any(match))
        .timeout(const Duration(seconds: 5));
    return next(type, on: on);
  }
}

void main() {
  group('план комнаты', () {
    test('пауза у всех', () {
      final plan = partyPlan(
        playing: false,
        episode: 3,
        members: [_member(1), _member(2)],
      );
      expect(plan.play, {1: false, 2: false});
      expect(plan.waitingFor, isNull);
    });

    test('ждём того, кто грузится или смотрит рекламу', () {
      final loading = _member(2, ready: false);
      final plan = partyPlan(
        playing: true,
        episode: 3,
        members: [_member(1, position: 40), loading],
      );
      expect(plan.play, {1: false, 2: true});
      expect(plan.waitingFor, loading);
    });

    test('ушедший вперёд ждёт отстающего', () {
      final ahead = _member(1, position: 50);
      final behind = _member(2, position: 47);
      final members = [ahead, behind];
      var plan = partyPlan(playing: true, episode: 3, members: members);
      expect(plan.play, {1: false, 2: true});
      expect(plan.waitingFor, behind);

      behind.position = 49;
      plan = partyPlan(playing: true, episode: 3, members: members);
      expect(plan.play[1], isFalse);

      behind.position = 49.8;
      plan = partyPlan(playing: true, episode: 3, members: members);
      expect(plan.play, {1: true, 2: true});
      expect(plan.waitingFor, isNull);
    });

    test('не смотрящих не ждём', () {
      final plan = partyPlan(
        playing: true,
        episode: 3,
        members: [_member(1), _member(2, ready: false, watching: false)],
      );
      expect(plan.play, {1: true});
    });

    test('другая серия считается загрузкой', () {
      final plan = partyPlan(
        playing: true,
        episode: 3,
        members: [_member(1), _member(2, episode: 2)],
      );
      expect(plan.play, {1: false, 2: true});
    });
  });

  test('новый участник переносится на позицию комнаты', () {
    final first = _member(1, position: 100);
    final late = _member(2, position: 601);
    expect(partyAlign(first, [first]), isNull);
    expect(partyAlign(late, [first, late]), 100);
    expect(partyAlign(late, [first, late]), isNull);
    late.episode = 4;
    first.episode = 4;
    first.alignedEpisode = 4;
    expect(partyAlign(late, [first, late]), 100);
  });

  test('адрес комнаты', () {
    expect(parsePartyAddress('26.1.2.3'), (host: '26.1.2.3', port: partyPort));
    expect(parsePartyAddress(' 10.0.0.5:5000 '), (
      host: '10.0.0.5',
      port: 5000,
    ));
    expect(parsePartyAddress('10.0.0.5:99999'), isNull);
    expect(parsePartyAddress(''), isNull);
  });

  test('комната: ведущий, серия, общая пауза и ожидание', () async {
    final server = await PartyServer.start(0);
    addTearDown(server.close);
    final host = await _Client.connect(server.port);
    final welcome = await host.next('welcome');
    expect(welcome['owner'], isTrue);

    final guest = await _Client.connect(server.port);
    expect((await guest.next('welcome'))['owner'], isFalse);
    host.send({'t': 'hello', 'name': 'RLTEX', 'uid': 'u-host'});
    guest.send({'t': 'hello', 'name': 'Вася', 'uid': 'u-guest'});
    final members = (await guest.next('room'))['members'] as List;
    expect(
      {for (final member in members) member['uid']: member['name']},
      anyOf(
        {'u-host': 'RLTEX', 'u-guest': 'Вася'},
        {'u-host': 'RLTEX', '': 'Гость'},
        {'': 'Гость', 'u-guest': 'Вася'},
      ),
    );

    const target = {
      'uri': 'https://ru.yummyani.me/catalog/item/x',
      'episode': 3,
    };
    host.send({'t': 'open', 'target': target});
    expect((await guest.next('open'))['target'], target);

    guest.send({
      't': 'open',
      'target': {'uri': 'other'},
    });

    void state(_Client client, double position, {bool playing = false}) =>
        client.send({
          't': 'state',
          'watching': true,
          'episode': 3,
          'position': position,
          'playing': playing,
          'ready': true,
        });

    state(host, 0);
    state(guest, 0);
    guest.send({'t': 'event', 'type': 'play', 'time': 0});
    await host.next('play', on: true);
    await guest.next('play', on: true);

    state(host, 20, playing: true);
    state(guest, 15, playing: true);
    await host.next('play', on: false);
    var room = await host.next('room');
    while (room['waiting'] == null) {
      room = await host.next('room');
    }
    expect(room['waiting'], 'Вася');

    host.send({'t': 'event', 'type': 'pause', 'time': 20});
    await guest.next('play', on: false);

    await host.socket.close();
    await guest.socket.close();
  });

  test('код комнаты', () {
    final code = partyCode('26.162.92.133')!;
    expect(code, matches(RegExp(r'^[0-9A-Z]{4}-[0-9A-Z]{3}$')));
    expect(parsePartyCode(code), (host: '26.162.92.133', port: partyPort));
    expect(parsePartyCode(code.toLowerCase().replaceAll('-', ' ')), (
      host: '26.162.92.133',
      port: partyPort,
    ));
    final withPort = partyCode('10.0.0.5:5000')!;
    expect(withPort.length, 11);
    expect(parsePartyCode(withPort), (host: '10.0.0.5', port: 5000));
    var rejected = 0;
    for (final letter in '0123456789ABCDEFGHJKMNPQRSTVWXYZ'.split('')) {
      if (letter == code[7]) continue;
      final typo = '${code.substring(0, 7)}$letter';
      if (parsePartyCode(typo) == null) rejected++;
    }
    expect(rejected, greaterThan(20));
    expect(partyDisplayCode('26.162.92.133'), code);
    expect(partyDisplayCode(code), code);
    expect(partyCode('myhost'), isNull);
  });

  test('права гостя: пауза, перемотка и серия', () async {
    var rights = <PartyRight>{};
    final server = await PartyServer.start(0, rightsOf: (_) => rights);
    addTearDown(server.close);
    final host = await _Client.connect(server.port);
    await host.next('welcome');
    final guest = await _Client.connect(server.port);
    await guest.next('welcome');
    host.send({'t': 'hello', 'name': 'RLTEX', 'uid': 'u-host'});
    guest.send({'t': 'hello', 'name': 'Вася', 'uid': 'u-guest'});
    const target = {
      'uri': 'https://ru.yummyani.me/catalog/item/x',
      'episode': 3,
    };
    host.send({'t': 'open', 'target': target});
    await host.next('open');
    await guest.next('open');
    for (final client in [host, guest]) {
      client.send({
        't': 'state',
        'watching': true,
        'episode': 3,
        'position': 100,
        'playing': true,
        'ready': true,
      });
    }

    guest.send({'t': 'event', 'type': 'pause', 'time': 100});
    expect((await guest.next('denied'))['right'], 'pause');
    guest.send({'t': 'event', 'type': 'seek', 'time': 300});
    expect((await guest.next('denied'))['right'], 'seek');
    expect((await guest.next('seek'))['time'], 100);
    guest.send({
      't': 'open',
      'target': {...target, 'episode': 4},
    });
    expect((await guest.next('denied'))['right'], 'episode');
    expect((await guest.next('open'))['target'], target);

    rights = {PartyRight.episode};
    guest.send({
      't': 'open',
      'target': {...target, 'episode': 4},
    });
    expect(((await host.next('open'))['target'] as Map)['episode'], 4);
    var room = await host.next('room');
    while (((room['members'] as List).last as Map)['rights'].toString() !=
        '[episode]') {
      room = await host.next('room');
    }

    await host.socket.close();
    await guest.socket.close();
  });

  test('вернувшийся участник заменяет старое соединение', () async {
    final server = await PartyServer.start(0);
    addTearDown(server.close);
    final host = await _Client.connect(server.port);
    await host.next('welcome');
    host.send({'t': 'hello', 'name': 'RLTEX', 'uid': 'u-host'});
    final first = await _Client.connect(server.port);
    await first.next('welcome');
    first.send({'t': 'hello', 'name': 'Вася', 'uid': 'u-guest'});
    final second = await _Client.connect(server.port);
    final id = (await second.next('welcome'))['id'];
    second.send({'t': 'hello', 'name': 'Вася', 'uid': 'u-guest'});

    bool replaced(Map<dynamic, dynamic> room) {
      final members = room['members'] as List;
      return members.length == 2 &&
          members.any(
            (member) => member['uid'] == 'u-guest' && member['id'] == id,
          );
    }

    var room = await host.next('room');
    while (!replaced(room)) {
      room = await host.next('room');
    }

    await host.socket.close();
    await second.socket.close();
  });

}
