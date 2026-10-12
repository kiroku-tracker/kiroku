import '../../data/database/app_database.dart';
import '../../data/database/library_repository.dart';
import '../../data/database/watch_status.dart';

/// Серия в календаре.
class CalendarEpisode {
  const CalendarEpisode({
    required this.item,
    required this.at,
    required this.episode,
    required this.estimated,
  });

  final LibraryItem item;

  final DateTime at;
  final int episode;

  final bool estimated;
}

class CalendarWeek {
  const CalendarWeek({
    required this.start,
    required this.days,
    required this.undated,
    required this.announced,
  });

  final DateTime start;

  final List<List<CalendarEpisode>> days;

  final List<LibraryItem> undated;

  final List<LibraryItem> announced;

  bool get isEmpty =>
      days.every((day) => day.isEmpty) && undated.isEmpty && announced.isEmpty;
}

/// Тайтлы для календаря.
bool _inCalendar(LibraryItem item) => const {
  WatchStatus.watching,
  WatchStatus.planned,
  WatchStatus.paused,
}.contains(item.status);

DateTime weekStart(DateTime day) {
  final date = DateTime(day.year, day.month, day.day);
  return DateTime(date.year, date.month, date.day - (date.weekday - 1));
}

/// Неделя календаря со сдвигом.
CalendarWeek buildCalendarWeek(
  List<LibraryItem> items, {
  required DateTime now,
  int weekOffset = 0,
}) {
  final monday = weekStart(now);
  final start = DateTime(
    monday.year,
    monday.month,
    monday.day + 7 * weekOffset,
  );
  final end = DateTime(start.year, start.month, start.day + 7);
  final days = List.generate(7, (_) => <CalendarEpisode>[]);
  final undated = <LibraryItem>[];
  final announced = <LibraryItem>[];

  for (final item in items.where(_inCalendar)) {
    final anime = item.anime;
    final release = anime.release;
    final next = anime.nextEpisodeAt?.toLocal();
    if (release.isAnnounced) {
      announced.add(item);
      if (next != null && !next.isBefore(start) && next.isBefore(end)) {
        days[_dayIndex(start, next)].add(
          CalendarEpisode(item: item, at: next, episode: 1, estimated: false),
        );
      }
      continue;
    }
    if (!release.isOngoing) continue;
    if (next == null) {
      undated.add(item);
      continue;
    }
    final nextEpisode = release.aired + 1;
    final from = (start.difference(next).inHours / (24 * 7)).floor() - 1;
    final to = (end.difference(next).inHours / (24 * 7)).ceil() + 1;
    for (var week = from; week <= to; week++) {
      final episode = nextEpisode + week;
      if (episode < 1) continue;
      if (anime.episodes > 0 && episode > anime.episodes) continue;
      final at = _addWeeks(next, week);
      if (at.isBefore(start) || !at.isBefore(end)) continue;
      days[_dayIndex(start, at)].add(
        CalendarEpisode(
          item: item,
          at: at,
          episode: episode,
          estimated: week != 0,
        ),
      );
    }
  }

  for (final day in days) {
    day.sort((a, b) => a.at.compareTo(b.at));
  }
  undated.sort((a, b) => a.anime.title.compareTo(b.anime.title));
  announced.sort((a, b) {
    final left = a.anime.nextEpisodeAt ?? _airedOn(a.anime);
    final right = b.anime.nextEpisodeAt ?? _airedOn(b.anime);
    if (left == null && right == null) {
      return a.anime.title.compareTo(b.anime.title);
    }
    if (left == null) return 1;
    if (right == null) return -1;
    return left.compareTo(right);
  });
  return CalendarWeek(
    start: start,
    days: days,
    undated: undated,
    announced: announced,
  );
}

/// Сдвиг на несколько недель.
DateTime _addWeeks(DateTime value, int weeks) => DateTime(
  value.year,
  value.month,
  value.day + 7 * weeks,
  value.hour,
  value.minute,
);

/// Номер дня недели.
int _dayIndex(DateTime start, DateTime at) => DateTime.utc(
  at.year,
  at.month,
  at.day,
).difference(DateTime.utc(start.year, start.month, start.day)).inDays;

DateTime? _airedOn(Anime anime) {
  final parts = (anime.airedOn ?? '').split('-');
  final year = int.tryParse(parts.first);
  if (year == null) return null;
  return DateTime(
    year,
    parts.length > 1 ? int.tryParse(parts[1]) ?? 12 : 12,
    parts.length > 2 ? int.tryParse(parts[2]) ?? 28 : 28,
  );
}
