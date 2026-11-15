import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/labels.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/status_menu.dart';
import '../../data/database/app_database.dart';
import '../../data/database/library_repository.dart';
import '../../data/database/watch_status.dart';
import '../../data/providers.dart';
import '../library/library_actions.dart';
import 'views_menu.dart';

/// Пункт «⋯» с окном истории и числа просмотров тайтла.
Widget historyMenuItem(
  BuildContext context, {
  required Anime anime,
  required String? selectedCycleId,
  required ValueChanged<String?> onSelect,
}) {
  return AppMenuItem(
    label: 'История просмотров…',
    icon: LucideIcons.history,
    color: AppColors.menuItemText,
    onPressed: () => showDialog<void>(
      context: context,
      builder: (_) => _HistoryDialog(
        anime: anime,
        selectedCycleId: selectedCycleId,
        onSelect: onSelect,
      ),
    ),
  );
}

/// Просмотры тайтла: сколько раз просмотрен целиком и список просмотров.
/// Клик по просмотру открывает его отметки в блоке «Серии».
class _HistoryDialog extends ConsumerWidget {
  const _HistoryDialog({
    required this.anime,
    required this.selectedCycleId,
    required this.onSelect,
  });

  final Anime anime;
  final String? selectedCycleId;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = ref.watch(libraryEntryProvider(anime.id)).value;
    final history =
        ref.watch(titleHistoryProvider(anime.id)).value ??
        const <CycleHistory>[];
    final views = ref.watch(viewsProvider).value?[anime.id];
    final status = entry == null
        ? WatchStatus.planned
        : WatchStatus.fromName(entry.status);
    final viewing = CurrentViewing.of(history, status);
    final library = ref.read(libraryRepositoryProvider);
    final count = views?.views ?? 0;
    final removable = views?.removable ?? 0;

    void select(String? id) {
      onSelect(id);
      Navigator.of(context).pop();
    }

    final rows = _rows(ref, history, viewing, select);
    return AlertDialog(
      title: const Text('История просмотров'),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 38,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Сколько раз тайтл просмотрен целиком',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                  StepButton(
                    icon: LucideIcons.minus,
                    tooltip: 'Меньше',
                    onPressed: removable > 0
                        ? () => library.removeView(anime.id)
                        : null,
                  ),
                  SizedBox(
                    width: 48,
                    child: Center(
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  StepButton(
                    icon: LucideIcons.plus,
                    tooltip: 'Больше',
                    onPressed: count < 999
                        ? () => library.addView(anime.id)
                        : null,
                  ),
                ],
              ),
            ),
            if (removable == 0 && count > 1) ...[
              const SizedBox(height: 6),
              const Text(
                'Просмотры с датами удаляются корзиной в списке',
                style: TextStyle(color: AppColors.muted, fontSize: 13),
              ),
            ],
            if (rows.isNotEmpty) ...[
              const SizedBox(height: 18),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      for (final row in rows)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: row,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Готово'),
        ),
      ],
    );
  }

  List<Widget> _rows(
    WidgetRef ref,
    List<CycleHistory> history,
    CurrentViewing viewing,
    ValueChanged<String?> onSelect,
  ) {
    if (history.isEmpty) return const [];
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
            if (history[index].cycle.id == selectedCycleId) {
              this.onSelect(null);
            }
            deleteViewing(
              ref,
              animeId: anime.id,
              cycleId: history[index].cycle.id,
              number: index + 1,
            );
          },
        ),
    ];
    return rows;
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
