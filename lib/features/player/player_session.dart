import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:window_manager/window_manager.dart';

import '../../app_section.dart';
import '../../core/theme/app_colors.dart';
import '../../data/providers.dart';
import '../../system/full_screen.dart';
import '../autotrack/auto_marker.dart';
import 'frame_reports.dart';
import 'player_screen.dart';
import 'site_catalog.dart';
import 'site_script.dart';

/// Видео встроенного просмотра развёрнуто на весь экран.
class PlayerFullScreenNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}

final playerFullScreenProvider =
    NotifierProvider<PlayerFullScreenNotifier, bool>(
      PlayerFullScreenNotifier.new,
    );

Future<void>? _environment;

Future<void> _prepareEnvironment() => _environment ??= () async {
  final support = await getApplicationSupportDirectory();
  await WebviewController.initializeEnvironment(
    userDataPath: '${support.path}\\webview',
    additionalArguments: '--autoplay-policy=no-user-gesture-required',
  );
}();

/// Действие пользователя в плеере: пауза, продолжение или перемотка.
typedef PlayerEvent = ({String type, double time});

/// Встроенный просмотр сайта: страница, выбор серии и полный экран.
class PlayerSession extends ChangeNotifier {
  PlayerSession(
    this._ref, {
    required this.uri,
    required this.title,
    required this.section,
    this.animeId,
    this.episode,
    this.dubbing,
    this.player,
  }) {
    _marker = _ref.read(autoMarkerProvider);
    unawaited(_start());
  }

  final Ref _ref;
  final Uri uri;
  final String title;
  final int? animeId;
  final int? episode;
  final String? dubbing;
  final String? player;

  final controller = WebviewController();
  final _events = StreamController<PlayerEvent>.broadcast();
  late final AutoMarker _marker;
  final _reports = <String, FrameReport>{};
  final _subscriptions = <StreamSubscription<Object?>>[];

  AppSection section;
  Route<void>? route;
  String? url;
  bool ready = false;
  String? error;
  bool focus = true;
  bool cover = true;
  bool started = false;
  bool fullScreen = false;
  bool playing = false;
  double viewWidth = 1280;
  SiteCatalog? catalog;
  SiteChoice site = (dubbing: null, player: null, episode: null);

  FrameVideo? video;

  bool _mini = false;
  bool _ownPage = true;
  bool _chosen = false;
  bool _closed = false;
  Timer? _coverTimer;
  String? _videoFrame;
  DateTime? _toggledAt;
  DateTime? _modesSentAt;

  bool get onPage => route != null;

  Stream<PlayerEvent> get events => _events.stream;

  bool get native => catalog != null && _ownPage && uri.host.startsWith('ru.');

  Future<void> _start() async {
    try {
      await _prepareEnvironment();
      await controller.initialize();
      await controller.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);
      await controller.setBackgroundColor(AppColors.background);
      await controller.addScriptToExecuteOnDocumentCreated(siteScript);
      if (_closed) return;
      _subscriptions.addAll([
        controller.loadingState.listen(_onLoadingState),
        controller.url.listen((url) {
          _reports.clear();
          this.url = url;
          _notify();
        }),
        controller.webMessage.listen(_onMessage),
        controller.containsFullScreenElementChanged.listen(_setFullScreen),
      ]);
      await controller.loadUrl(uri.toString());
      ready = true;
      _notify();
      unawaited(_loadCatalog());
      _holdCover();
    } on Object catch (error) {
      this.error = '$error';
      _notify();
    }
  }

  void _notify() {
    if (!_closed) notifyListeners();
  }

  /// Озвучки, плееры и серии тайтла из API сайта.
  Future<void> _loadCatalog() async {
    final animeId = this.animeId;
    if (animeId == null) return;
    try {
      final yummyId = await _ref
          .read(siteEpisodesRepositoryProvider)
          .yummyId(animeId);
      if (yummyId == null) return;
      final catalog = SiteCatalog(
        await _ref.read(yummyClientProvider).videos(yummyId),
      );
      if (catalog.isEmpty || _closed) return;
      this.catalog = catalog;
      _notify();
      await _sendModes();
    } on Object {
      // Ошибка пропускается.
    }
  }

  /// Режимы, которые должны стоять на странице: только плеер, свои
  /// элементы, мини-окно, скрытые спойлеры.
  List<bool> get _modes => [
    focus || _mini,
    native || _mini,
    _mini,
    _ref.read(appPrefsProvider).value?.hideSpoilers ?? true,
  ];

  Future<void> _sendModes() async {
    if (_closed || !ready) return;
    _modesSentAt = DateTime.now();
    final [focus, native, mini, spoilers] = _modes;
    await controller.executeScript(
      'window.__kirokuFocus && window.__kirokuFocus($focus);'
      'window.__kirokuNative && window.__kirokuNative($native);'
      'window.__kirokuMini && window.__kirokuMini($mini);'
      'window.__kirokuSpoilers && window.__kirokuSpoilers($spoilers);',
    );
  }

  /// Ставит видео на паузу или продолжает.
  void togglePause() {
    final pause = playing;
    playing = !pause;
    _toggledAt = DateTime.now();
    _notify();
    control(pause ? 'pause' : 'play');
  }

  /// Команда видео: pause, play или seek на [position] секунд.
  void control(String action, {double? position}) {
    if (_closed || !ready) return;
    final url = jsonEncode(action == 'pause' ? null : _videoFrame);
    unawaited(
      controller.executeScript(
        'window.__kirokuControl && window.__kirokuControl('
        '${jsonEncode(action)}, ${jsonEncode(position)}, $url)',
      ),
    );
  }

  /// Выбирает озвучку, плеер и серию кнопками сайта.
  void choose(SiteChoice choice) {
    site = choice;
    _notify();
    final want = jsonEncode({
      'dubbing': choice.dubbing,
      'player': choice.player,
      'episode': choice.episode,
    });
    unawaited(
      controller.executeScript(
        'window.__kirokuPlay && window.__kirokuPlay($want)',
      ),
    );
  }

  /// Закрывает страницу фоном, пока сайт не приведён к виду «только
  /// плеер» (не дольше 8 секунд).
  void _holdCover() {
    if (_closed) return;
    _coverTimer?.cancel();
    cover = true;
    _notify();
    _coverTimer = Timer(const Duration(seconds: 8), () {
      cover = false;
      _notify();
    });
  }

  /// Переключает «только плеер» и всю страницу сайта.
  void toggleFocus() {
    focus = !focus;
    if (focus) _holdCover();
    _notify();
    unawaited(_sendModes());
  }

  /// Видео показано в мини-окне: на странице остаётся только плеер.
  void setMini(bool value) {
    _mini = value;
    unawaited(_sendModes());
  }

  /// После первой загрузки страницы тайтла выбирает серию и озвучку.
  void _onLoadingState(LoadingState state) {
    if (state != LoadingState.navigationCompleted) return;
    unawaited(_sendModes());
    if (_chosen) return;
    final url = Uri.tryParse(this.url ?? '');
    if (url == null || !url.path.startsWith('/catalog/item/')) return;
    _chosen = true;
    if (!url.host.startsWith('ru.')) return;
    if (episode == null && dubbing == null && player == null) return;
    choose((dubbing: dubbing, player: player, episode: episode));
  }

  void _onMessage(Object? message) {
    if (message is Map && message['kiroku'] == 2) {
      _onSiteState(message);
      return;
    }
    if (message is Map && message['kiroku'] == 4) {
      unawaited(_setFullScreen(message['full'] == true));
      return;
    }
    if (message is Map && message['kiroku'] == 6) {
      final type = message['event'];
      _events.add((
        type: type == 'seeked' ? 'seek' : '$type',
        time: (message['time'] as num?)?.toDouble() ?? 0,
      ));
      return;
    }
    final now = DateTime.now();
    final report = FrameReport.fromMessage(message, now);
    if (report == null) return;
    _reports[report.url] = report;
    video = mainVideo(_reports.values, now: now)?.video;
    final embedded = embeddedSession(_reports.values, now: now);
    _marker.reportEmbedded(embedded);
    if (embedded == null) return;
    if (embedded.position > 0) started = true;
    _videoFrame = embedded.documents.last.url;
    final toggledAt = _toggledAt;
    final isPlaying = embedded.status == 4;
    if (isPlaying != playing &&
        (toggledAt == null || now.difference(toggledAt).inSeconds >= 3)) {
      playing = isPlaying;
      _notify();
    }
  }

  /// Что выбрано на сайте сейчас.
  void _onSiteState(Map<dynamic, dynamic> message) {
    final ownPage = message['path'] == uri.path;
    if (ownPage != _ownPage) {
      _ownPage = ownPage;
      _notify();
    }
    final modes = message['modes'];
    final synced = modes is List && listEquals(modes, _modes);
    final sentAt = _modesSentAt;
    if (!synced &&
        (sentAt == null || DateTime.now().difference(sentAt).inSeconds >= 1)) {
      unawaited(_sendModes());
    }
    if (cover && synced && message['ready'] == true) {
      _coverTimer?.cancel();
      cover = false;
      _notify();
    }
    final site = (
      dubbing: message['dubbing'] as String? ?? this.site.dubbing,
      player: message['player'] as String? ?? this.site.player,
      episode: (message['episode'] as num?)?.toInt() ?? this.site.episode,
    );
    if (site != this.site) {
      this.site = site;
      _notify();
    }
  }

  Future<void> _setFullScreen(bool value) async {
    if (value == fullScreen || _closed) return;
    if (value && (_mini || !onPage)) {
      unawaited(_exitPageFullScreen());
      return;
    }
    fullScreen = value;
    _ref.read(playerFullScreenProvider.notifier).set(value);
    _notify();
    FullScreen.set(await windowManager.getId(), value);
  }

  Future<void> _exitPageFullScreen() async {
    await controller.executeScript(
      'document.fullscreenElement && document.exitFullscreen()',
    );
  }

  /// Страница просмотра открыта, мини-окно убирается.
  void enterPage(Route<void> route) {
    this.route = route;
    _notify();
  }

  /// Страница просмотра закрыта, видео остаётся в мини-окне.
  void leavePage() {
    route = null;
    if (fullScreen) {
      unawaited(_setFullScreen(false));
      unawaited(_exitPageFullScreen());
    }
    _notify();
  }

  /// Закрывает просмотр совсем.
  void close() {
    if (fullScreen) {
      fullScreen = false;
      _ref.read(playerFullScreenProvider.notifier).set(false);
      unawaited(windowManager.getId().then((id) => FullScreen.set(id, false)));
    }
    _closed = true;
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _coverTimer?.cancel();
    _marker.reportEmbedded(null);
    unawaited(_events.close());
    unawaited(controller.dispose());
  }
}

/// Открытый встроенный просмотр.
class PlayerSessionNotifier extends Notifier<PlayerSession?> {
  @override
  PlayerSession? build() => null;

  /// Открывает адрес во встроенном просмотре в текущем разделе.
  void open(
    Uri uri, {
    required String title,
    int? animeId,
    int? episode,
    String? dubbing,
    String? player,
  }) {
    final current = state;
    if (current != null && current.uri == uri) {
      show();
      if (episode != null && episode != current.site.episode) {
        current.choose((dubbing: dubbing, player: player, episode: episode));
      }
      return;
    }
    close();
    final session = PlayerSession(
      ref,
      uri: uri,
      title: title,
      section: ref.read(appSectionProvider),
      animeId: animeId,
      episode: episode,
      dubbing: dubbing,
      player: player,
    );
    state = session;
    _push(session);
  }

  /// Возвращает видео из мини-окна на страницу.
  void show() {
    final session = state;
    if (session == null) return;
    final current = ref.read(appSectionProvider);
    if (session.onPage) {
      if (session.section != current) {
        ref.read(appSectionProvider.notifier).open(session.section);
      }
      return;
    }
    session.section = current;
    _push(session);
  }

  void _push(PlayerSession session) {
    final route = MaterialPageRoute<void>(
      builder: (_) => PlayerScreen(session: session),
    );
    session.enterPage(route);
    sectionNavigatorKeys[session.section]?.currentState?.push(route);
  }

  /// Страница закрыта: начатое видео сворачивается, остальное закрывается.
  void pageClosed(PlayerSession session, Route<void>? route) {
    if (state != session || session.route != route) return;
    session.leavePage();
    if (!session.started) close();
  }

  /// Закрывает просмотр совсем.
  void close() {
    final session = state;
    if (session == null) return;
    state = null;
    final route = session.route;
    if (route != null && route.isActive) route.navigator?.removeRoute(route);
    session.close();
  }
}

final playerSessionProvider =
    NotifierProvider<PlayerSessionNotifier, PlayerSession?>(
      PlayerSessionNotifier.new,
    );
