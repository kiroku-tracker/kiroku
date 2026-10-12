import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/widgets/app_menu_anchor.dart';
import '../../core/labels.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../core/widgets/icon_toggle.dart';
import '../../core/widgets/panel.dart';
import '../../core/widgets/status_menu.dart';
import '../../data/database/app_database.dart';
import '../../data/database/library_repository.dart';
import '../library/library_actions.dart';

/// Блок «Серии» на странице тайтла.
class EpisodesPanel extends ConsumerStatefulWidget {
  const EpisodesPanel({
    super.key,
    required this.anime,
    required this.history,
    required this.viewing,
    required this.selectedCycleId,
    required this.onShowCurrent,
  });

  final Anime anime;

  final List<CycleHistory> history;

  final CurrentViewing viewing;

  final String? selectedCycleId;
  final VoidCallback onShowCurrent;

  @override
  ConsumerState<EpisodesPanel> createState() => _EpisodesPanelState();
}

enum _View { tiles, dates }

class _EpisodesPanelState extends ConsumerState<EpisodesPanel> {
  static const _rangeSize = 100;

  final _menuController = MenuController();
  final _gridKey = GlobalKey();
  _View _view = _View.tiles;
  int? _rangeIndex;
  int? _anchor;
  int? _menuEpisode;

  CycleHistory? get _current => widget.viewing.cycle;

  bool get _isCurrent => widget.selectedCycleId == null;

  CycleHistory? get _selected {
    if (_isCurrent) return _current;
    for (final cycle in widget.history) {
      if (cycle.cycle.id == widget.selectedCycleId) return cycle;
    }
    return _current;
  }

  int get _selectedOrdinal => _isCurrent
      ? widget.viewing.ordinal
      : widget.history.indexOf(_selected!) + 1;

  Map<int, WatchEvent> get _events => _selected?.events ?? const {};

  int get _total {
    final release = widget.anime.release;
    final declared = release.episodes > 0
        ? release.episodes
        : release.aired +
              (widget.anime.nextEpisodeAt != null || release.isOngoing ? 1 : 0);
    final marked = _events.keys.fold<int>(0, max);
    return max(declared, marked);
  }

  Set<int> get _previouslyWatched => {
    for (final cycle in widget.history)
      if (cycle != _current) ...cycle.events.keys,
  };

  @override
  Widget build(BuildContext context) {
    final total = _total;
    final ranges = (total / _rangeSize).ceil();
    var firstUnwatched = 1;
    while (_events.containsKey(firstUnwatched)) {
      firstUnwatched++;
    }
    final rangeIndex = (_rangeIndex ?? (firstUnwatched - 1) ~/ _rangeSize)
        .clamp(0, max(ranges - 1, 0))
        .toInt();
    final from = rangeIndex * _rangeSize + 1;
    final to = min(from + _rangeSize - 1, total);

    return Panel(
      title: 'Серии',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconToggle(
            icon: LucideIcons.grid3x3,
            tooltip: 'Плитки',
            active: _view == _View.tiles,
            onTap: () => setState(() => _view = _View.tiles),
          ),
          const SizedBox(width: 4),
          IconToggle(
            icon: LucideIcons.list,
            tooltip: 'Даты просмотра',
            active: _view == _View.dates,
            onTap: () => setState(() => _view = _View.dates),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_isCurrent) ...[
            _ArchivedBanner(
              number: _selectedOrdinal,
              onShowCurrent: widget.onShowCurrent,
            ),
            const SizedBox(height: 14),
          ],
          if (total == 0)
            const Text(
              'Серии ещё не выходили.',
              style: TextStyle(color: AppColors.muted),
            )
          else ...[
            if (ranges > 1) ...[
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (var index = 0; index < ranges; index++)
                    _RangeChip(
                      label:
                          '${index * _rangeSize + 1}–${min((index + 1) * _rangeSize, total)}',
                      active: index == rangeIndex,
                      onTap: () => setState(() => _rangeIndex = index),
                    ),
                ],
              ),
              const SizedBox(height: 14),
            ],
            if (_view == _View.tiles)
              _buildTiles(from, to)
            else
              _buildDates(from, to),
            if (_view == _View.tiles && _isCurrent) ...[
              const SizedBox(height: 12),
              const Text(
                'Клик: отметить или снять. Shift+клик: несколько подряд. '
                'Правый клик: дата и другие действия.',
                style: TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildTiles(int from, int to) {
    final release = widget.anime.release;
    final previous = _isCurrent ? _previouslyWatched : const <int>{};
    return AppMenuAnchor(
      controller: _menuController,
      style: AppTheme.menuStyle,
      menuChildren: _menuItems(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const minTile = 52.0;
          const gap = 8.0;
          final columns = max(
            1,
            ((constraints.maxWidth + gap) / (minTile + gap)).floor(),
          );
          final tileWidth =
              ((constraints.maxWidth - gap * (columns - 1)) / columns)
                  .floorToDouble();
          return Wrap(
            key: _gridKey,
            spacing: gap,
            runSpacing: gap,
            children: [
              for (var episode = from; episode <= to; episode++)
                _EpisodeTile(
                  width: tileWidth,
                  episode: episode,
                  event: _events[episode],
                  watchedBefore: previous.contains(episode),
                  unaired: release.isUnaired(episode),
                  extra: release.episodes > 0 && episode > release.episodes,
                  enabled: _isCurrent,
                  tooltip: _tooltip(episode),
                  onTap: () => _onTap(episode),
                  onSecondaryTap: (globalPosition) {
                    final box =
                        _gridKey.currentContext?.findRenderObject()
                            as RenderBox?;
                    if (box == null) return;
                    setState(() => _menuEpisode = episode);
                    _menuController.open(
                      position: box.globalToLocal(globalPosition),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  String _tooltip(int episode) {
    final event = _events[episode];
    final release = widget.anime.release;
    if (event != null) {
      final date = event.watchedAt == null
          ? 'дата неизвестна'
          : formatWatchDate(event.watchedAt!);
      final aired = event.beforeAired ? ' · до эфира' : '';
      return 'Серия $episode · просмотрена $date$aired';
    }
    if (release.isUnaired(episode)) {
      final next = widget.anime.nextEpisodeAt;
      return next != null && episode == release.aired + 1
          ? 'Серия $episode · выйдет ${formatDateTime(next)}'
          : 'Серия $episode · ещё не вышла';
    }
    if (_isCurrent && _previouslyWatched.contains(episode)) {
      return 'Серия $episode · просмотрена в прошлом просмотре';
    }
    return 'Серия $episode';
  }

  Future<void> _onTap(int episode) async {
    if (!_isCurrent) return;
    final anime = widget.anime;
    final anchor = _anchor;
    setState(() => _anchor = episode);

    if (HardwareKeyboard.instance.isShiftPressed &&
        anchor != null &&
        anchor != episode) {
      final from = min(anchor, episode);
      final to = max(anchor, episode);
      if (_events.containsKey(episode)) {
        await unmarkEpisodeRange(ref, animeId: anime.id, from: from, to: to);
        return;
      }
      final unaired = [
        for (var e = from; e <= to; e++)
          if (anime.release.isUnaired(e) && !_events.containsKey(e)) e,
      ];
      if (unaired.isNotEmpty && !await _confirmUnaired(unaired)) return;
      await markEpisodeRange(
        ref,
        animeId: anime.id,
        title: anime.title,
        from: from,
        to: to,
      );
      return;
    }

    if (!_events.containsKey(episode) &&
        anime.release.isUnaired(episode) &&
        !await _confirmUnaired([episode])) {
      return;
    }
    await toggleEpisode(
      ref,
      animeId: anime.id,
      title: anime.title,
      episode: episode,
    );
  }

  Future<bool> _confirmUnaired(List<int> episodes) {
    final single = episodes.length == 1;
    return confirmAction(
      context,
      title: single ? 'Серия ещё не вышла' : 'Часть серий ещё не вышла',
      message: single
          ? 'Серия ${episodes.single} ещё не вышла в японском эфире. '
                'Отметить всё равно?'
          : 'Серии ${episodes.first}–${episodes.last} ещё не вышли в японском '
                'эфире. Отметить всё равно?',
      confirmLabel: 'Отметить',
    );
  }

  List<Widget> _menuItems() {
    final episode = _menuEpisode;
    if (episode == null) return const [];
    final event = _events[episode];
    final anime = widget.anime;
    final hasGapBefore = [for (var e = 1; e < episode; e++) e]
        .any((e) => !_events.containsKey(e));
    return [
      if (event != null) ...[
        AppMenuItem(
          label: 'Указать дату просмотра…',
          icon: LucideIcons.calendarDays,
          color: AppColors.menuItemText,
          onPressed: () => _pickDate(episode),
        ),
        if (event.watchedAt != null)
          AppMenuItem(
            label: 'Дата неизвестна',
            icon: LucideIcons.calendarX2,
            color: AppColors.menuItemText,
            onPressed: () => setEpisodeDate(
              ref,
              animeId: anime.id,
              cycleId: _selected!.cycle.id,
              episode: episode,
              watchedAt: null,
            ),
          ),
      ],
      if (_isCurrent) ...[
        if (event == null)
          AppMenuItem(
            label: 'Отметить серию $episode',
            icon: LucideIcons.circleCheck,
            color: AppColors.menuItemText,
            onPressed: () => _onTap(episode),
          ),
        if (hasGapBefore && episode > 1)
          AppMenuItem(
            label: 'Отметить серии 1–$episode',
            icon: LucideIcons.checkCheck,
            color: AppColors.menuItemText,
            onPressed: () async {
              final unaired = [
                for (var e = 1; e <= episode; e++)
                  if (anime.release.isUnaired(e) && !_events.containsKey(e)) e,
              ];
              if (unaired.isNotEmpty && !await _confirmUnaired(unaired)) {
                return;
              }
              await markEpisodeRange(
                ref,
                animeId: anime.id,
                title: anime.title,
                from: 1,
                to: episode,
              );
            },
          ),
        if (event != null)
          AppMenuItem(
            label: 'Снять отметку',
            icon: LucideIcons.circleX,
            color: AppColors.dangerText,
            onPressed: () => toggleEpisode(
              ref,
              animeId: anime.id,
              title: anime.title,
              episode: episode,
            ),
          ),
      ],
    ];
  }

  Future<void> _pickDate(int episode) async {
    final selected = _selected;
    if (selected == null) return;
    final current = selected.events[episode]?.watchedAt?.toLocal();
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: DateTime(1990),
      lastDate: now,
      helpText: 'Серия $episode: дата просмотра',
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current ?? now),
      helpText: 'Время просмотра',
    );
    if (!mounted) return;
    final watchedAt = DateTime(
      date.year,
      date.month,
      date.day,
      time?.hour ?? 0,
      time?.minute ?? 0,
    );
    await setEpisodeDate(
      ref,
      animeId: widget.anime.id,
      cycleId: selected.cycle.id,
      episode: episode,
      watchedAt: watchedAt,
    );
  }

  Widget _buildDates(int from, int to) {
    final release = widget.anime.release;
    final rows = <Widget>[];
    for (var episode = from; episode <= to; episode++) {
      final event = _events[episode];
      final String state;
      if (event != null) {
        state = event.beforeAired ? 'Просмотрена до эфира' : 'Просмотрена';
      } else if (release.isUnaired(episode)) {
        state = 'Ещё не вышла';
      } else {
        state = 'Не просмотрена';
      }
      rows.add(
        Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            border: episode == from
                ? null
                : const Border(top: BorderSide(color: Color(0xFF312F37))),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 70,
                child: Text(
                  '№ $episode',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              SizedBox(
                width: 190,
                child: Text(
                  state,
                  style: TextStyle(
                    color: event != null
                        ? const Color(0xFFB9AAFF)
                        : AppColors.muted,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  event == null
                      ? ''
                      : event.watchedAt == null
                      ? 'дата неизвестна'
                      : formatWatchDate(event.watchedAt!),
                  style: TextStyle(
                    color: event?.watchedAt == null
                        ? AppColors.muted
                        : AppColors.text,
                  ),
                ),
              ),
              if (event != null)
                IconButton(
                  tooltip: 'Изменить дату',
                  iconSize: 17,
                  onPressed: () => _pickDate(episode),
                  icon: const Icon(LucideIcons.calendarDays),
                ),
            ],
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF383540)),
      ),
      child: Column(children: rows),
    );
  }
}

class _EpisodeTile extends StatefulWidget {
  const _EpisodeTile({
    required this.width,
    required this.episode,
    required this.event,
    required this.watchedBefore,
    required this.unaired,
    required this.extra,
    required this.enabled,
    required this.tooltip,
    required this.onTap,
    required this.onSecondaryTap,
  });

  final double width;
  final int episode;
  final WatchEvent? event;
  final bool watchedBefore;
  final bool unaired;

  final bool extra;
  final bool enabled;
  final String tooltip;
  final VoidCallback onTap;
  final ValueChanged<Offset> onSecondaryTap;

  @override
  State<_EpisodeTile> createState() => _EpisodeTileState();
}

class _EpisodeTileState extends State<_EpisodeTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final watched = widget.event != null;
    final (Color background, Color border, Color text) = switch ((
      watched,
      widget.unaired,
      widget.watchedBefore,
    )) {
      (true, true, _) => (
        const Color(0xFF49365F),
        const Color(0xFF9A76CF),
        const Color(0xFFEADFFF),
      ),
      (true, false, _) => (
        const Color(0xFF4D3CA0),
        const Color(0xFF755FE4),
        Colors.white,
      ),
      (false, true, _) => (
        const Color(0xFF211F26),
        const Color(0xFF6B6177),
        const Color(0xFF9E97A7),
      ),
      (false, false, true) => (
        const Color(0xFF2C2940),
        const Color(0xFF514775),
        const Color(0xFFC9C0EC),
      ),
      _ => (
        const Color(0xFF232229),
        const Color(0xFF3A3842),
        const Color(0xFFBBB7C3),
      ),
    };
    final hovered = _hovered && widget.enabled;
    final borderColor = widget.extra
        ? AppColors.dangerText
        : hovered
        ? const Color(0xFF8B78F0)
        : border;

    return Tooltip(
      message: widget.tooltip,
      waitDuration: const Duration(milliseconds: 500),
      child: MouseRegion(
        cursor: widget.enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.enabled ? widget.onTap : null,
          onSecondaryTapDown: (details) =>
              widget.onSecondaryTap(details.globalPosition),
          child: CustomPaint(
            foregroundPainter: widget.unaired
                ? _DashedBorder(color: borderColor)
                : null,
            child: Container(
              width: widget.width,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(8),
                border: widget.unaired ? null : Border.all(color: borderColor),
              ),
              child: Text(
                '${widget.episode}',
                style: TextStyle(
                  color: hovered && !watched ? Colors.white : text,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorder extends CustomPainter {
  _DashedBorder({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(0.5),
          const Radius.circular(8),
        ),
      );
    for (final metric in path.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += 7) {
        canvas.drawPath(metric.extractPath(d, d + 4), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorder oldDelegate) =>
      oldDelegate.color != color;
}

class _RangeChip extends StatelessWidget {
  const _RangeChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? const Color(0xFF3B2F78) : const Color(0xFF222027),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: active ? AppColors.progress : const Color(0xFF393640),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : AppColors.navIdle,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _ArchivedBanner extends StatelessWidget {
  const _ArchivedBanner({required this.number, required this.onShowCurrent});

  final int number;
  final VoidCallback onShowCurrent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
      decoration: BoxDecoration(
        color: const Color(0xFF211D35),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF574B91)),
      ),
      child: Row(
        children: [
          const Icon(
            LucideIcons.history,
            size: 16,
            color: AppColors.accentText,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Просмотр $number: здесь меняются только даты.',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: onShowCurrent,
            child: const Text('К текущему просмотру'),
          ),
        ],
      ),
    );
  }
}
