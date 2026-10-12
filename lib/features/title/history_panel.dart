import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/labels.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/panel.dart';
import '../../data/database/app_database.dart';
import '../../data/database/library_repository.dart';
import '../library/library_actions.dart';

class HistoryPanel extends ConsumerWidget {
  const HistoryPanel({
    super.key,
    required this.anime,
    required this.history,
    required this.viewing,
    required this.selectedCycleId,
    required this.onSelect,
  });

  final Anime anime;
  final List<CycleHistory> history;
  final CurrentViewing viewing;
  final String? selectedCycleId;

  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = anime.release.availableEpisodes;
    final rows = <Widget>[
      if (viewing.cycle == null)
        _HistoryRow(
          ordinal: viewing.ordinal,
          item: null,
          isCurrent: true,
          selected: selectedCycleId == null,
          total: total,
          onTap: () => onSelect(null),
        ),
      for (var index = history.length - 1; index >= 0; index--)
        _HistoryRow(
          ordinal: index + 1,
          item: history[index],
          isCurrent: history[index] == viewing.cycle,
          selected: history[index] == viewing.cycle
              ? selectedCycleId == null
              : history[index].cycle.id == selectedCycleId,
          total: total,
          onTap: () => onSelect(
            history[index] == viewing.cycle ? null : history[index].cycle.id,
          ),
          onDelete: () {
            if (history[index].cycle.id == selectedCycleId) onSelect(null);
            deleteViewing(
              ref,
              animeId: anime.id,
              cycleId: history[index].cycle.id,
              number: index + 1,
            );
          },
        ),
    ];
    return Panel(
      title: 'История просмотров',
      child: Column(
        children: [
          for (final row in rows)
            Padding(padding: const EdgeInsets.only(bottom: 8), child: row),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.ordinal,
    required this.item,
    required this.isCurrent,
    required this.selected,
    required this.total,
    required this.onTap,
    this.onDelete,
  });

  final int ordinal;

  final CycleHistory? item;
  final bool isCurrent;
  final bool selected;
  final int total;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final item = this.item;
    final String subtitle;
    if (item == null) {
      subtitle = 'начнётся с первой отмеченной серии';
    } else {
      final (from, to) = item.dateRange;
      final dates = from == null
          ? 'даты неизвестны'
          : formatDateRange(from, to!);
      final watched = item.events.length;
      final episodes = total > 0
          ? '$watched из ${episodesLabel(total)}'
          : episodesLabel(watched);
      subtitle = '$dates · $episodes';
    }

    final (
      String state,
      Color stateColor,
      Color stateBackground,
      IconData icon,
    ) = item == null
        ? (
            'не начат',
            const Color(0xFFB9B4C1),
            const Color(0xFF2A2830),
            LucideIcons.play,
          )
        : item.isCompleted
        ? (
            'завершён',
            const Color(0xFFAEE8C0),
            const Color(0xFF1C4930),
            LucideIcons.circleCheck,
          )
        : item.isUnfinished
        ? (
            'не завершён',
            const Color(0xFFFFD79C),
            const Color(0xFF50381F),
            LucideIcons.circlePause,
          )
        : (
            'идёт',
            const Color(0xFFCBBFFF),
            const Color(0xFF31285C),
            LucideIcons.play,
          );

    return Material(
      color: selected ? const Color(0xFF28233B) : const Color(0xFF1E1C22),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: selected ? AppColors.progress : const Color(0xFF34313A),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: EdgeInsets.fromLTRB(14, 10, onDelete == null ? 14 : 6, 10),
          child: Row(
            children: [
              Icon(icon, size: 18, color: stateColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Просмотр $ordinal${isCurrent ? ' · текущий' : ''}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: stateBackground,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  state,
                  style: TextStyle(
                    color: stateColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (onDelete != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  tooltip: 'Удалить просмотр',
                  iconSize: 17,
                  onPressed: onDelete,
                  icon: const Icon(LucideIcons.trash2),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
