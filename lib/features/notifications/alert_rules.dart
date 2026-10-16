import '../../data/database/app_database.dart';
import '../../data/database/settings_repository.dart';
import '../../data/database/watch_status.dart';

/// Сообщать ли о новых сериях тайтла по общей настройке.
bool episodeAlertsByDefault(LibraryEntry entry, AppPrefs prefs) {
  final status = WatchStatus.fromName(entry.status);
  return prefs.notifyEpisodes &&
      (status == WatchStatus.watching || status == WatchStatus.planned);
}

/// Сообщать ли о новых сериях тайтла.
bool episodeAlerts(LibraryEntry entry, AppPrefs prefs) {
  if (entry.muted) return false;
  if (entry.alertsOn) return true;
  return episodeAlertsByDefault(entry, prefs);
}

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
