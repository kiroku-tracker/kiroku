import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/labels.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/status_style.dart';
import '../../core/widgets/interactive_card.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/panel.dart';
import '../../core/widgets/poster.dart';
import '../../data/database/app_database.dart';
import '../../data/database/library_repository.dart';
import '../../data/providers.dart';
import '../notifications/site_line.dart';
import '../title/title_screen.dart';
import 'calendar_model.dart';

/// Календарь выхода серий.
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  int _weekOffset = 0;

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(libraryItemsProvider).value ?? const [];
    final now = DateTime.now();
    final week = buildCalendarWeek(items, now: now, weekOffset: _weekOffset);
    final today = DateTime(now.year, now.month, now.day);

    return SingleChildScrollView(
      padding: pagePadding(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Календарь',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_weekOffset != 0)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: OutlinedButton(
                      onPressed: () => setState(() => _weekOffset = 0),
                      child: const Text('Эта неделя'),
                    ),
                  ),
                IconButton(
                  tooltip: 'Предыдущая неделя',
                  onPressed: () => setState(() => _weekOffset--),
                  icon: const Icon(LucideIcons.chevronLeft),
                ),
                SizedBox(
                  width: 190,
                  child: Text(
                    formatWeek(week.start),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Следующая неделя',
                  onPressed: () => setState(() => _weekOffset++),
                  icon: const Icon(LucideIcons.chevronRight),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Японский эфир онгоингов из «Смотрю», «Хочу посмотреть» и '
            '«Отложено», по местному времени.',
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 18),
          if (week.isEmpty && _weekOffset == 0)
            const EmptyState(
              title: 'Нечего ждать',
              text: 'Здесь появятся онгоинги и анонсы из библиотеки.',
            )
          else ...[
            Panel(
              title: 'Неделя',
              child: Column(
                children: [
                  for (var index = 0; index < 7; index++)
                    _DayRow(
                      day: DateTime(
                        week.start.year,
                        week.start.month,
                        week.start.day + index,
                      ),
                      today: today,
                      episodes: week.days[index],
                      first: index == 0,
                    ),
                ],
              ),
            ),
            if (week.undated.isNotEmpty) ...[
              const SizedBox(height: 18),
              Panel(
                title: 'Дата следующей серии не объявлена',
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final item in week.undated)
                      _TitleCard(
                        item: item,
                        line:
                            'Вышло ${episodesLabel(item.anime.episodesAired)}',
                      ),
                  ],
                ),
              ),
            ],
            if (week.announced.isNotEmpty) ...[
              const SizedBox(height: 18),
              Panel(
                title: 'Анонсы',
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final item in week.announced)
                      _TitleCard(item: item, line: _premiere(item)),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  static String _premiere(LibraryItem item) {
    final next = item.anime.nextEpisodeAt;
    if (next != null) return 'Премьера: ${formatDateTime(next)}';
    final airedOn = item.anime.airedOn;
    if (airedOn != null) return 'Премьера: ${formatAiredOn(airedOn)}';
    return 'Дата премьеры не объявлена';
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.day,
    required this.today,
    required this.episodes,
    required this.first,
  });

  final DateTime day;
  final DateTime today;
  final List<CalendarEpisode> episodes;
  final bool first;

  @override
  Widget build(BuildContext context) {
    final isToday = day == today;
    final past = day.isBefore(today);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: first
            ? null
            : const Border(top: BorderSide(color: AppColors.panelBorder)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    weekdayName(day),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: isToday
                          ? AppColors.accentText
                          : past
                          ? AppColors.muted
                          : AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isToday
                        ? 'сегодня, ${formatDayMonth(day)}'
                        : formatDayMonth(day),
                    style: TextStyle(
                      color: isToday ? AppColors.accentText : AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: episodes.isEmpty
                ? const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text(
                      'Серий нет',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  )
                : Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final episode in episodes)
                        _EpisodeCard(episode: episode),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// Серия в календаре.
class _EpisodeCard extends ConsumerWidget {
  const _EpisodeCard({required this.episode});

  final CalendarEpisode episode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aired = episode.at.isBefore(DateTime.now());
    final watched = episode.item.progress.nextEpisode > episode.episode;
    final site = siteLine(
      ref,
      episode.item.anime,
      episode.item.entry,
      short: true,
    );
    return _CardFrame(
      item: episode.item,
      lines: [
        Text(
          [
            'Серия ${episode.episode}',
            '${episode.estimated ? '≈ ' : ''}${formatTime(episode.at)}',
          ].join(' · '),
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(height: 3),
        Text(
          watched
              ? 'Просмотрена'
              : aired
              ? 'Вышла'
              : 'Ещё не вышла',
          style: TextStyle(
            fontSize: 12,
            color: watched
                ? const Color(0xFFAEE8C0)
                : aired
                ? AppColors.accentText
                : AppColors.muted,
          ),
        ),
        if (site != null) ...[
          const SizedBox(height: 2),
          Text(
            site,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        ],
      ],
    );
  }
}

/// Тайтл без даты или анонс.
class _TitleCard extends StatelessWidget {
  const _TitleCard({required this.item, required this.line});

  final LibraryItem item;
  final String line;

  @override
  Widget build(BuildContext context) {
    return _CardFrame(
      item: item,
      lines: [
        Text(
          line,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

/// Рамка карточки календаря.
class _CardFrame extends StatelessWidget {
  const _CardFrame({required this.item, required this.lines});

  final LibraryItem item;
  final List<Widget> lines;

  @override
  Widget build(BuildContext context) {
    final style = StatusStyle.of(item.status);
    return SizedBox(
      width: 290,
      child: InteractiveCard(
        semanticLabel: item.anime.title,
        onTap: () => openTitle(
          context,
          animeId: item.anime.id,
          backLabel: 'Назад в календарь',
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 46,
                child: Poster(
                  url: item.anime.posterUrl,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.anime.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              height: 1.25,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Tooltip(
                          message: item.status.label,
                          child: Icon(
                            style.icon,
                            size: 14,
                            color: style.foreground,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ...lines,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
