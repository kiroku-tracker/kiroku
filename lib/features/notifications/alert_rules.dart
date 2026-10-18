import '../../data/database/app_database.dart';
import '../../data/database/settings_repository.dart';
import '../../data/database/watch_status.dart';

/// Уведомления о сериях тайтла по общей настройке: у «Смотрю» о каждой
/// серии.
EpisodeAlertMode defaultAlertMode(LibraryEntry entry, AppPrefs prefs) =>
    switch (WatchStatus.fromName(entry.status)) {
      WatchStatus.watching => EpisodeAlertMode.episodes,
      WatchStatus.planned => prefs.alertPlanned,
      _ => EpisodeAlertMode.off,
    };

/// Уведомления о сериях, выбранные у тайтла отдельно.
EpisodeAlertMode? ownAlertMode(LibraryEntry entry) =>
    EpisodeAlertMode.values.asNameMap()[entry.alertMode];

/// Уведомления о сериях тайтла.
EpisodeAlertMode alertModeOf(LibraryEntry entry, AppPrefs prefs) =>
    ownAlertMode(entry) ?? defaultAlertMode(entry, prefs);

/// Сообщать ли о новых сезонах франшизы.
bool seasonAlerts(Franchise? franchise, AppPrefs prefs) {
  if (franchise?.muted ?? false) return false;
  if (franchise?.alertsOn ?? false) return true;
  return prefs.notifyFranchises;
}

/// Флаги для нужного состояния: совпадает с общей настройкой или задано
/// отдельно.
({bool muted, bool alertsOn}) alertFlags({
  required bool on,
  required bool byDefault,
}) => on == byDefault
    ? (muted: false, alertsOn: false)
    : (muted: !on, alertsOn: on);
