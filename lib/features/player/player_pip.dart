import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:webview_windows/webview_windows.dart';

import '../../app_section.dart';
import '../../core/theme/app_colors.dart';
import 'player_session.dart';

/// Мини-окно с видео, когда страница просмотра закрыта или скрыта.
class PlayerPip extends ConsumerWidget {
  const PlayerPip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(playerSessionProvider);
    final section = ref.watch(appSectionProvider);
    if (session == null || ref.watch(playerFullScreenProvider)) {
      return const SizedBox.shrink();
    }
    return ListenableBuilder(
      listenable: session,
      builder: (context, _) =>
          session.ready && (!session.onPage || session.section != section)
          ? _PipWindow(key: ObjectKey(session), session: session)
          : const SizedBox.shrink(),
    );
  }
}

/// Окно с видео в углу, которое можно перетащить.
class _PipWindow extends ConsumerStatefulWidget {
  const _PipWindow({super.key, required this.session});

  final PlayerSession session;

  @override
  ConsumerState<_PipWindow> createState() => _PipWindowState();
}

class _PipWindowState extends ConsumerState<_PipWindow> {
  static const _size = Size(384, 216);
  static const _margin = 16.0;
  static var _corner = Alignment.bottomRight;

  Offset? _drag;
  bool _hover = false;

  @override
  void initState() {
    super.initState();
    widget.session.setMini(true);
  }

  @override
  void dispose() {
    widget.session.setMini(false);
    super.dispose();
  }

  Offset _cornerOffset(Size area) => Offset(
    _corner.x < 0 ? _margin : area.width - _size.width - _margin,
    _corner.y < 0 ? _margin : area.height - _size.height - _margin,
  );

  Offset _clamp(Offset offset, Size area) => Offset(
    offset.dx.clamp(0, area.width - _size.width),
    offset.dy.clamp(0, area.height - _size.height),
  );

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final sessions = ref.read(playerSessionProvider.notifier);
    return LayoutBuilder(
      builder: (context, constraints) {
        final area = constraints.biggest;
        final position = _drag ?? _cornerOffset(area);
        return Stack(
          children: [
            AnimatedPositioned(
              duration: _drag == null
                  ? const Duration(milliseconds: 200)
                  : Duration.zero,
              curve: Curves.easeOutCubic,
              left: position.dx,
              top: position.dy,
              width: _size.width,
              height: _size.height,
              child: MouseRegion(
                onEnter: (_) => setState(() => _hover = true),
                onExit: (_) => setState(() => _hover = false),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: sessions.show,
                  onPanStart: (_) => setState(() => _drag = position),
                  onPanUpdate: (details) => setState(
                    () => _drag = _clamp(_drag! + details.delta, area),
                  ),
                  onPanEnd: (_) => setState(() {
                    final center = _drag! + _size.center(Offset.zero);
                    _corner = Alignment(
                      center.dx < area.width / 2 ? -1 : 1,
                      center.dy < area.height / 2 ? -1 : 1,
                    );
                    _drag = null;
                  }),
                  child: _frame(session, sessions),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _frame(PlayerSession session, PlayerSessionNotifier sessions) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.panelBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x80000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: Colors.black),
            IgnorePointer(
              child: FittedBox(
                child: SizedBox(
                  width: session.viewWidth,
                  height: session.viewWidth * 9 / 16,
                  child: Webview(
                    session.controller,
                    filterQuality: FilterQuality.medium,
                  ),
                ),
              ),
            ),
            AnimatedOpacity(
              opacity: _hover ? 1 : 0,
              duration: const Duration(milliseconds: 150),
              child: _controls(session, sessions),
            ),
            Center(
              child: AnimatedOpacity(
                opacity: _hover || !session.playing ? 1 : 0,
                duration: const Duration(milliseconds: 150),
                child: Material(
                  color: const Color(0x99000000),
                  shape: const CircleBorder(),
                  child: IconButton(
                    tooltip: session.playing ? 'Пауза' : 'Продолжить',
                    onPressed: session.togglePause,
                    color: Colors.white,
                    iconSize: 22,
                    icon: Icon(
                      session.playing ? LucideIcons.pause : LucideIcons.play,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _controls(PlayerSession session, PlayerSessionNotifier sessions) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.center,
          colors: [Color(0xB3000000), Color(0x00000000)],
        ),
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 6, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  session.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Развернуть',
                onPressed: sessions.show,
                color: Colors.white,
                icon: const Icon(LucideIcons.maximize2, size: 16),
              ),
              IconButton(
                tooltip: 'Закрыть',
                onPressed: sessions.close,
                color: Colors.white,
                icon: const Icon(LucideIcons.x, size: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
