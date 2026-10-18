import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/labels.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/status_style.dart';
import '../../core/widgets/poster.dart';
import '../../core/widgets/poster_card.dart';
import '../../core/widgets/release_badge.dart';
import '../../data/database/app_database.dart';
import '../../data/database/franchise_rules.dart';
import '../../data/database/library_repository.dart';
import '../../data/database/watch_status.dart';
import '../../data/shikimori/release_facts.dart';
import '../franchise/franchise_card.dart';
import '../franchise/franchise_screen.dart';
import '../title/title_screen.dart';
import 'entry_status_button.dart';
import 'library_filter.dart';

class LibraryTable extends StatefulWidget {
  const LibraryTable({super.key, required this.units, this.tab});

  final List<LibraryUnit> units;

  final WatchStatus? tab;

  @override
  State<LibraryTable> createState() => _LibraryTableState();
}

class _LibraryTableState extends State<LibraryTable> {
  static const _flex = [6, 3, 3, 2, 2, 2];

  final _expanded = <String>{};

  @override
  Widget build(BuildContext context) {
    const header = TextStyle(
      color: AppColors.muted,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    );
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.panelBorder),
      ),
      child: Column(
        children: [
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: const BoxDecoration(
              color: Color(0xFF222128),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                for (final (index, label) in const [
                  'Название',
                  'Статус',
                  'Прогресс',
                  'Моя оценка',
                  'Тип',
                  'Эфир',
                ].indexed)
                  Expanded(
                    flex: _flex[index],
                    child: Text(label, style: header),
                  ),
              ],
            ),
          ),
          for (final unit in widget.units)
            ...switch (unit) {
              TitleUnit(:final item) => [_Row(item: item, flex: _flex)],
              final FranchiseUnit unit => [
                _FranchiseRow(
                  unit: unit,
                  tab: widget.tab,
                  flex: _flex,
                  expanded: _expanded.contains(unit.key),
                  onToggle: () => setState(
                    () => _expanded.contains(unit.key)
                        ? _expanded.remove(unit.key)
                        : _expanded.add(unit.key),
                  ),
                ),
                if (_expanded.contains(unit.key))
                  for (final item in unit.items)
                    _Row(item: item, flex: _flex, nested: true),
              ],
            },
        ],
      ),
    );
  }
}

class _Row extends StatefulWidget {
  const _Row({required this.item, required this.flex, this.nested = false});

  final LibraryItem item;
  final List<int> flex;

  final bool nested;

  @override
  State<_Row> createState() => _RowState();
}

class _RowState extends State<_Row> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final anime = item.anime;
    final release = anime.release;
    final available = release.availableEpisodes;
    final fresh = release.isOngoing ? unwatchedAired(item) : 0;
    final flex = widget.flex;

    return Material(
      color: _hovered
          ? AppColors.cardHover
          : widget.nested
          ? const Color(0xFF16151A)
          : Colors.transparent,
      child: InkWell(
        onTap: () => openTitle(
          context,
          animeId: anime.id,
          backLabel: 'Назад в библиотеку',
        ),
        onHover: (value) => setState(() => _hovered = value),
        hoverColor: Colors.transparent,
        child: Container(
          height: 76,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.panelBorder)),
          ),
          child: Row(
            children: [
              Expanded(
                flex: flex[0],
                child: Row(
                  children: [
                    if (widget.nested) const SizedBox(width: 34),
                    SizedBox(
                      width: 40,
                      child: Poster(
                        url: anime.posterUrl,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            anime.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          if (anime.russian.isNotEmpty)
                            Text(
                              anime.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
              ),
              Expanded(
                flex: flex[1],
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: EntryStatusButton(
                    animeId: anime.id,
                    title: anime.title,
                    status: item.status,
                    release: release,
                    compact: true,
                  ),
                ),
              ),
              Expanded(
                flex: flex[2],
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            release.isAnnounced
                                ? ''
                                : '${item.progress.watched} / $available',
                          ),
                          if (fresh > 0) ...[
                            const SizedBox(width: 6),
                            Text(
                              '+$fresh',
                              style: const TextStyle(
                                color: Color(0xFFCBBFFF),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (!release.isAnnounced) ...[
                        const SizedBox(height: 6),
                        ProgressBar(
                          value: available == 0
                              ? 0
                              : item.progress.watched / available,
                          height: 4,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: flex[3],
                child: item.entry.score == null
                    ? const SizedBox.shrink()
                    : Row(
                        children: [
                          const Icon(
                            LucideIcons.star,
                            size: 14,
                            color: Color(0xFFFFC857),
                          ),
                          const SizedBox(width: 5),
                          Text('${item.entry.score} из 10'),
                        ],
                      ),
              ),
              Expanded(
                flex: flex[4],
                child: Text(
                  kindLabel(anime.kind),
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
              Expanded(
                flex: flex[5],
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ReleaseBadge(release: release),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FranchiseRow extends StatefulWidget {
  const _FranchiseRow({
    required this.unit,
    required this.tab,
    required this.flex,
    required this.expanded,
    required this.onToggle,
  });

  final FranchiseUnit unit;
  final WatchStatus? tab;
  final List<int> flex;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  State<_FranchiseRow> createState() => _FranchiseRowState();
}

class _FranchiseRowState extends State<_FranchiseRow> {
  bool _hovered = false;

  ReleaseFacts get _release {
    final releases = [for (final item in widget.unit.items) item.anime.release];
    return releases.where((release) => release.isOngoing).firstOrNull ??
        releases.where((release) => release.isAnnounced).firstOrNull ??
        releases.first;
  }

  @override
  Widget build(BuildContext context) {
    final unit = widget.unit;
    final flex = widget.flex;
    final total = unit.items.length;
    final tab = widget.tab;
    final average = unit.averageScore;
    const muted = TextStyle(color: AppColors.muted, fontSize: 12);

    return Material(
      color: _hovered ? AppColors.cardHover : Colors.transparent,
      child: InkWell(
        onTap: () => openFranchise(
          context,
          key: unit.key,
          backLabel: 'Назад в библиотеку',
        ),
        onHover: (value) => setState(() => _hovered = value),
        hoverColor: Colors.transparent,
        child: Container(
          height: 76,
          padding: const EdgeInsets.symmetric(horizontal: 14),

          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.panelBorder)),
          ),
          child: Row(
            children: [
              Expanded(
                flex: flex[0],
                child: Row(
                  children: [
                    SizedBox.square(
                      dimension: 30,
                      child: IconButton(
                        tooltip: widget.expanded
                            ? 'Свернуть части'
                            : 'Показать части',
                        onPressed: widget.onToggle,
                        iconSize: 18,
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          widget.expanded
                              ? LucideIcons.chevronDown
                              : LucideIcons.chevronRight,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 40,
                      child: Poster(
                        url: unit.cover.anime.posterUrl,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            unit.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            'Франшиза · ${partsLabel(total)}',
                            maxLines: 1,
                            style: muted,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
              ),
              Expanded(
                flex: flex[1],
                child: tab == null || unit.all != null
                    ? _StatusCounts(unit: unit)
                    : Text(
                        '${tab.label}: ${unit.countOf(tab)} из $total',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
              ),
              Expanded(
                flex: flex[2],
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        unit.all == null
                            ? '${unit.completedCount} из ${unit.releasedCount} '
                                  '${plural(unit.releasedCount, 'части', 'частей', 'частей')}'
                            : '${unit.watchedEpisodes} из '
                                  '${unit.availableEpisodes} эп.',
                      ),
                      const SizedBox(height: 6),
                      ProgressBar(value: unit.progress, height: 4),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: flex[3],
                child: average == null
                    ? const SizedBox.shrink()
                    : Tooltip(
                        message: 'Средняя оценка частей',
                        child: Row(
                          children: [
                            const Icon(
                              LucideIcons.star,
                              size: 14,
                              color: Color(0xFFFFC857),
                            ),
                            const SizedBox(width: 5),
                            Text('${formatAverage(average)} из 10'),
                          ],
                        ),
                      ),
              ),
              Expanded(
                flex: flex[4],
                child: const Text(
                  'Франшиза',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              Expanded(
                flex: flex[5],
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ReleaseBadge(release: _release),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Число частей по статусам.
class _StatusCounts extends StatelessWidget {
  const _StatusCounts({required this.unit});

  final FranchiseUnit unit;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      children: [
        for (final status in WatchStatus.values)
          if (unit.countOf(status) > 0)
            Tooltip(
              message: status.label,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    StatusStyle.of(status).icon,
                    size: 14,
                    color: StatusStyle.of(status).foreground,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${unit.countOf(status)}',
                    style: TextStyle(
                      color: StatusStyle.of(status).foreground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
      ],
    );
  }
}
