import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import '../../data/database/settings_repository.dart';
import 'party_sync.dart';

/// Права гостя по номеру его Kiroku.
typedef PartyRightsOf = Set<PartyRight> Function(String uid);

/// Комната совместного просмотра: принимает участников и ведёт их вместе.
class PartyServer {
  PartyServer._(this._server, this._rightsOf) {
    _server.listen(_onRequest);
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) => _tick());
  }

  /// Открывает комнату на порту [port] на всех адресах компьютера. Без
  /// [rightsOf] гостям можно всё.
  static Future<PartyServer> start(int port, {PartyRightsOf? rightsOf}) async =>
      PartyServer._(
        await HttpServer.bind(InternetAddress.anyIPv4, port),
        rightsOf ?? (_) => PartyRight.values.toSet(),
      );

  final HttpServer _server;
  final PartyRightsOf _rightsOf;
  late final Timer _timer;
  final _members = <WebSocket, PartyMember>{};
  var _nextId = 1;
  var _ticks = 0;
  Map<dynamic, dynamic>? _target;
  bool _playing = false;
  PartyMember? _waitingFor;
  ({double time, DateTime at})? _lastSeek;

  /// Создатель комнаты уже подключается: следующий не станет владельцем.
  bool _ownerJoining = false;
  bool _closed = false;

  int get port => _server.port;

  int? get _episode => (_target?['episode'] as num?)?.toInt();

  Set<PartyRight> _rights(PartyMember member) =>
      member.owner ? PartyRight.values.toSet() : _rightsOf(member.uid);

  Future<void> _onRequest(HttpRequest request) async {
    if (!WebSocketTransformer.isUpgradeRequest(request)) {
      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
      return;
    }
    final local = request.connectionInfo?.remoteAddress.isLoopback ?? false;
    final owner =
        local &&
        !_ownerJoining &&
        !_members.values.any((member) => member.owner);
    if (owner) _ownerJoining = true;
    final WebSocket socket;
    try {
      socket = await WebSocketTransformer.upgrade(request);
    } on Object {
      return;
    } finally {
      if (owner) _ownerJoining = false;
    }
    if (_closed) {
      _send(socket, {'t': 'bye'});
      await socket.close();
      return;
    }
    socket.pingInterval = const Duration(seconds: 5);
    final member = PartyMember(id: _nextId++, owner: owner);
    _members[socket] = member;
    _send(socket, {'t': 'welcome', 'id': member.id, 'owner': member.owner});
    final target = _target;
    if (target != null) _send(socket, {'t': 'open', 'target': target});
    socket.listen(
      (data) => _onMessage(socket, member, data),
      onDone: () {
        _members.remove(socket);
        _room();
      },
      onError: (_) {},
    );
  }

  void _onMessage(WebSocket socket, PartyMember member, Object? data) {
    final Object? decoded;
    try {
      decoded = jsonDecode('$data');
    } on FormatException {
      return;
    }
    if (decoded is! Map) return;
    switch (decoded['t']) {
      case 'hello':
        final name = '${decoded['name'] ?? ''}'.trim();
        if (name.isNotEmpty) member.name = name;
        member.uid = '${decoded['uid'] ?? ''}';
        _replaceOld(socket, member);
        _room();
      case 'state':
        member
          ..watching = decoded['watching'] == true
          ..episode = (decoded['episode'] as num?)?.toInt()
          ..position = (decoded['position'] as num?)?.toDouble() ?? 0
          ..duration = (decoded['duration'] as num?)?.toDouble() ?? 0
          ..playing = decoded['playing'] == true
          ..ready = decoded['ready'] == true;
      case 'event':
        _onEvent(socket, member, decoded);
      case 'open':
        final target = decoded['target'];
        if (target is! Map) return;
        final current = _target;
        if (!member.owner &&
            (!_rights(member).contains(PartyRight.episode) ||
                current == null ||
                current['uri'] != target['uri'])) {
          _deny(socket, PartyRight.episode);
          if (current != null) _send(socket, {'t': 'open', 'target': current});
          return;
        }
        _target = target;
        for (final other in _members.keys) {
          _send(other, {'t': 'open', 'target': target});
        }
    }
  }

  /// Вернувшийся после обрыва участник заменяет своё старое соединение.
  void _replaceOld(WebSocket socket, PartyMember member) {
    if (member.uid.isEmpty) return;
    final old = [
      for (final MapEntry(key: other, value: otherMember) in _members.entries)
        if (other != socket && otherMember.uid == member.uid) other,
    ];
    for (final other in old) {
      final otherMember = _members.remove(other);
      if (otherMember != null && otherMember.owner && !member.owner) {
        member.owner = true;
        _send(socket, {'t': 'welcome', 'id': member.id, 'owner': true});
      }
      unawaited(other.close());
    }
  }

  /// Пауза, продолжение или перемотка у одного участника становятся общими,
  /// если у него есть на это право.
  void _onEvent(
    WebSocket from,
    PartyMember member,
    Map<dynamic, dynamic> event,
  ) {
    final rights = _rights(member);
    switch (event['type']) {
      case 'play' || 'pause' when !rights.contains(PartyRight.pause):
        _deny(from, PartyRight.pause);
        member.commandedAt = null;
        return;
      case 'play':
        _playing = true;
      case 'pause':
        _playing = false;
      case 'seek':
        final time = (event['time'] as num?)?.toDouble();
        if (time == null) return;
        if (!rights.contains(PartyRight.seek)) {
          _deny(from, PartyRight.seek);
          final back = _roomPosition(member);
          if (back != null) _send(from, {'t': 'seek', 'time': back});
          return;
        }
        final last = _lastSeek;
        final now = DateTime.now();
        if (last != null &&
            now.difference(last.at) < const Duration(seconds: 5) &&
            (last.time - time).abs() < 3) {
          return;
        }
        _lastSeek = (time: time, at: now);
        for (final MapEntry(key: socket, value: member) in _members.entries) {
          member.held = false;
          if (socket != from) _send(socket, {'t': 'seek', 'time': time});
        }
    }
    for (final member in _members.values) {
      member.commandedAt = null;
    }
    _tick();
  }

  /// Позиция остальных на серии участника: куда вернуть его после
  /// запрещённой перемотки.
  double? _roomPosition(PartyMember member) {
    double? position;
    for (final other in _members.values) {
      if (other == member ||
          !other.watching ||
          !other.ready ||
          other.episode != member.episode) {
        continue;
      }
      if (position == null || other.position < position) {
        position = other.position;
      }
    }
    return position;
  }

  void _deny(WebSocket socket, PartyRight right) =>
      _send(socket, {'t': 'denied', 'right': right.name});

  void _tick() {
    for (final MapEntry(key: socket, value: member) in _members.entries) {
      final time = partyAlign(member, _members.values);
      if (time != null) _send(socket, {'t': 'seek', 'time': time});
    }
    final plan = partyPlan(
      playing: _playing,
      episode: _episode,
      members: _members.values,
    );
    final now = DateTime.now();
    for (final MapEntry(key: socket, value: member) in _members.entries) {
      final play = plan.play[member.id];
      if (play == null || member.playing == play && member.ready) continue;
      final at = member.commandedAt;
      if (member.commanded == play &&
          at != null &&
          now.difference(at) < const Duration(milliseconds: 1500)) {
        continue;
      }
      member
        ..commanded = play
        ..commandedAt = now;
      _send(socket, {'t': 'play', 'on': play});
    }
    final changed = _waitingFor != plan.waitingFor;
    _waitingFor = plan.waitingFor;
    if (changed || ++_ticks % 2 == 0) _room();
  }

  /// Сразу рассылает состав комнаты, например после смены прав.
  void refresh() => _room();

  /// Рассылает состав комнаты.
  void _room() {
    final watching = [
      for (final member in _members.values)
        if (member.watching && (_episode == null || member.episode == _episode))
          member,
    ];
    final room = {
      't': 'room',
      'playing': _playing,
      'waiting': _waitingFor?.name,
      'position': watching.isEmpty
          ? 0
          : watching.map((member) => member.position).reduce(min),
      'duration': watching.isEmpty
          ? 0
          : watching.map((member) => member.duration).reduce(max),
      'members': [
        for (final member in _members.values)
          {
            'id': member.id,
            'uid': member.uid,
            'name': member.name,
            'owner': member.owner,
            'rights': [for (final right in _rights(member)) right.name],
            'status': partyStatus(
              member,
              episode: _episode,
              waitingFor: _waitingFor,
            ),
          },
      ],
    };
    for (final socket in _members.keys) {
      _send(socket, room);
    }
  }

  void _send(WebSocket socket, Map<String, Object?> message) {
    try {
      socket.add(jsonEncode(message));
    } on Object {
      // Ошибка пропускается.
    }
  }

  /// Закрывает комнату и сообщает об этом участникам.
  Future<void> close() async {
    _closed = true;
    _timer.cancel();
    final sockets = [..._members.keys];
    _members.clear();
    for (final socket in sockets) {
      _send(socket, {'t': 'bye'});
    }
    await Future.wait([for (final socket in sockets) socket.close()]);
    await _server.close(force: true);
  }
}
