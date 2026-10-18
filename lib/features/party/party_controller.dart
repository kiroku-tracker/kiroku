import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/toast.dart';
import '../../data/database/app_database.dart';
import '../../data/database/party_history_repository.dart';
import '../../data/database/settings_repository.dart';
import '../../data/providers.dart';
import '../player/player_session.dart';
import 'party_address.dart';
import 'party_server.dart';

/// Роль в комнате.
enum PartyRole { none, host, guest }

/// Участник в списке окна комнаты.
typedef PartyPerson = ({
  int id,
  String uid,
  String name,
  bool owner,
  bool me,
  String status,
  Set<PartyRight> rights,
});

/// Что сейчас смотрят в комнате.
typedef PartyTarget = ({
  String uri,
  String title,
  int? animeId,
  int? episode,
  String? dubbing,
  String? player,
});

/// Состояние совместного просмотра.
class PartyState {
  const PartyState({
    this.role = PartyRole.none,
    this.address,
    this.busy = false,
    this.error,
    this.people = const [],
    this.waiting,
    this.target,
    this.playing = false,
    this.position = 0,
    this.duration = 0,
    this.rate = 1,
    this.reconnecting = false,
  });

  final PartyRole role;

  /// Адрес комнаты для друзей.
  final String? address;
  final bool busy;
  final String? error;
  final List<PartyPerson> people;

  /// Кого ждёт комната.
  final String? waiting;

  /// Что сейчас смотрят в комнате.
  final PartyTarget? target;

  /// Идёт ли просмотр в комнате.
  final bool playing;

  /// Где сейчас комната и длина серии, в секундах.
  final double position;
  final double duration;

  /// Общая скорость комнаты.
  final double rate;

  /// Связь с комнатой потеряна, идёт переподключение.
  final bool reconnecting;

  bool get active => role != PartyRole.none;

  /// Свои права в комнате.
  Set<PartyRight> get rights =>
      people.where((person) => person.me).firstOrNull?.rights ?? const {};

  PartyState copyWith({
    List<PartyPerson>? people,
    String? waiting,
    bool clearWaiting = false,
    PartyTarget? target,
    bool? playing,
    double? position,
    double? duration,
    double? rate,
    bool? reconnecting,
  }) => PartyState(
    role: role,
    address: address,
    busy: busy,
    error: error,
    people: people ?? this.people,
    waiting: clearWaiting ? null : waiting ?? this.waiting,
    target: target ?? this.target,
    playing: playing ?? this.playing,
    position: position ?? this.position,
    duration: duration ?? this.duration,
    rate: rate ?? this.rate,
    reconnecting: reconnecting ?? this.reconnecting,
  );
}

/// Совместный просмотр: своя комната или чужая.
class PartyNotifier extends Notifier<PartyState> {
  PartyServer? _server;
  WebSocket? _socket;
  Timer? _timer;
  Timer? _retry;
  StreamSubscription<PlayerEvent>? _events;
  PlayerSession? _followed;
  PartyTarget? _target;
  ({String host, int port})? _endpoint;
  ({String uid, String name})? _me;
  int? _myId;
  bool _owner = false;
  var _generation = 0;
  DateTime? _lostAt;
  String? _local;
  DateTime? _localSince;
  String? _sentLocal;
  DateTime? _matchedAt;
  PartySession? _record;
  DateTime? _recordedAt;
  Map<String, String> _known = const {};
  Map<String, Set<PartyRight>> _custom = const {};

  @override
  PartyState build() {
    ref.onDispose(_stop);
    return const PartyState();
  }

  /// Создаёт комнату и входит в неё.
  Future<void> host() async {
    if (state.active || state.busy) return;
    state = const PartyState(busy: true);
    final prefs = await ref.read(appPrefsProvider.future);
    final room = await partyRoom(prefs);
    if (room.error != null) {
      state = PartyState(error: room.error);
      return;
    }
    try {
      _custom = await _loadRights();
      _server = await PartyServer.start(room.port, rightsOf: _guestRights);
      await _connect('127.0.0.1', room.port);
      state = PartyState(
        role: PartyRole.host,
        address: room.address,
        target: _target,
      );
      if (_socket == null) _lost();
    } on Object catch (error) {
      await _stop();
      state = PartyState(error: 'Не удалось создать комнату: $error');
    }
  }

  /// Входит в комнату друга по коду, «IP» или «IP:порт».
  Future<void> join(String input) async {
    if (state.active || state.busy) return;
    final address =
        parsePartyCode(input) ??
        (input.contains('.') || input.contains(':')
            ? parsePartyAddress(input)
            : null);
    if (address == null) {
      state = const PartyState(error: 'Неверный код комнаты');
      return;
    }
    state = const PartyState(busy: true);
    try {
      await _connect(address.host, address.port);
      state = PartyState(
        role: PartyRole.guest,
        address: input.trim(),
        target: _target,
      );
      if (_socket == null) _lost();
    } on Object {
      await _stop();
      state = const PartyState(error: 'Не удалось войти в комнату');
    }
  }

  /// Возвращается к сеансу из истории: открывает тайтл и серию, снова
  /// создаёт свою комнату или входит в комнату друга.
  Future<void> resume(PartySession record) async {
    final uri = Uri.tryParse(record.uri);
    if (uri != null) {
      ref
          .read(playerSessionProvider.notifier)
          .open(
            uri,
            title: record.title,
            animeId: record.animeId,
            episode: record.episodeTo,
          );
    }
    if (state.active) return;
    if (record.role == 'host') {
      await host();
    } else {
      await join(record.address);
    }
    if (state.active) _record = record;
  }

  /// Открывает в плеере то, что сейчас смотрят в комнате.
  void watch() {
    final target = _target;
    final uri = target == null ? null : Uri.tryParse(target.uri);
    if (target == null || uri == null) return;
    final player = ref.read(playerSessionProvider.notifier);
    final session = ref.read(playerSessionProvider);
    if (session != null && session.uri == uri) {
      player.show();
      _match(session, target);
      return;
    }
    _matchedAt = DateTime.now();
    player.open(
      uri,
      title: target.title,
      animeId: target.animeId,
      episode: target.episode,
      dubbing: target.dubbing,
      player: target.player,
    );
  }

  /// Права гостя в своей комнате; запоминаются по номеру его Kiroku.
  Future<void> setRights(String uid, Set<PartyRight> rights) async {
    if (uid.isEmpty) return;
    _custom = {..._custom, uid: rights};
    _server?.refresh();
    await ref
        .read(settingsRepositoryProvider)
        .write('party.rights.$uid', partyRightsText(rights));
  }

  /// Новый ник сразу виден в комнате.
  Future<void> rename() async {
    final me = _me;
    if (me == null) return;
    final name = partyName(await ref.read(appPrefsProvider.future));
    _me = (uid: me.uid, name: name);
    _send({'t': 'hello', 'name': name, 'uid': me.uid});
  }

  /// Выходит из комнаты; своя комната закрывается.
  Future<void> leave() async {
    await _stop();
    state = const PartyState();
  }

  Future<Map<String, Set<PartyRight>>> _loadRights() async {
    final saved = await ref.read(settingsRepositoryProvider).readAll();
    const prefix = 'party.rights.';
    return {
      for (final MapEntry(:key, :value) in saved.entries)
        if (key.startsWith(prefix))
          key.substring(prefix.length): partyRightsOf(value),
    };
  }

  Set<PartyRight> _guestRights(String uid) {
    final custom = _custom[uid];
    if (custom != null) return custom;
    if (!ref.mounted) return const {};
    return (ref.read(appPrefsProvider).value ?? const AppPrefs())
        .partyGuestRights;
  }

  Future<void> _connect(String host, int port) async {
    final generation = _generation;
    final me = _me ??= await partyIdentity(
      ref.read(settingsRepositoryProvider),
      await ref.read(appPrefsProvider.future),
    );
    final socket = await WebSocket.connect('ws://$host:$port/')
        .timeout(const Duration(seconds: 6));
    if (generation != _generation) {
      unawaited(socket.close());
      throw const SocketException('Комната закрыта');
    }
    socket.pingInterval = const Duration(seconds: 5);
    _endpoint = (host: host, port: port);
    _socket = socket;
    socket.listen(_onMessage, onDone: () => _onClosed(socket), onError: (_) {});
    _send({'t': 'hello', 'name': me.name, 'uid': me.uid});
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(milliseconds: 500),
      (_) => _report(),
    );
  }

  /// Отправляет комнате своё состояние и свою смену серии.
  void _report() {
    if (!ref.mounted) return;
    final session = ref.read(playerSessionProvider);
    _follow(session);
    final target = _target;
    final video = session?.video;
    final watching =
        session != null &&
        session.ready &&
        (_owner || target == null || '${session.uri}' == target.uri);
    _send({
      't': 'state',
      'watching': watching,
      'episode': session?.site.episode,
      'position': session?.videoTime ?? 0,
      'duration': video?.duration ?? 0,
      'rate': video?.rate ?? 1,
      'playing': video != null && !video.paused,
      'ready': video != null && video.ready,
    });
    if (watching && video != null && !video.paused && video.time > 0) {
      _remember(video.time);
    }
    _offer(session, ready: video != null && video.ready);
  }

  /// Своя смена серии или озвучки: у создателя она становится серией
  /// комнаты, гостю комната её разрешает или нет. Отправляется, когда
  /// выбор держится секунду и это не переключение по команде комнаты.
  void _offer(PlayerSession? session, {required bool ready}) {
    final episode = session?.site.episode;
    final target = _target;
    if (session == null ||
        episode == null ||
        (!_owner && (target == null || '${session.uri}' != target.uri))) {
      _local = null;
      return;
    }
    final PartyTarget local = (
      uri: '${session.uri}',
      title: session.title,
      animeId: session.animeId,
      episode: episode,
      dubbing: session.site.dubbing,
      player: session.site.player,
    );
    final key = jsonEncode(_targetJson(local));
    final now = DateTime.now();
    if (key != _local) {
      _local = key;
      _localSince = now;
      return;
    }
    final since = _localSince;
    final matched = _matchedAt;
    if (key == _sentLocal ||
        (target != null && _same(local, target)) ||
        (matched != null && now.difference(matched).inSeconds < 8) ||
        since == null ||
        now.difference(since).inMilliseconds < 1000 ||
        (!_owner && !ready)) {
      return;
    }
    _sentLocal = key;
    _send({'t': 'open', 'target': _targetJson(local)});
  }

  /// Записывает сеанс в историю: не чаще раза в 5 секунд и сразу при
  /// смене серии.
  void _remember(double position) {
    final target = _target;
    if (target == null) return;
    final uri = target.uri;
    final episode = target.episode;
    final now = DateTime.now();
    final current = _record;
    final at = _recordedAt;
    if (current != null &&
        current.uri == uri &&
        current.episodeTo == episode &&
        at != null &&
        now.difference(at) < const Duration(seconds: 5)) {
      return;
    }
    final record = partyRecord(
      current,
      role: state.role == PartyRole.host ? 'host' : 'guest',
      address: state.address ?? '',
      animeId: target.animeId,
      title: target.title,
      uri: uri,
      episode: episode,
      position: position,
      people: [
        for (final person in state.people)
          if (!person.me) person.uid.isEmpty ? person.name : person.uid,
      ],
      now: now,
    );
    _record = record;
    _recordedAt = now;
    unawaited(ref.read(partyHistoryRepositoryProvider).save(record));
  }

  /// Пересылает комнате паузу, продолжение и перемотку из своего плеера.
  void _follow(PlayerSession? session) {
    if (session == _followed) return;
    _followed = session;
    unawaited(_events?.cancel());
    _events = session?.events.listen(
      (event) => _send({
        't': 'event',
        'type': event.type,
        'time': event.time,
        'rate': event.rate,
      }),
    );
  }

  void _onMessage(Object? data) {
    if (!ref.mounted) return;
    final Object? message;
    try {
      message = jsonDecode('$data');
    } on FormatException {
      return;
    }
    if (message is! Map) return;
    final session = ref.read(playerSessionProvider);
    switch (message['t']) {
      case 'welcome':
        _myId = (message['id'] as num?)?.toInt();
        _owner = message['owner'] == true;
      case 'open':
        final target = _parseTarget(message['target']);
        if (target != null) _onTarget(target);
      case 'play':
        session?.control(message['on'] == true ? 'play' : 'pause');
      case 'seek':
        final time = (message['time'] as num?)?.toDouble();
        if (time != null) session?.control('seek', position: time);
      case 'rate':
        final rate = (message['value'] as num?)?.toDouble();
        if (rate != null) session?.control('rate', rate: rate);
      case 'denied':
        final text = _deniedText(message['right']);
        if (text != null) {
          ref
              .read(toastProvider.notifier)
              .show('${text[0].toUpperCase()}${text.substring(1)}');
        }
      case 'bye' when !_owner:
        unawaited(_stop());
        state = const PartyState(error: 'Создатель закрыл комнату');
      case 'room':
        final people = <PartyPerson>[
          for (final person in (message['members'] as List?) ?? const [])
            if (person is Map)
              (
                id: (person['id'] as num?)?.toInt() ?? 0,
                uid: '${person['uid'] ?? ''}',
                name: '${person['name'] ?? ''}',
                owner: person['owner'] == true,
                me: person['id'] == _myId,
                status: '${person['status'] ?? ''}',
                rights: partyRightsOf(
                  ((person['rights'] as List?) ?? const []).join(','),
                ),
              ),
        ];
        _rememberPeople(people);
        final waiting = message['waiting'] as String?;
        state = state.copyWith(
          people: people,
          waiting: waiting,
          clearWaiting: waiting == null,
          playing: message['playing'] == true,
          rate: (message['rate'] as num?)?.toDouble() ?? 1,
          position: (message['position'] as num?)?.toDouble() ?? 0,
          duration: (message['duration'] as num?)?.toDouble() ?? 0,
        );
    }
  }

  /// Новая серия комнаты: показывается в окне комнаты, а уже открытый у
  /// себя тот же тайтл переключается на неё.
  void _onTarget(PartyTarget target) {
    _target = target;
    _sentLocal = null;
    state = state.copyWith(target: target);
    final session = ref.read(playerSessionProvider);
    if (session != null && '${session.uri}' == target.uri) {
      _match(session, target);
    }
  }

  /// Переключает открытый тайтл на серию, озвучку и плеер комнаты.
  void _match(PlayerSession session, PartyTarget target) {
    final site = session.site;
    final episode = target.episode;
    final dubbing = target.dubbing;
    final player = target.player;
    if (site.episode != episode ||
        (dubbing != null && site.dubbing != dubbing) ||
        (player != null && site.player != player)) {
      _matchedAt = DateTime.now();
      session.choose((dubbing: dubbing, player: player, episode: episode));
    }
  }

  /// Запоминает имена остальных участников по номерам их Kiroku.
  void _rememberPeople(List<PartyPerson> people) {
    final known = {
      for (final person in people)
        if (!person.me && person.uid.isNotEmpty) person.uid: person.name,
    };
    if (known.length == _known.length &&
        known.entries.every((entry) => _known[entry.key] == entry.value)) {
      return;
    }
    _known = known;
    unawaited(ref.read(partyHistoryRepositoryProvider).rememberPeople(known));
  }

  /// Связь оборвалась: комната остаётся на экране, Kiroku пробует
  /// вернуться в неё.
  void _onClosed(WebSocket socket) {
    if (!ref.mounted || socket != _socket) return;
    _socket = null;
    if (state.active) _lost();
  }

  /// Связи нет: комната помечается и начинаются попытки вернуться.
  void _lost() {
    _lostAt = DateTime.now();
    state = state.copyWith(reconnecting: true);
    _retryLater();
  }

  /// Новая попытка через 3 секунды; через минуту без связи комната
  /// закрывается.
  void _retryLater() {
    _retry?.cancel();
    _retry = Timer(const Duration(seconds: 3), () async {
      final endpoint = _endpoint;
      if (!ref.mounted || !state.active || endpoint == null) return;
      try {
        await _connect(endpoint.host, endpoint.port);
        if (ref.mounted) state = state.copyWith(reconnecting: false);
      } on Object {
        if (!ref.mounted || !state.active) return;
        final lost = _lostAt;
        if (lost != null &&
            DateTime.now().difference(lost) > const Duration(minutes: 1)) {
          await _stop();
          state = const PartyState(error: 'Связь с комнатой потеряна');
        } else {
          _retryLater();
        }
      }
    });
  }

  void _send(Map<String, Object?> message) {
    try {
      _socket?.add(jsonEncode(message));
    } on Object {
      // Ошибка пропускается.
    }
  }

  Future<void> _stop() async {
    _generation++;
    _timer?.cancel();
    _timer = null;
    _retry?.cancel();
    _retry = null;
    await _events?.cancel();
    _events = null;
    _followed = null;
    _target = null;
    _endpoint = null;
    _me = null;
    _owner = false;
    _lostAt = null;
    _local = null;
    _localSince = null;
    _sentLocal = null;
    _matchedAt = null;
    _record = null;
    _recordedAt = null;
    _known = const {};
    final socket = _socket;
    _socket = null;
    await socket?.close();
    final server = _server;
    _server = null;
    await server?.close();
  }
}

/// Чего не разрешила комната.
String? _deniedText(Object? right) => switch (right) {
  'pause' => 'нет права ставить паузу',
  'seek' => 'нет права перематывать',
  'episode' => 'нет права выбирать серию',
  'rate' => 'нет права менять скорость',
  _ => null,
};

/// Одна и та же серия: озвучка и плеер сравниваются, если комната их знает.
bool _same(PartyTarget local, PartyTarget target) =>
    local.uri == target.uri &&
    local.episode == target.episode &&
    (target.dubbing == null || local.dubbing == target.dubbing) &&
    (target.player == null || local.player == target.player);

/// Серия комнаты для отправки.
Map<String, Object?> _targetJson(PartyTarget target) => {
  'uri': target.uri,
  'title': target.title,
  'animeId': target.animeId,
  'episode': target.episode,
  'dubbing': target.dubbing,
  'player': target.player,
};

/// Серия комнаты из сообщения.
PartyTarget? _parseTarget(Object? data) {
  if (data is! Map || data['uri'] == null) return null;
  return (
    uri: '${data['uri']}',
    title: '${data['title'] ?? ''}',
    animeId: (data['animeId'] as num?)?.toInt(),
    episode: (data['episode'] as num?)?.toInt(),
    dubbing: data['dubbing'] is String ? data['dubbing'] as String : null,
    player: data['player'] is String ? data['player'] as String : null,
  );
}

final partyProvider = NotifierProvider<PartyNotifier, PartyState>(
  PartyNotifier.new,
);
