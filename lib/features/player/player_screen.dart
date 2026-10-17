import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_windows/webview_windows.dart';

import '../../app_section.dart';
import '../../core/theme/app_colors.dart';
import '../party/party_chip.dart';
import 'player_session.dart';
import 'site_controls.dart';

/// Страница встроенного просмотра.
class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key, required this.session});

  final PlayerSession session;

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  late final PlayerSessionNotifier _sessions;
  Route<void>? _route;

  @override
  void initState() {
    super.initState();
    _sessions = ref.read(playerSessionProvider.notifier);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _route ??= ModalRoute.of(context);
  }

  @override
  void dispose() {
    final session = widget.session;
    final route = _route;
    unawaited(Future.microtask(() => _sessions.pageClosed(session, route)));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final fullScreen = ref.watch(playerFullScreenProvider);
    final visible = ref.watch(appSectionProvider) == session.section;
    return ListenableBuilder(
      listenable: session,
      builder: (context, _) {
        final error = session.error;
        return Scaffold(
          body: Column(
            children: [
              if (!fullScreen) _topBar(session),
              if (!fullScreen && session.focus && session.native)
                SiteControls(
                  animeId: session.animeId!,
                  catalog: session.catalog!,
                  choice: session.site,
                  onChoose: session.choose,
                ),
              Expanded(
                child: error != null
                    ? Center(
                        child: Text(
                          'Встроенный просмотр недоступен: $error',
                          style: const TextStyle(color: AppColors.muted),
                        ),
                      )
                    : session.ready && visible
                    ? LayoutBuilder(
                        builder: (context, constraints) =>
                            _view(session, constraints, framed: !fullScreen),
                      )
                    : const Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Сайт с отступами и скруглением; «только плеер» в пропорциях 16:9.
  Widget _view(
    PlayerSession session,
    BoxConstraints constraints, {
    required bool framed,
  }) {
    final padding = framed ? 16.0 : 0.0;
    var width = constraints.maxWidth - padding * 2;
    var height = constraints.maxHeight - padding;
    if (framed && session.focus && session.native) {
      if (width / height > 16 / 9) {
        width = height * 16 / 9;
      } else {
        height = width * 9 / 16;
      }
    }
    session.viewWidth = width;
    return Padding(
      padding: EdgeInsets.fromLTRB(padding, 0, padding, padding),
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: width,
          height: height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(framed ? 12 : 0),
            child: Stack(
              children: [
                Webview(session.controller),
                if (session.cover && session.focus)
                  const Positioned.fill(
                    child: ColoredBox(
                      color: AppColors.background,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBar(PlayerSession session) {
    return Padding(
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
              session.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const PartyChip(),
          IconButton(
            tooltip: session.focus ? 'Вся страница' : 'Только плеер',
            onPressed: session.ready ? session.toggleFocus : null,
            icon: Icon(
              session.focus
                  ? LucideIcons.layoutTemplate
                  : LucideIcons.monitorPlay,
              size: 18,
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Обновить',
            onPressed: session.ready ? session.controller.reload : null,
            icon: const Icon(LucideIcons.refreshCw, size: 18),
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Открыть в браузере',
            onPressed: () => launchUrl(
              Uri.parse(session.url ?? session.uri.toString()),
              mode: LaunchMode.externalApplication,
            ),
            icon: const Icon(LucideIcons.externalLink, size: 18),
          ),
        ],
      ),
    );
  }
}
