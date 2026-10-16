import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../data/database/app_database.dart';
import '../../data/database/franchise_rules.dart';
import '../../data/database/settings_repository.dart';
import '../../data/providers.dart';
import '../../data/watch/dubbing_rules.dart';
import 'alert_rules.dart';
import 'dubbing_dialogs.dart';

/// Кнопка уведомлений тайтла.
class TitleAlertsButton extends ConsumerWidget {
  const TitleAlertsButton({
    super.key,
    required this.anime,
    required this.entry,
  });

  final Anime anime;
  final LibraryEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(appPrefsProvider).value ?? const AppPrefs();
    final franchises = ref.watch(franchisesProvider).value ?? const {};
    final choice = effectiveDubbing(
      entry,
      franchises[franchiseKeyOf(entry, anime)],
    );
    final on = episodeAlerts(entry, prefs);

    final String label;
    final String tooltip;
    if (!on) {
      label = 'Без уведомлений';
      tooltip = 'Уведомления о новых сериях выключены';
    } else if (choice != null) {
      label = choice.name;
      tooltip = switch (choice.source) {
        DubbingSource.title => 'Ждать серии в озвучке ${choice.name}',
        DubbingSource.franchise =>
          'Ждать серии в озвучке ${choice.name} (выбрана у франшизы)',
        DubbingSource.seen || DubbingSource.franchiseSeen =>
          'Ждать серии в озвучке ${choice.name} (по просмотру)',
      };
    } else {
      label = prefs.episodeAlert.label;
      tooltip = 'Озвучка не известна, уведомления по общей настройке';
    }

    return _AlertsChip(
      icon: on ? LucideIcons.bell : LucideIcons.bellOff,
      label: label,
      tooltip: tooltip,
      dimmed: !on,
      onPressed: () =>
          showTitleDubbingDialog(context, anime: anime, entry: entry),
    );
  }
}

/// Кнопка уведомлений франшизы.
class FranchiseAlertsButton extends ConsumerWidget {
  const FranchiseAlertsButton({
    super.key,
    required this.franchiseKey,
    required this.name,
    required this.partIds,
  });

  final String franchiseKey;
  final String name;
  final List<int> partIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(appPrefsProvider).value ?? const AppPrefs();
    final franchise =
        (ref.watch(franchisesProvider).value ?? const {})[franchiseKey];
    final chosen = franchise?.dubbing;
    final seen = franchise?.dubbingSeen;

    final String label;
    final String tooltip;
    if (chosen != null && chosen.isNotEmpty) {
      label = chosen;
      tooltip = 'Ждать серии в озвучке $chosen';
    } else if (chosen == null && seen != null) {
      label = seen;
      tooltip = 'Ждать серии в озвучке $seen (по просмотру)';
    } else {
      label = prefs.episodeAlert.label;
      tooltip = 'Озвучка не известна, уведомления по общей настройке';
    }

    final on = seasonAlerts(franchise, prefs);
    return _AlertsChip(
      icon: on ? LucideIcons.bell : LucideIcons.bellOff,
      label: label,
      tooltip: on ? tooltip : '$tooltip. О новых сезонах не сообщать',
      onPressed: () => showFranchiseDubbingDialog(
        context,
        franchiseKey: franchiseKey,
        name: name,
        partIds: partIds,
      ),
    );
  }
}

class _AlertsChip extends StatelessWidget {
  const _AlertsChip({
    required this.icon,
    required this.label,
    required this.tooltip,
    required this.onPressed,
    this.dimmed = false,
  });

  final IconData icon;
  final String label;
  final String tooltip;
  final VoidCallback onPressed;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final color = dimmed ? AppColors.muted : AppColors.textSecondary;
    return Tooltip(
      message: tooltip,
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 17, color: color),
        label: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 220),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color),
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10),
        ),
      ),
    );
  }
}
