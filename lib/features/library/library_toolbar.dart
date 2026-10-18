import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/status_style.dart';
import '../../core/widgets/icon_toggle.dart';
import '../../core/widgets/select_button.dart';
import '../../data/database/settings_repository.dart';
import '../../data/database/watch_status.dart';

class StatusTabs extends StatelessWidget {
  const StatusTabs({
    super.key,
    required this.current,
    required this.counts,
    required this.onChanged,
    this.favorites = false,
    this.favoriteCount = 0,
    this.onFavorites,
  });

  final WatchStatus? current;
  final Map<WatchStatus?, int> counts;
  final ValueChanged<WatchStatus?> onChanged;

  /// Открыта вкладка «Избранное».
  final bool favorites;
  final int favoriteCount;
  final VoidCallback? onFavorites;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: [
        for (final status in WatchStatus.values)
          TabChip(
            icon: StatusStyle.of(status).icon,
            label: status.label,
            count: counts[status] ?? 0,
            active: !favorites && current == status,
            onTap: () => onChanged(status),
          ),
        TabChip(
          icon: LucideIcons.layers3,
          label: 'Все',
          count: counts[null] ?? 0,
          active: !favorites && current == null,
          onTap: () => onChanged(null),
        ),
        if (onFavorites case final onFavorites?)
          TabChip(
            icon: LucideIcons.heart,
            label: 'Избранное',
            count: favoriteCount,
            active: favorites,
            onTap: onFavorites,
          ),
      ],
    );
  }
}

/// Вкладка-кнопка с числом.
class TabChip extends StatefulWidget {
  const TabChip({
    super.key,
    required this.icon,
    required this.label,
    this.count,
    required this.active,
    required this.onTap,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final int? count;
  final bool active;
  final VoidCallback onTap;

  /// Меньше обычной: для пунктов внутри вкладки.
  final bool compact;

  @override
  State<TabChip> createState() => _TabChipState();
}

class _TabChipState extends State<TabChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final highlighted = widget.active || _hovered;
    final compact = widget.compact;
    final idle = compact && widget.count == 0
        ? AppColors.navIdle.withValues(alpha: 0.45)
        : AppColors.navIdle;
    final radius = BorderRadius.circular(compact ? 8 : 10);
    return Semantics(
      button: true,
      selected: widget.active,
      child: Material(
        color: highlighted ? const Color(0xFF2B2642) : const Color(0xFF19181E),
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: highlighted
                ? const Color(0xFF6654C9)
                : const Color(0xFF323039),
          ),
        ),
        child: InkWell(
          onTap: widget.onTap,
          onHover: (value) => setState(() => _hovered = value),
          borderRadius: radius,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Padding(
            padding: compact
                ? const EdgeInsets.fromLTRB(10, 5, 6, 5)
                : const EdgeInsets.fromLTRB(12, 8, 8, 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.icon,
                  size: compact ? 14 : 16,
                  color: highlighted ? Colors.white : idle,
                ),
                SizedBox(width: compact ? 6 : 8),
                Text(
                  widget.label,
                  style: TextStyle(
                    color: highlighted ? Colors.white : idle,
                    fontSize: compact ? 13 : null,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.count case final count?) ...[
                  const SizedBox(width: 8),
                  Container(
                    constraints: const BoxConstraints(minWidth: 24),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: widget.active
                          ? const Color(0xFF6F56E8)
                          : const Color(0xFF302E38),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$count',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: widget.active
                            ? Colors.white
                            : const Color(0xFFCBC6D5),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Пункты вкладки «Хочу посмотреть» по выходу серий.
class PlannedTabs extends StatelessWidget {
  const PlannedTabs({
    super.key,
    required this.current,
    required this.counts,
    required this.onChanged,
  });

  final PlannedFilter current;
  final Map<PlannedFilter, int> counts;
  final ValueChanged<PlannedFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final filter in PlannedFilter.values)
          TabChip(
            icon: switch (filter) {
              PlannedFilter.all => LucideIcons.list,
              PlannedFilter.available => LucideIcons.circlePlay,
              PlannedFilter.airing => LucideIcons.radio,
              PlannedFilter.announced => LucideIcons.hourglass,
            },
            label: filter.label,
            count: counts[filter] ?? 0,
            active: current == filter,
            onTap: () => onChanged(filter),
            compact: true,
          ),
      ],
    );
  }
}

/// Панель поиска и фильтров.
class LibraryFilterBar extends StatelessWidget {
  const LibraryFilterBar({
    super.key,
    required this.queryController,
    required this.onQueryChanged,
    required this.prefs,
    required this.onPrefsChanged,
    this.tab,
  });

  /// Открытая вкладка: у пунктов «Хочу посмотреть» своя сортировка.
  final WatchStatus? tab;

  final TextEditingController queryController;
  final ValueChanged<String> onQueryChanged;
  final LibraryPrefs prefs;
  final ValueChanged<LibraryPrefs> onPrefsChanged;

  @override
  Widget build(BuildContext context) {
    void clear() {
      queryController.clear();
      onQueryChanged('');
    }

    return Row(
      children: [
        Expanded(
          child: CallbackShortcuts(
            bindings: {const SingleActivator(LogicalKeyboardKey.escape): clear},
            child: TextField(
              controller: queryController,
              onChanged: onQueryChanged,
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Найти в библиотеке',
                prefixIcon: const Icon(LucideIcons.search, size: 17),
                suffixIcon: queryController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Очистить',
                        onPressed: clear,
                        icon: const Icon(LucideIcons.x, size: 16),
                      ),
                constraints: const BoxConstraints(maxHeight: 40),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SelectButton<KindFilter>(
          icon: LucideIcons.filter,
          tooltip: 'Тип',
          value: prefs.kind,
          options: KindFilter.values,
          labelOf: (kind) => kind.label,
          onChanged: (kind) => onPrefsChanged(prefs.copyWith(kind: kind)),
        ),
        const SizedBox(width: 8),
        SelectButton<LibrarySort>(
          icon: LucideIcons.arrowUpDown,
          tooltip: 'Сортировка',
          value: prefs.sortIn(tab),
          options: LibrarySort.values,
          labelOf: (sort) => sort.label,
          onChanged: (sort) => onPrefsChanged(prefs.withSort(tab, sort)),
        ),
        const SizedBox(width: 12),
        IconToggle(
          icon: LucideIcons.layers,
          tooltip: prefs.groupFranchises
              ? 'Показать части франшиз отдельно'
              : 'Объединить части франшиз',
          active: prefs.groupFranchises,
          onTap: () => onPrefsChanged(
            prefs.copyWith(groupFranchises: !prefs.groupFranchises),
          ),
        ),
        Container(
          width: 1,
          height: 22,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          color: AppColors.divider,
        ),
        IconToggle(
          icon: LucideIcons.grid2x2,
          tooltip: 'Плитки',
          active: prefs.view == LibraryView.tiles,
          onTap: () => onPrefsChanged(prefs.copyWith(view: LibraryView.tiles)),
        ),
        const SizedBox(width: 4),
        IconToggle(
          icon: LucideIcons.table2,
          tooltip: 'Таблица',
          active: prefs.view == LibraryView.table,
          onTap: () => onPrefsChanged(prefs.copyWith(view: LibraryView.table)),
        ),
      ],
    );
  }
}
