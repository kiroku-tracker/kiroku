import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/widgets/app_menu_anchor.dart';
import '../../core/labels.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/panel.dart';
import '../../core/widgets/poster.dart';
import '../../core/widgets/status_menu.dart';
import '../../data/database/app_database.dart';
import '../../data/providers.dart';
import '../library/library_actions.dart';
import '../title/title_screen.dart';
import 'journal_model.dart';

class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  static const limit = 300;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journal = ref.watch(journalProvider);
    final events = journal.value ?? const [];
    final days = groupJournal(events);

    return SingleChildScrollView(
      padding: pagePadding(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(title: 'Журнал'),
          const SizedBox(height: 6),
          const Text(
            'Правый клик по строке: изменить дату или снять отметку.',
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 18),
          if (journal.hasError)
            Text(
              'Не удалось открыть журнал: ${journal.error}',
              style: const TextStyle(color: AppColors.dangerText),
            )
          else if (journal.hasValue && days.isEmpty)
            const EmptyState(
              title: 'Отметок пока нет',
              text: 'Здесь появятся отмеченные серии.',
            )
          else ...[
            for (final day in days) ...[
              Panel(
                title: _dayTitle(day.day),
                child: Column(
                  children: [
                    for (final row in day.rows) _JournalRowView(row: row),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],
            if (events.length >= limit)
              const Text(
                'Последние $limit отметок. Вся история тайтла на его '
                'странице.',
                style: TextStyle(color: AppColors.muted),
              ),
          ],
        ],
      ),
    );
  }

  static String _dayTitle(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = DateTime.utc(
      today.year,
      today.month,
      today.day,
    ).difference(DateTime.utc(day.year, day.month, day.day)).inDays;
    final date = day.year == now.year ? formatDayMonth(day) : formatDate(day);
    if (days == 0) return 'Сегодня, $date';
    if (days == 1) return 'Вчера, $date';
    return '${weekdayName(day)}, $date';
  }
}

class _JournalRowView extends ConsumerStatefulWidget {
  const _JournalRowView({required this.row});

  final JournalRow row;

  @override
  ConsumerState<_JournalRowView> createState() => _JournalRowViewState();
}

class _JournalRowViewState extends ConsumerState<_JournalRowView> {
  final _menu = MenuController();
  bool _hovered = false;

  JournalRow get row => widget.row;

  void _openTitle() =>
      openTitle(context, animeId: row.anime.id, backLabel: 'Назад в журнал');

  /// Положение меню кнопки.
  Offset _menuPosition(BuildContext button) {
    final box = button.findRenderObject()! as RenderBox;
    final row = context.findRenderObject()! as RenderBox;
    final corner = box.localToGlobal(
      box.size.bottomRight(Offset.zero),
      ancestor: row,
    );
    return Offset(corner.dx - 240, corner.dy);
  }

  Future<void> _pickDate() async {
    final current = row.undated ? DateTime.now() : row.at;
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: current.isAfter(now) ? now : current,
      firstDate: DateTime(1990),
      lastDate: now,
      helpText: '${episodesWord(row.episodes)}: дата просмотра',
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
      helpText: 'Время просмотра',
    );
    if (!mounted) return;
    await setEpisodesDate(
      ref,
      animeId: row.anime.id,
      cycleId: row.cycle.id,
      episodes: row.episodes,
      watchedAt: DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? 0,
        time?.minute ?? 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final details = [
      episodesWord(row.episodes),
      if (row.cycle.number > 1) '${row.cycle.number}-й просмотр',
      if (row.undated) 'без даты',
    ].join(' · ');

    final content = Material(
      color: _hovered ? AppColors.cardHover : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: _openTitle,
        onSecondaryTapDown: (details) =>
            _menu.open(position: details.localPosition),
        onHover: (value) => setState(() => _hovered = value),
        borderRadius: BorderRadius.circular(10),
        hoverColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              SizedBox(
                width: 54,
                child: Text(
                  row.undated ? '' : formatTime(row.at),
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              SizedBox(
                width: 32,
                child: Poster(
                  url: row.anime.posterUrl,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.anime.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      details,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              if (row.auto)
                const Tooltip(
                  message: 'Отмечено автоматически',
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      LucideIcons.monitorPlay,
                      size: 16,
                      color: AppColors.accentText,
                    ),
                  ),
                ),
              Builder(
                builder: (button) => IconButton(
                  tooltip: 'Действия',
                  onPressed: () => _menu.isOpen
                      ? _menu.close()
                      : _menu.open(position: _menuPosition(button)),
                  icon: const Icon(LucideIcons.ellipsis, size: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return AppMenuAnchor(
      controller: _menu,
      style: AppTheme.menuStyle,
      menuChildren: [
        AppMenuItem(
          label: 'Открыть тайтл',
          icon: LucideIcons.arrowUpRight,
          color: AppColors.menuItemText,
          onPressed: _openTitle,
        ),
        AppMenuItem(
          label: 'Изменить дату…',
          icon: LucideIcons.calendarClock,
          color: AppColors.menuItemText,
          onPressed: _pickDate,
        ),
        AppMenuItem(
          label: row.episodes.length == 1 ? 'Снять отметку' : 'Снять отметки',
          icon: LucideIcons.circleX,
          color: AppColors.dangerText,
          onPressed: () => unmarkEpisodes(
            ref,
            animeId: row.anime.id,
            title: row.anime.title,
            cycleId: row.cycle.id,
            episodes: row.episodes,
          ),
        ),
      ],
      child: content,
    );
  }
}
