import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/labels.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/select_button.dart';
import '../../data/database/library_repository.dart';
import '../../data/database/watch_status.dart';
import '../../data/providers.dart';
import 'site_catalog.dart';

/// Выбор озвучки, плеера и серии над видео сайта.
class SiteControls extends ConsumerWidget {
  const SiteControls({
    super.key,
    required this.animeId,
    required this.catalog,
    required this.choice,
    required this.onChoose,
    required this.width,
  });

  /// Высота строки вместе с отступом до видео.
  static const height = _rowHeight + _gap;
  static const _rowHeight = 36.0;
  static const _gap = 12.0;

  final int animeId;
  final SiteCatalog catalog;
  final SiteChoice choice;
  final ValueChanged<SiteChoice> onChoose;

  /// Ширина видео: строка не выходит за его края.
  final double width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dubbings = catalog.dubbings;
    final dubbing = dubbings.contains(choice.dubbing)
        ? choice.dubbing!
        : dubbings.first;
    final players = catalog.players(dubbing);
    final player = players.contains(choice.player)
        ? choice.player!
        : players.first;
    final current = (dubbing: dubbing, player: player, episode: choice.episode);
    final episodes = catalog.episodes(dubbing, player);

    final entry = ref.watch(libraryEntryProvider(animeId)).value;
    final history = entry == null
        ? const <CycleHistory>[]
        : ref.watch(titleHistoryProvider(animeId)).value ??
              const <CycleHistory>[];
    final status = entry == null
        ? WatchStatus.planned
        : WatchStatus.fromName(entry.status);
    final watched = CurrentViewing.of(history, status).events.keys.toSet();

    return Padding(
      padding: const EdgeInsets.only(bottom: _gap),
      child: Center(
        child: SizedBox(
          width: width,
          height: _rowHeight,
          child: Row(
            children: [
              SelectButton<String>(
                icon: LucideIcons.mic,
                tooltip: 'Озвучка',
                value: dubbing,
                options: dubbings,
                labelOf: (value) =>
                    '${shortDubbing(value)} · '
                    '${episodesLabel(catalog.episodeCount(value))}',
                onChanged: (value) =>
                    onChoose(catalog.withDubbing(current, value)),
              ),
              const SizedBox(width: 8),
              SelectButton<String>(
                icon: LucideIcons.monitorPlay,
                tooltip: 'Плеер',
                value: player,
                options: players,
                labelOf: shortPlayer,
                onChanged: (value) =>
                    onChoose(catalog.withPlayer(current, value)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _EpisodeStrip(
                  episodes: episodes,
                  watched: watched,
                  playing: choice.episode,
                  onTap: (episode) => onChoose((
                    dubbing: dubbing,
                    player: player,
                    episode: episode,
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Один ряд серий; если все не влезают, листается стрелками и колесом.
class _EpisodeStrip extends StatefulWidget {
  const _EpisodeStrip({
    required this.episodes,
    required this.watched,
    required this.playing,
    required this.onTap,
  });

  final List<int> episodes;
  final Set<int> watched;
  final int? playing;
  final ValueChanged<int> onTap;

  @override
  State<_EpisodeStrip> createState() => _EpisodeStripState();
}

class _EpisodeStripState extends State<_EpisodeStrip> {
  static const _tile = 48.0;
  static const _gap = 6.0;
  static const _arrow = 34.0;
  static const _wheelStep = 40.0;

  /// Первая видимая серия (индекс); null: встать на текущую.
  int? _start;
  double _wheel = 0;

  @override
  void didUpdateWidget(_EpisodeStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.playing != widget.playing ||
        oldWidget.episodes.length != widget.episodes.length) {
      _start = null;
    }
  }

  int _fit(double width) => max(0, ((width + _gap) / (_tile + _gap)).floor());

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final episodes = widget.episodes;
        final width = constraints.maxWidth;
        if (episodes.length <= _fit(width)) {
          return Row(
            children: [
              for (var i = 0; i < episodes.length; i++) ...[
                if (i > 0) const SizedBox(width: _gap),
                _tileFor(episodes[i], _tile),
              ],
            ],
          );
        }

        final room = width - 2 * (_arrow + _gap);
        final count = max(1, _fit(room));
        final last = episodes.length - count;
        final playing = episodes.indexOf(widget.playing ?? -1);
        final start = (_start ?? (playing < 0 ? 0 : playing - 2))
            .clamp(0, last)
            .toInt();
        final tileWidth = max(
          _tile,
          ((room - _gap * (count - 1)) / count).floorToDouble(),
        );

        void move(int by) =>
            setState(() => _start = (start + by).clamp(0, last).toInt());

        return Listener(
          onPointerSignal: (event) {
            if (event is! PointerScrollEvent) return;
            _wheel += event.scrollDelta.dy + event.scrollDelta.dx;
            final steps = (_wheel / _wheelStep).truncate();
            if (steps == 0) return;
            _wheel -= steps * _wheelStep;
            move(steps);
          },
          child: Row(
            children: [
              _Arrow(
                icon: LucideIcons.chevronLeft,
                tooltip: 'Предыдущие серии',
                onTap: start > 0 ? () => move(-count) : null,
              ),
              const SizedBox(width: _gap),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (var i = start; i < start + count; i++)
                      _tileFor(episodes[i], tileWidth),
                  ],
                ),
              ),
              const SizedBox(width: _gap),
              _Arrow(
                icon: LucideIcons.chevronRight,
                tooltip: 'Следующие серии',
                onTap: start < last ? () => move(count) : null,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _tileFor(int episode, double width) => _EpisodeTile(
    key: ValueKey(episode),
    episode: episode,
    width: width,
    watched: widget.watched.contains(episode),
    playing: episode == widget.playing,
    onTap: () => widget.onTap(episode),
  );
}

/// Стрелка листания ряда серий.
class _Arrow extends StatelessWidget {
  const _Arrow({required this.icon, required this.tooltip, this.onTap});

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.secondaryButton,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.secondaryButtonBorder),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          hoverColor: Colors.white.withValues(alpha: 0.06),
          child: SizedBox(
            width: 34,
            height: 34,
            child: Icon(
              icon,
              size: 16,
              color: onTap != null
                  ? AppColors.secondaryButtonText
                  : AppColors.secondaryButtonText.withValues(alpha: 0.3),
            ),
          ),
        ),
      ),
    );
  }
}

/// Плитка серии.
class _EpisodeTile extends StatelessWidget {
  const _EpisodeTile({
    super.key,
    required this.episode,
    required this.width,
    required this.watched,
    required this.playing,
    required this.onTap,
  });

  final int episode;
  final double width;
  final bool watched;
  final bool playing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: watched ? AppColors.accent : AppColors.secondaryButton,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: playing
            ? const BorderSide(color: AppColors.accentText, width: 2)
            : watched
            ? BorderSide.none
            : const BorderSide(color: AppColors.secondaryButtonBorder),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        hoverColor: Colors.white.withValues(alpha: 0.06),
        child: SizedBox(
          width: width,
          height: 34,
          child: Center(
            child: Text(
              '$episode',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: watched ? Colors.white : AppColors.secondaryButtonText,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
