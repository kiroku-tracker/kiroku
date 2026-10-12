import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:window_manager/window_manager.dart';

import '../../app_section.dart';
import '../../core/theme/app_colors.dart';
import '../autotrack/auto_marker.dart';
import 'frame_reports.dart';

/// Скрипт во всех фреймах: видео на странице и известная реклама.
const _pageScript = r'''
(function () {
  if (window.__kiroku) return;
  window.__kiroku = true;
  var top = window === window.top;
  var ads = /adfinity|an\.yandex\.ru|yandex\.ru\/ads|adfox|doubleclick|googlesyndication|adriver|betweendigital|buzzoola|mediasniper/i;
  function isAd(url) { return ads.test(url || ''); }

  if (!top && isAd(location.href)) {
    document.documentElement.style.display = 'none';
    setInterval(function () {
      document.querySelectorAll('video').forEach(function (v) {
        v.muted = true;
        v.pause();
      });
    }, 500);
    return;
  }
  function sweep() {
    document.querySelectorAll('iframe').forEach(function (frame) {
      if (isAd(frame.src)) frame.remove();
    });
  }
  new MutationObserver(sweep).observe(document, { childList: true, subtree: true });

  function send(message) {
    if (top) {
      try { window.chrome.webview.postMessage(message); } catch (e) {}
    } else {
      try { window.top.postMessage(message, '*'); } catch (e) {}
    }
  }
  if (top) {
    window.addEventListener('message', function (e) {
      if (e.data && e.data.kiroku === 1) send(e.data);
    });
  }
  setInterval(function () {
    var videos = Array.prototype.map.call(document.querySelectorAll('video'), function (v) {
      return {
        time: v.currentTime,
        duration: isFinite(v.duration) ? v.duration : -1,
        paused: v.paused,
        muted: v.muted
      };
    });
    send({ kiroku: 1, url: location.href, title: document.title, top: top, videos: videos });
  }, 2000);
})();
''';

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
  );
}();

/// Открывает адрес во встроенном просмотре в текущем разделе.
void openPlayer(AppSection section, Uri uri, {required String title}) {
  sectionNavigatorKeys[section]?.currentState?.push(
    MaterialPageRoute<void>(
      builder: (_) => PlayerScreen(uri: uri, title: title),
    ),
  );
}

/// Встроенный просмотр сайта.
class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key, required this.uri, required this.title});

  final Uri uri;
  final String title;

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  final _controller = WebviewController();
  final _reports = <String, FrameReport>{};
  final _subscriptions = <StreamSubscription<Object?>>[];
  late final AutoMarker _marker;
  late final PlayerFullScreenNotifier _fullScreen;
  String? _url;
  bool _isFullScreen = false;
  bool _ready = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _marker = ref.read(autoMarkerProvider);
    _fullScreen = ref.read(playerFullScreenProvider.notifier);
    _start();
  }

  Future<void> _start() async {
    try {
      await _prepareEnvironment();
      await _controller.initialize();
      await _controller.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);
      await _controller.setBackgroundColor(AppColors.background);
      await _controller.addScriptToExecuteOnDocumentCreated(_pageScript);
      _subscriptions.addAll([
        _controller.url.listen((url) {
          _reports.clear();
          if (mounted) setState(() => _url = url);
        }),
        _controller.webMessage.listen(_onMessage),
        _controller.containsFullScreenElementChanged.listen(_setFullScreen),
      ]);
      await _controller.loadUrl(widget.uri.toString());
      if (mounted) setState(() => _ready = true);
    } on Object catch (error) {
      if (mounted) setState(() => _error = '$error');
    }
  }

  void _onMessage(Object? message) {
    final now = DateTime.now();
    final report = FrameReport.fromMessage(message, now);
    if (report == null) return;
    _reports[report.url] = report;
    _marker.reportEmbedded(embeddedSession(_reports.values, now: now));
  }

  Future<void> _setFullScreen(bool value) async {
    _isFullScreen = value;
    _fullScreen.set(value);
    await windowManager.setFullScreen(value);
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _marker.reportEmbedded(null);
    if (_isFullScreen) {
      _fullScreen.set(false);
      unawaited(windowManager.setFullScreen(false));
    }
    unawaited(_controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fullScreen = ref.watch(playerFullScreenProvider);
    final error = _error;
    return Scaffold(
      body: Column(
        children: [
          if (!fullScreen)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(LucideIcons.arrowLeft, size: 18),
                    label: const Text('Назад'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Обновить',
                    onPressed: _ready ? _controller.reload : null,
                    icon: const Icon(LucideIcons.refreshCw, size: 18),
                  ),
                  const SizedBox(width: 4),
                  OutlinedButton.icon(
                    onPressed: () => launchUrl(
                      Uri.parse(_url ?? widget.uri.toString()),
                      mode: LaunchMode.externalApplication,
                    ),
                    icon: const Icon(LucideIcons.externalLink),
                    label: const Text('Открыть в браузере'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: error != null
                ? Center(
                    child: Text(
                      'Встроенный просмотр недоступен: $error',
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  )
                : _ready
                ? Webview(_controller)
                : const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }
}
