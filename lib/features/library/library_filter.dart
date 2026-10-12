import '../../core/labels.dart';
import '../../data/database/app_database.dart';
import '../../data/database/franchise_rules.dart';
import '../../data/database/library_repository.dart';
import '../../data/database/settings_repository.dart';
import '../../data/database/watch_status.dart';

/// Фильтр и сортировка библиотеки.
List<LibraryItem> filterLibrary(
  List<LibraryItem> items, {
  required WatchStatus? status,
  required String query,
  required KindFilter kind,
  required LibrarySort sort,
}) {
  final needle = normalizeSearch(query.trim());
  final result = [
    for (final item in items)
      if ((status == null || item.status == status) &&
          kind.matches(item.anime.kind) &&
          (needle.isEmpty || _searchText(item).contains(needle)))
        item,
  ];
  result.sort(_comparator(sort));
  return result;
}

/// Число тайтлов по статусам.
Map<WatchStatus?, int> countByStatus(List<LibraryItem> items) {
  final counts = <WatchStatus?, int>{null: items.length};
  for (final item in items) {
    counts[item.status] = (counts[item.status] ?? 0) + 1;
  }
  return counts;
}

/// Тайтлы для «Продолжить просмотр».
List<LibraryItem> continueWatching(List<LibraryItem> items) {
  final result = [
    for (final item in items)
      if (item.status == WatchStatus.watching && unwatchedAired(item) > 0) item,
  ];
  result.sort((a, b) => b.entry.updatedAt.compareTo(a.entry.updatedAt));
  return result;
}

/// Все вышедшие серии онгоинга просмотрены.
bool isCaughtUp(LibraryItem item) =>
    item.status == WatchStatus.watching &&
    item.anime.release.isOngoing &&
    item.progress.watched > 0 &&
    unwatchedAired(item) == 0;

/// Непросмотренные вышедшие серии.
int unwatchedAired(LibraryItem item) {
  final available = item.anime.release.availableEpisodes;
  final left = available - item.progress.watched;
  return item.progress.nextEpisode <= available && left > 0 ? left : 0;
}

/// Строка для поиска без регистра и «ё».
String normalizeSearch(String value) =>
    value.toLowerCase().replaceAll('ё', 'е');

String _searchText(LibraryItem item) => normalizeSearch(
  [
    item.anime.russian,
    item.anime.name,
    kindLabel(item.anime.kind),
    item.status.label,
    item.entry.note,
  ].join(' '),
);

double _progressRatio(LibraryItem item) {
  final available = item.anime.release.availableEpisodes;
  return available == 0 ? 0 : item.progress.watched / available;
}

int Function(LibraryItem, LibraryItem) _comparator(LibrarySort sort) {
  int byUpdated(LibraryItem a, LibraryItem b) =>
      b.entry.updatedAt.compareTo(a.entry.updatedAt);
  return switch (sort) {
    LibrarySort.updated => byUpdated,
    LibrarySort.added => (a, b) => b.entry.addedAt.compareTo(a.entry.addedAt),
    LibrarySort.title => (a, b) => normalizeSearch(
      a.anime.title,
    ).compareTo(normalizeSearch(b.anime.title)),
    LibrarySort.progress => (a, b) {
      final diff = _progressRatio(b).compareTo(_progressRatio(a));
      return diff != 0 ? diff : byUpdated(a, b);
    },
    LibrarySort.score => (a, b) {
      final diff = (b.entry.score ?? -1).compareTo(a.entry.score ?? -1);
      return diff != 0 ? diff : byUpdated(a, b);
    },
    LibrarySort.nextEpisode => (a, b) {
      final left = _nextAt(a.anime);
      final right = _nextAt(b.anime);
      if (left == null && right == null) return byUpdated(a, b);
      if (left == null) return 1;
      if (right == null) return -1;
      return left.compareTo(right);
    },
  };
}

DateTime? _nextAt(Anime anime) =>
    anime.release.isReleased ? null : anime.nextEpisodeAt;

/// Тайтлы и франшизы для библиотеки.
List<LibraryUnit> libraryUnits(
  List<LibraryItem> items, {
  required WatchStatus? status,
  required String query,
  required KindFilter kind,
  required LibrarySort sort,
  required bool groupFranchises,
  required Map<String, Franchise> franchises,
}) {
  final grouped = groupLibrary(items, franchises);
  final searching = query.trim().isNotEmpty || kind != KindFilter.all;
  if (!groupFranchises || searching) {
    final franchiseOf = <int, String>{
      for (final unit in grouped.whereType<FranchiseUnit>())
        for (final item in unit.items) item.anime.id: unit.name,
    };
    return [
      for (final item in filterLibrary(
        items,
        status: status,
        query: query,
        kind: kind,
        sort: sort,
      ))
        TitleUnit(item, franchiseName: franchiseOf[item.anime.id]),
    ];
  }
  final result = [
    for (final unit in grouped)
      if (switch (unit) {
        TitleUnit(:final item) => status == null || item.status == status,
        FranchiseUnit() => status == null || unit.has(status),
      })
        unit,
  ];
  result.sort(_unitComparator(sort));
  return result;
}

int Function(LibraryUnit, LibraryUnit) _unitComparator(LibrarySort sort) {
  List<LibraryItem> parts(LibraryUnit unit) => switch (unit) {
    TitleUnit(:final item) => [item],
    FranchiseUnit(:final items) => items,
  };
  DateTime latest(LibraryUnit unit, DateTime Function(LibraryItem) date) =>
      parts(unit).map(date).reduce((a, b) => a.isAfter(b) ? a : b);
  int byUpdated(LibraryUnit a, LibraryUnit b) => latest(
    b,
    (item) => item.entry.updatedAt,
  ).compareTo(latest(a, (item) => item.entry.updatedAt));
  String name(LibraryUnit unit) => normalizeSearch(switch (unit) {
    TitleUnit(:final item) => item.anime.title,
    FranchiseUnit(:final name) => name,
  });
  double progress(LibraryUnit unit) => switch (unit) {
    TitleUnit(:final item) => _progressRatio(item),
    FranchiseUnit() => unit.completedCount / unit.items.length,
  };
  double score(LibraryUnit unit) => switch (unit) {
    TitleUnit(:final item) => (item.entry.score ?? -1).toDouble(),
    FranchiseUnit() => unit.averageScore ?? -1,
  };
  DateTime? nextAt(LibraryUnit unit) {
    final dates = [for (final item in parts(unit)) ?_nextAt(item.anime)]
      ..sort();
    return dates.firstOrNull;
  }

  return switch (sort) {
    LibrarySort.updated => byUpdated,
    LibrarySort.added => (a, b) => latest(
      b,
      (item) => item.entry.addedAt,
    ).compareTo(latest(a, (item) => item.entry.addedAt)),
    LibrarySort.title => (a, b) => name(a).compareTo(name(b)),
    LibrarySort.progress => (a, b) {
      final diff = progress(b).compareTo(progress(a));
      return diff != 0 ? diff : byUpdated(a, b);
    },
    LibrarySort.score => (a, b) {
      final diff = score(b).compareTo(score(a));
      return diff != 0 ? diff : byUpdated(a, b);
    },
    LibrarySort.nextEpisode => (a, b) {
      final left = nextAt(a);
      final right = nextAt(b);
      if (left == null && right == null) return byUpdated(a, b);
      if (left == null) return 1;
      if (right == null) return -1;
      return left.compareTo(right);
    },
  };
}

/// Часть франшизы со следующей серией.
LibraryItem? franchiseNextPart(FranchiseUnit unit, {int? preferred}) {
  final queued = unit.items
      .where((item) => item.anime.id == preferred && unwatchedAired(item) > 0)
      .firstOrNull;
  if (queued != null) return queued;
  final candidates = [
    for (final item in unit.items)
      if (item.status == WatchStatus.watching && unwatchedAired(item) > 0) item,
  ]..sort((a, b) => b.entry.updatedAt.compareTo(a.entry.updatedAt));
  return candidates.firstOrNull;
}
