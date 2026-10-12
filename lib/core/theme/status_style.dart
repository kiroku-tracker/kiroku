import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/database/status_action.dart';
import '../../data/database/watch_status.dart';

/// Цвет и иконка статуса.
class StatusStyle {
  const StatusStyle({
    required this.foreground,
    required this.background,
    required this.icon,
  });

  final Color foreground;
  final Color background;
  final IconData icon;

  static StatusStyle of(WatchStatus status) => switch (status) {
    WatchStatus.watching => const StatusStyle(
      foreground: Color(0xFFCBBFFF),
      background: Color(0xFF31285C),
      icon: LucideIcons.play,
    ),
    WatchStatus.planned => const StatusStyle(
      foreground: Color(0xFFBCD8FF),
      background: Color(0xFF263957),
      icon: LucideIcons.clock3,
    ),
    WatchStatus.completed => const StatusStyle(
      foreground: Color(0xFFAEE8C0),
      background: Color(0xFF1C4930),
      icon: LucideIcons.circleCheck,
    ),
    WatchStatus.paused => const StatusStyle(
      foreground: Color(0xFFFFD79C),
      background: Color(0xFF50381F),
      icon: LucideIcons.pause,
    ),
    WatchStatus.dropped => const StatusStyle(
      foreground: Color(0xFFFFB4BD),
      background: Color(0xFF532830),
      icon: LucideIcons.circleX,
    ),
  };

  static StatusStyle ofAction(StatusAction action) =>
      action == StatusAction.caughtUp
      ? StatusStyle(
          foreground: of(WatchStatus.watching).foreground,
          background: of(WatchStatus.watching).background,
          icon: LucideIcons.checkCheck,
        )
      : of(action.status);
}
