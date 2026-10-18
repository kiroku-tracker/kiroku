import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/labels.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/panel.dart';
import '../../core/widgets/poster.dart';
import '../../data/database/library_repository.dart';
import '../../data/database/status_action.dart';
import '../../data/providers.dart';
import '../../data/shikimori/anime_info.dart';
import '../title/title_screen.dart';
import 'discover_logic.dart';
import '../welcome/one_time_tip.dart';

/// Тайтл для карточек и почему он предложен.
typedef DiscoverEntry = ({AnimeInfo anime, String reason});

enum _Swipe { want, hide, skip, seen }

/// Карточки по одной: вправо «Хочу посмотреть», влево «Не интересно»,
/// вниз «Пропустить», глаз «Уже смотрел».
class SwipeDeck extends ConsumerStatefulWidget {
  const SwipeDeck({super.key, required this.entries, required this.backLabel});

  final List<DiscoverEntry> entries;
  final String backLabel;

  @override
  ConsumerState<SwipeDeck> createState() => _SwipeDeckState();
}

class _SwipeDeckState extends ConsumerState<SwipeDeck>
    with SingleTickerProviderStateMixin {
  static const _cardWidth = 400.0;
  static const _cardHeight = 580.0;
  static const _threshold = 130.0;

  late final _fly = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  )..addListener(_onFly);
  final _focus = FocusNode();
  final _done = <({int id, _Swipe swipe, LibraryChange? change})>[];
  Offset _shift = Offset.zero;
  Offset _flyFrom = Offset.zero;
  Offset _flyTo = Offset.zero;
  bool _busy = false;

  @override
  void dispose() {
    _fly.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onFly() => setState(
    () => _shift = Offset.lerp(
      _flyFrom,
      _flyTo,
      Curves.easeOut.transform(_fly.value),
    )!,
  );

  Future<void> _animate(Offset to) async {
    _flyFrom = _shift;
    _flyTo = to;
    await _fly.forward(from: 0);
  }

  List<DiscoverEntry> _queue() {
    final hidden = ref.watch(discoverHiddenProvider).value ?? const {};
    final statuses = ref.watch(libraryStatusesProvider).value ?? const {};
    final done = {for (final item in _done) item.id};
    return [
      for (final entry in widget.entries)
        if (!hidden.contains(entry.anime.id) &&
            !done.contains(entry.anime.id) &&
            statuses[entry.anime.id] == null)
          entry,
    ];
  }

  Future<void> _decide(DiscoverEntry entry, _Swipe swipe) async {
    if (_busy) return;
    _busy = true;
    try {
      switch (swipe) {
        case _Swipe.want:
          await _animate(const Offset(900, 0));
        case _Swipe.hide:
          await _animate(const Offset(-900, 0));
        case _Swipe.seen:
          await _animate(const Offset(0, -900));
        case _Swipe.skip:
          break;
      }
      LibraryChange? change;
      switch (swipe) {
        case _Swipe.want:
          change = await ref
              .read(libraryRepositoryProvider)
              .add(entry.anime, StatusAction.planned);
        case _Swipe.seen:
          change = await ref
              .read(libraryRepositoryProvider)
              .add(entry.anime, StatusAction.completed);
        case _Swipe.hide:
          await ref.read(discoverHiddenProvider.notifier).hide(entry.anime.id);
        case _Swipe.skip:
          break;
      }
      if (!mounted) return;
      setState(() {
        _done.add((id: entry.anime.id, swipe: swipe, change: change));
        _shift = Offset.zero;
      });
    } finally {
      _busy = false;
    }
  }

  Future<void> _undo() async {
    if (_busy || _done.isEmpty) return;
    final last = _done.removeLast();
    switch (last.swipe) {
      case _Swipe.want || _Swipe.seen:
        await last.change?.undo();
      case _Swipe.hide:
        await ref.read(discoverHiddenProvider.notifier).unhide(last.id);
      case _Swipe.skip:
        break;
    }
    if (mounted) setState(() {});
  }

  KeyEventResult _onKey(DiscoverEntry? top, KeyEvent event) {
    if (event is! KeyDownEvent || top == null) return KeyEventResult.ignored;
    final swipe = switch (event.logicalKey) {
      LogicalKeyboardKey.arrowRight => _Swipe.want,
      LogicalKeyboardKey.arrowLeft => _Swipe.hide,
      LogicalKeyboardKey.arrowDown => _Swipe.skip,
      LogicalKeyboardKey.arrowUp => _Swipe.seen,
      _ => null,
    };
    if (swipe != null) {
      _decide(top, swipe);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      _undo();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final queue = _queue();
    final top = queue.firstOrNull;
    final next = queue.length > 1 ? queue[1] : null;
    final undo = TextButton.icon(
      onPressed: _done.isEmpty ? null : _undo,
      icon: const Icon(LucideIcons.undo2, size: 17),
      label: const Text('Вернуть'),
    );
    if (top == null) {
      return Column(
        children: [
          const EmptyState(
            title: 'Карточки закончились',
            text: 'Можно открыть сетку или подобрать заново.',
          ),
          if (_done.isNotEmpty) ...[const SizedBox(height: 12), undo],
        ],
      );
    }
    void open() =>
        openTitle(context, animeId: top.anime.id, backLabel: widget.backLabel);

    return Focus(
      focusNode: _focus,
      autofocus: true,
      onKeyEvent: (_, event) => _onKey(top, event),
      child: Center(
        child: SizedBox(
          width: _cardWidth,
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'Осталось ${queue.length}',
                    style: const TextStyle(color: AppColors.muted),
                  ),
                  const Spacer(),
                  undo,
                ],
              ),
              const SizedBox(height: 8),
              OneTimeTip(
                id: 'swipe-keys',
                text:
                    'Клавиши: → хочу посмотреть, ← не интересно, ↓ пропустить, '
                    '↑ уже смотрел, Backspace вернуть',
                targetAnchor: Alignment.topRight,
                followerAnchor: Alignment.topLeft,
                offset: const Offset(20, 40),
                child: SizedBox(
                  height: _cardHeight,
                  child: Stack(
                    children: [
                      if (next != null)
                        Positioned.fill(
                          child: Transform.scale(
                            scale: 0.94,
                            child: Opacity(
                              opacity: 0.55,
                              child: _SwipeCard(
                                entry: next,
                                shift: Offset.zero,
                              ),
                            ),
                          ),
                        ),
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: open,
                          onPanUpdate: (details) {
                            if (!_busy) {
                              setState(
                                () => _shift += Offset(details.delta.dx, 0),
                              );
                            }
                          },
                          onPanEnd: (_) {
                            if (_busy) return;
                            if (_shift.dx > _threshold) {
                              _decide(top, _Swipe.want);
                            } else if (_shift.dx < -_threshold) {
                              _decide(top, _Swipe.hide);
                            } else {
                              _animate(Offset.zero);
                            }
                          },
                          child: Transform.translate(
                            offset: _shift,
                            child: Transform.rotate(
                              angle: _shift.dx / 1400,
                              child: _SwipeCard(
                                entry: top,
                                shift: _shift,
                                onSeen: () => _decide(top, _Swipe.seen),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _RoundButton(
                    icon: LucideIcons.x,
                    tooltip: 'Не интересно (←)',
                    color: AppColors.dangerText,
                    size: 60,
                    onPressed: () => _decide(top, _Swipe.hide),
                  ),
                  const SizedBox(width: 22),
                  _RoundButton(
                    icon: LucideIcons.skipForward,
                    tooltip: 'Пропустить (↓)',
                    color: AppColors.navIdle,
                    size: 46,
                    onPressed: () => _decide(top, _Swipe.skip),
                  ),
                  const SizedBox(width: 22),
                  _RoundButton(
                    icon: LucideIcons.bookmarkPlus,
                    tooltip: 'Хочу посмотреть (→)',
                    color: AppColors.accentText,
                    size: 60,
                    onPressed: () => _decide(top, _Swipe.want),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Карточка тайтла: постер, название, описание и жанры.
class _SwipeCard extends ConsumerWidget {
  const _SwipeCard({required this.entry, required this.shift, this.onSeen});

  final DiscoverEntry entry;
  final Offset shift;

  /// Кнопка-глаз «Уже смотрел»; у карточки позади её нет.
  final VoidCallback? onSeen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final anime = entry.anime;
    final details = ref.watch(animeDetailsProvider(anime.id)).value?.details;
    final release = anime.release;
    final meta = [
      kindLabel(anime.kind),
      if (anime.year != null) '${anime.year}',
      if (release.availableEpisodes > 0)
        episodesLabel(release.availableEpisodes),
    ].join(' · ');
    final score = anime.score;
    final description = details?.description;
    final genres = details?.genres ?? const <String>[];

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Poster(url: anime.posterUrl),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00000000), Color(0xF20C0B10)],
                  stops: [0.35, 0.82],
                ),
              ),
            ),
            Positioned(
              left: 22,
              right: 22,
              bottom: 22,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    entry.reason,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.accentText,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    anime.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: meta),
                        if (score != null && score > 0) ...[
                          const TextSpan(text: ' · '),
                          const WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Icon(
                              LucideIcons.star,
                              size: 13,
                              color: Color(0xFFFFC857),
                            ),
                          ),
                          TextSpan(text: ' ${score.toStringAsFixed(1)}'),
                        ],
                      ],
                    ),
                    style: const TextStyle(
                      color: Color(0xCCFFFFFF),
                      fontSize: 13,
                    ),
                  ),
                  if (genres.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final genre in genres.take(4)) _Chip(genre),
                      ],
                    ),
                  ],
                  if (description != null && description.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      description,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xE6FFFFFF),
                        fontSize: 13.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Positioned(
              top: 64,
              left: 22,
              child: _Stamp(
                text: 'Хочу посмотреть',
                color: AppColors.accentText,
                opacity: (shift.dx / 130).clamp(0, 1),
                angle: -0.18,
              ),
            ),
            Positioned(
              top: 64,
              right: 22,
              child: _Stamp(
                text: 'Не интересно',
                color: AppColors.dangerText,
                opacity: (-shift.dx / 130).clamp(0, 1),
                angle: 0.18,
              ),
            ),
            Positioned(
              top: 64,
              left: 0,
              right: 0,
              child: Center(
                child: _Stamp(
                  text: 'Уже смотрел',
                  color: Colors.white,
                  opacity: (-shift.dy / 130).clamp(0, 1),
                  angle: 0,
                ),
              ),
            ),
            if (onSeen case final onSeen?)
              Positioned(
                top: 14,
                right: 14,
                child: Tooltip(
                  message: 'Уже смотрел (↑)',
                  child: Material(
                    color: const Color(0x80000000),
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: onSeen,
                      child: const SizedBox.square(
                        dimension: 38,
                        child: Icon(
                          LucideIcons.eye,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Надпись поверх карточки при перетаскивании.
class _Stamp extends StatelessWidget {
  const _Stamp({
    required this.text,
    required this.color,
    required this.opacity,
    required this.angle,
  });

  final String text;
  final Color color;
  final double opacity;
  final double angle;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Transform.rotate(
        angle: angle,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0x99000000),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color, width: 2.5),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

/// Жанр на карточке.
class _Chip extends StatelessWidget {
  const _Chip(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0x33FFFFFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}

/// Круглая кнопка под карточкой.
class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.size,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final Color color;
  final double size;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.card,
        shape: CircleBorder(
          side: BorderSide(color: color.withValues(alpha: 0.5)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          hoverColor: color.withValues(alpha: 0.12),
          child: SizedBox.square(
            dimension: size,
            child: Icon(icon, color: color, size: max(18, size * 0.4)),
          ),
        ),
      ),
    );
  }
}
