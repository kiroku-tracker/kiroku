import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/labels.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/status_menu.dart';
import '../../data/providers.dart';
import '../../data/database/app_database.dart';
import '../../data/database/library_repository.dart';
import '../../data/database/status_action.dart';
import '../../data/database/watch_status.dart';
import '../library/library_actions.dart';
import 'watch_actions.dart';

/// Какую серию открыть кнопкой просмотра и как её подписать.
class WatchNext {
  const WatchNext({
    required this.label,
    required this.icon,
    this.tooltip,
    this.episode,
    this.restart = false,
  });

  factory WatchNext.of(
    Anime anime, {
    required WatchStatus status,
    required int next,
    required int watched,
  }) {
    final release = anime.release;
    final available = release.availableEpisodes;
    if (release.isAnnounced) {
      return const WatchNext(label: 'Ещё не вышло', icon: LucideIcons.clock);
    }
    if (release.canComplete &&
        status == WatchStatus.completed &&
        watched >= available) {
      return const WatchNext(
        label: 'Смотреть заново',
        icon: LucideIcons.rotateCcw,
        episode: 1,
        restart: true,
      );
    }
    if (next > available) {
      final nextAt = anime.nextEpisodeAt;
      return WatchNext(
        label: 'Нет новых серий',
        icon: LucideIcons.checkCheck,
        tooltip: nextAt == null
            ? 'Дата следующей серии пока не объявлена'
            : 'Серия ${release.aired + 1}: ${formatDateTime(nextAt)}',
      );
    }
    return WatchNext(
      label: 'Смотреть · серия $next',
      icon: LucideIcons.play,
      episode: next,
    );
  }

  final String label;
  final IconData icon;
  final String? tooltip;

  final int? episode;

  final bool restart;
}

/// Открывает серию кнопки просмотра; «Смотреть заново» начинает новый
/// просмотр.
Future<void> runWatchNext(WidgetRef ref, Anime anime, WatchNext next) async {
  final episode = next.episode;
  if (episode == null) return;
  if (next.restart) {
    await changeStatus(
      ref,
      animeId: anime.id,
      title: anime.title,
      action: StatusAction.watching,
    );
  }
  await watchEpisode(ref, anime, episode);
}

/// Кнопка «Смотреть · серия N» на карточке.
class WatchNextButton extends ConsumerStatefulWidget {
  const WatchNextButton({
    super.key,
    required this.anime,
    required this.status,
    required this.next,
    required this.watched,
    this.height = 40,
    this.whenWatched,
  });

  final Anime anime;
  final WatchStatus status;
  final int next;
  final int watched;
  final double height;

  /// Что показать вместо кнопки, если тайтл просмотрен целиком.
  final Widget? whenWatched;

  @override
  ConsumerState<WatchNextButton> createState() => _WatchNextButtonState();
}

class _WatchNextButtonState extends ConsumerState<WatchNextButton> {
  bool _busy = false;

  Future<void> _run(WatchNext next) async {
    setState(() => _busy = true);
    try {
      await runWatchNext(ref, widget.anime, next);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final next = WatchNext.of(
      widget.anime,
      status: widget.status,
      next: widget.next,
      watched: widget.watched,
    );
    final style = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(Size(0, widget.height)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 12),
      ),
    );
    final label = Text(next.label, overflow: TextOverflow.ellipsis);
    final whenWatched = widget.whenWatched;
    if (next.restart && whenWatched != null) return whenWatched;
    final Widget button;
    if (next.episode == null) {
      button = OutlinedButton.icon(
        onPressed: null,
        style: style,
        icon: Icon(next.icon, size: 16),
        label: label,
      );
    } else {
      button = FilledButton.icon(
        onPressed: _busy ? null : () => _run(next),
        style: style,
        icon: _busy
            ? const SizedBox.square(
                dimension: 15,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(next.icon, size: 16),
        label: label,
      );
    }
    return SizedBox(
      width: double.infinity,
      height: widget.height,
      child: next.tooltip == null
          ? button
          : Tooltip(message: next.tooltip!, child: button),
    );
  }
}

/// Пункты меню правого клика по карточке тайтла.
List<Widget> titleCardMenu(
  WidgetRef ref,
  LibraryItem item, {
  String markSuffix = '',
}) {
  final anime = item.anime;
  final next = item.progress.nextEpisode;
  final release = anime.release;
  final canMark = !release.isAnnounced && next <= release.availableEpisodes;
  return [
    if (canMark)
      AppMenuItem(
        label: 'Отметить серию $next$markSuffix',
        icon: LucideIcons.circleCheck,
        color: AppColors.menuItemText,
        onPressed: () =>
            markNextEpisode(ref, animeId: anime.id, title: anime.title),
      ),
    AppMenuItem(
      label: 'Смотреть в Kiroku',
      icon: LucideIcons.monitorPlay,
      color: AppColors.menuItemText,
      onPressed: () =>
          watchOnSite(ref, anime, inApp: true, episode: canMark ? next : null),
    ),
    AppMenuItem(
      label: 'Открыть в браузере',
      icon: LucideIcons.globe,
      color: AppColors.menuItemText,
      onPressed: () => watchOnSite(ref, anime, inApp: false),
    ),
    if (markSuffix.isEmpty)
      AppMenuItem(
        label: item.entry.favorite ? 'Убрать из избранного' : 'В избранное',
        icon: LucideIcons.heart,
        color: AppColors.menuItemText,
        onPressed: () => ref
            .read(libraryRepositoryProvider)
            .setFavorite(anime.id, !item.entry.favorite),
      ),
  ];
}
