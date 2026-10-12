import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/labels.dart';
import '../../data/database/app_database.dart';
import '../../data/database/status_action.dart';
import '../../data/database/watch_status.dart';
import 'library_actions.dart';

/// Кнопка отметки следующей серии.
class NextEpisodeButton extends ConsumerWidget {
  const NextEpisodeButton({
    super.key,
    required this.anime,
    required this.status,
    required this.next,
    required this.watched,
    this.short = false,
  });

  final Anime anime;
  final WatchStatus status;

  final int next;

  final int watched;
  final bool short;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final release = anime.release;
    final available = release.availableEpisodes;

    if (release.isAnnounced) {
      return OutlinedButton.icon(
        onPressed: null,
        icon: const Icon(LucideIcons.clock),
        label: const Text('Ещё не вышло'),
      );
    }

    if (release.canComplete &&
        status == WatchStatus.completed &&
        watched >= available) {
      return OutlinedButton.icon(
        onPressed: () => changeStatus(
          ref,
          animeId: anime.id,
          title: anime.title,
          action: StatusAction.watching,
        ),
        icon: const Icon(LucideIcons.rotateCcw),
        label: Text(short ? 'Заново' : 'Смотреть заново'),
      );
    }

    if (next > available) {
      final nextAt = anime.nextEpisodeAt;
      return Tooltip(
        message: nextAt == null
            ? 'Дата следующей серии пока не объявлена'
            : 'Серия ${release.aired + 1}: ${formatDateTime(nextAt)}',
        child: OutlinedButton.icon(
          onPressed: null,
          icon: const Icon(LucideIcons.checkCheck),
          label: Text(short ? 'Нет новых' : 'Все вышедшие просмотрены'),
        ),
      );
    }
    return OutlinedButton.icon(
      onPressed: () =>
          markNextEpisode(ref, animeId: anime.id, title: anime.title),
      icon: const Icon(LucideIcons.circleCheck),
      label: Text(
        short ? 'Серия $next' : 'Следующая серия · $next',
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
