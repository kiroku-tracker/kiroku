import '../database/app_database.dart';

enum DubbingSource { title, franchise, seen, franchiseSeen }

/// Озвучка для уведомлений.
class DubbingChoice {
  const DubbingChoice(this.name, this.source);

  final String name;
  final DubbingSource source;

  bool get automatic =>
      source == DubbingSource.seen || source == DubbingSource.franchiseSeen;
}

/// Озвучка, которую ждать у тайтла.
DubbingChoice? effectiveDubbing(LibraryEntry entry, Franchise? franchise) {
  final own = entry.dubbing;
  if (own != null) {
    return own.isEmpty ? null : DubbingChoice(own, DubbingSource.title);
  }
  final shared = franchise?.dubbing;
  if (shared != null) {
    return shared.isEmpty
        ? null
        : DubbingChoice(shared, DubbingSource.franchise);
  }
  if (entry.dubbingSeen case final seen?) {
    return DubbingChoice(seen, DubbingSource.seen);
  }
  if (franchise?.dubbingSeen case final seen?) {
    return DubbingChoice(seen, DubbingSource.franchiseSeen);
  }
  return null;
}
