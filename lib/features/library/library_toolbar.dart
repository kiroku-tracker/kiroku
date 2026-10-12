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
  });

  final WatchStatus? current;
  final Map<WatchStatus?, int> counts;
  final ValueChanged<WatchStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: [
        for (final status in WatchStatus.values)
          _Tab(
            icon: StatusStyle.of(status).icon,
            label: status.label,
            count: counts[status] ?? 0,
            active: current == status,
            onTap: () => onChanged(status),
          ),
        _Tab(
          icon: LucideIcons.layers3,
          label: 'Все',
          count: counts[null] ?? 0,
          active: current == null,
          onTap: () => onChanged(null),
        ),
      ],
    );
  }
}

class _Tab extends StatefulWidget {
  const _Tab({
    required this.icon,
    required this.label,
    required this.count,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final int count;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_Tab> createState() => _TabState();
}

class _TabState extends State<_Tab> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final highlighted = widget.active || _hovered;
    return Semantics(
      button: true,
      selected: widget.active,
      child: Material(
        color: highlighted ? const Color(0xFF2B2642) : const Color(0xFF19181E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: highlighted
                ? const Color(0xFF6654C9)
                : const Color(0xFF323039),
          ),
        ),
        child: InkWell(
          onTap: widget.onTap,
          onHover: (value) => setState(() => _hovered = value),
          borderRadius: BorderRadius.circular(10),
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.icon,
                  size: 16,
                  color: highlighted ? Colors.white : AppColors.navIdle,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: TextStyle(
                    color: highlighted ? Colors.white : AppColors.navIdle,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
                    '${widget.count}',
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
            ),
          ),
        ),
      ),
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
  });

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
          value: prefs.sort,
          options: LibrarySort.values,
          labelOf: (sort) => sort.label,
          onChanged: (sort) => onPrefsChanged(prefs.copyWith(sort: sort)),
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
