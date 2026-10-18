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

/// Пункт «Хочу посмотреть» по выходу серий.
PlannedFilter plannedFilterOf(Anime anime) {
  final release = anime.release;
  if (release.isAnnounced) return PlannedFilter.announced;
  if (release.isOngoing) return PlannedFilter.airing;
  return PlannedFilter.available;
}

/// Число тайтлов «Хочу посмотреть» в каждом пункте.
Map<PlannedFilter, int> plannedCounts(List<LibraryItem> items) {
  final counts = <PlannedFilter, int>{};
  for (final item in items) {
    if (item.status != WatchStatus.planned) continue;
    final filter = plannedFilterOf(item.anime);
    counts[filter] = (counts[filter] ?? 0) + 1;
    counts[PlannedFilter.all] = (counts[PlannedFilter.all] ?? 0) + 1;
  }
  return counts;
}

/// Дата следующей серии; у анонса без неё дата премьеры.
DateTime? _nextAt(Anime anime) {
  final release = anime.release;
  if (release.isReleased) return null;
  return anime.nextEpisodeAt ??
      (release.isAnnounced ? premiereAt(anime.airedOn) : null);
}

/// Дата премьеры; без месяца или дня берётся конец года или месяца.
DateTime? premiereAt(String? airedOn) {
  final parts = (airedOn ?? '').split('-');
  final year = int.tryParse(parts.first);
  if (year == null) return null;
  final month = parts.length > 1 ? int.tryParse(parts[1]) : null;
  final day = parts.length > 2 ? int.tryParse(parts[2]) : null;
  if (month == null) return DateTime(year, 12, 31);
  return DateTime(year, month, day ?? DateTime(year, month + 1, 0).day);
}

/// Тайтлы и франшизы для библиотеки.
List<LibraryUnit> libraryUnits(
  List<LibraryItem> items, {
  required WatchStatus? status,
  required String query,
  required KindFilter kind,
  required LibrarySort sort,
  required bool groupFranchises,
  required Map<String, Franchise> franchises,
  bool favorites = false,
  PlannedFilter planned = PlannedFilter.all,
}) {
  final release = status == WatchStatus.planned ? planned : PlannedFilter.all;
  bool fits(LibraryItem item) =>
      release == PlannedFilter.all || plannedFilterOf(item.anime) == release;
  if (favorites) {
    return _favoriteUnits(
      items,
      query: query,
      kind: kind,
      sort: sort,
      groupFranchises: groupFranchises,
      franchises: franchises,
    );
  }
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
        if (fits(item))
          TitleUnit(item, franchiseName: franchiseOf[item.anime.id]),
    ];
  }
  final result = <LibraryUnit>[
    for (final unit in grouped)
      if (unit is FranchiseUnit &&
          status != null &&
          status != WatchStatus.completed)
        ?_onlyParts(unit, (item) => item.status == status && fits(item))
      else if (switch (unit) {
        TitleUnit(:final item) =>
          (status == null || item.status == status) && fits(item),
        FranchiseUnit() => status == null || unit.has(status),
      })
        unit,
  ];
  result.sort(_unitComparator(sort));
  return result;
}

/// Подходящие части франшизы: одна часть показывается тайтлом,
/// несколько собираются во франшизу без остальных частей.
LibraryUnit? _onlyParts(FranchiseUnit unit, bool Function(LibraryItem) keep) {
  final parts = [
    for (final item in unit.items)
      if (keep(item)) item,
  ];
  if (parts.isEmpty) return null;
  if (parts.length == 1) {
    return TitleUnit(parts.single, franchiseName: unit.name);
  }
  return FranchiseUnit(
    key: unit.key,
    name: unit.name,
    items: parts,
    cover: parts.contains(unit.cover) ? unit.cover : parts.first,
    all: unit.items,
  );
}

/// Избранное: отмеченные тайтлы и франшизы целиком.
List<LibraryUnit> _favoriteUnits(
  List<LibraryItem> items, {
  required String query,
  required KindFilter kind,
  required LibrarySort sort,
  required bool groupFranchises,
  required Map<String, Franchise> franchises,
}) {
  final grouped = groupLibrary(items, franchises);
  final franchiseOf = <int, FranchiseUnit>{
    for (final unit in grouped.whereType<FranchiseUnit>())
      for (final item in unit.items) item.anime.id: unit,
  };
  bool favoriteFranchise(FranchiseUnit? unit) =>
      unit != null && (franchises[unit.key]?.favorite ?? false);
  final searching = query.trim().isNotEmpty || kind != KindFilter.all;
  if (!groupFranchises || searching) {
    return [
      for (final item in filterLibrary(
        items,
        status: null,
        query: query,
        kind: kind,
        sort: sort,
      ))
        if (item.entry.favorite ||
            favoriteFranchise(franchiseOf[item.anime.id]))
          TitleUnit(item, franchiseName: franchiseOf[item.anime.id]?.name),
    ];
  }
  final result = <LibraryUnit>[
    for (final unit in grouped)
      ...switch (unit) {
        FranchiseUnit() when favoriteFranchise(unit) => [unit],
        FranchiseUnit(:final items, :final name) => [
          for (final item in items)
            if (item.entry.favorite) TitleUnit(item, franchiseName: name),
        ],
        TitleUnit(:final item) => [if (item.entry.favorite) unit],
      },
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
    FranchiseUnit() => unit.progress,
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
