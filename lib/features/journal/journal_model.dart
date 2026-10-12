import '../../data/database/app_database.dart';
import '../../data/database/library_repository.dart';

class JournalRow {
  JournalRow(JournalEvent first)
    : anime = first.anime,
      cycle = first.cycle,
      auto = first.event.source == 'auto',
      undated = first.event.watchedAt == null,
      events = [first.event],
      at = first.at;

  final Anime anime;
  final WatchCycle cycle;

  final bool auto;

  final bool undated;
  final List<WatchEvent> events;

  final DateTime at;

  List<int> get episodes => [for (final event in events) event.episode]..sort();

  bool _accepts(JournalEvent next) =>
      next.anime.id == anime.id &&
      next.cycle.id == cycle.id &&
      (next.event.source == 'auto') == auto &&
      (next.event.watchedAt == null) == undated &&
      _sameDay(next.at, at);
}

class JournalDay {
  JournalDay(this.day);

  final DateTime day;
  final rows = <JournalRow>[];
}

/// Раскладывает отметки по дням.
List<JournalDay> groupJournal(List<JournalEvent> events) {
  final days = <JournalDay>[];
  for (final event in events) {
    final at = event.at;
    final day = DateTime(at.year, at.month, at.day);
    if (days.isEmpty || days.last.day != day) days.add(JournalDay(day));
    final rows = days.last.rows;
    if (rows.isNotEmpty && rows.last._accepts(event)) {
      rows.last.events.add(event.event);
    } else {
      rows.add(JournalRow(event));
    }
  }
  return days;
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
