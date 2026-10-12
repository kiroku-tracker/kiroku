import '../shikimori/release_facts.dart';
import 'watch_status.dart';

/// Действия меню статуса.
enum StatusAction {
  watching(WatchStatus.watching, 'Смотрю'),

  planned(WatchStatus.planned, 'Хочу посмотреть'),

  completed(WatchStatus.completed, 'Просмотрено'),

  caughtUp(WatchStatus.watching, 'Всё вышедшее просмотрено'),

  paused(WatchStatus.paused, 'Отложено'),

  dropped(WatchStatus.dropped, 'Брошено');

  const StatusAction(this.status, this.label);

  final WatchStatus status;
  final String label;

  static StatusAction forStatus(WatchStatus status) => switch (status) {
    WatchStatus.watching => StatusAction.watching,
    WatchStatus.planned => StatusAction.planned,
    WatchStatus.completed => StatusAction.completed,
    WatchStatus.paused => StatusAction.paused,
    WatchStatus.dropped => StatusAction.dropped,
  };

  /// Доступные действия для тайтла.
  static List<StatusAction> availableFor(ReleaseFacts release) {
    if (release.isAnnounced) return const [StatusAction.planned];
    return [
      StatusAction.watching,
      StatusAction.planned,
      if (release.canComplete) StatusAction.completed,
      if (release.isOngoing && release.availableEpisodes > 0)
        StatusAction.caughtUp,
      StatusAction.paused,
      StatusAction.dropped,
    ];
  }
}
