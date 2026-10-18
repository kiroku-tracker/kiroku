import 'app_database.dart';
import 'library_repository.dart';
import 'watch_status.dart';

const hiddenFranchiseKinds = {'music', 'cm', 'pv'};

String? franchiseKeyOf(LibraryEntry entry, Anime anime) {
  final override = entry.franchiseOverride;
  if (override != null) return override.isEmpty ? null : override;
  final key = anime.franchise;
  return key == null || key.isEmpty ? null : key;
}

bool isCustomFranchise(String key) => key.startsWith('custom:');

/// Порядок просмотра франшизы.
class WatchOrder {
  const WatchOrder({required this.main, required this.extra});

  final List<Anime> main;

  final List<Anime> extra;

  bool get isEmpty => main.isEmpty && extra.isEmpty;
}

/// Делит франшизу на основную линию и дополнительные части.
WatchOrder buildWatchOrder(
  List<Anime> parts,
  Iterable<AnimeRelation> relations,
) {
  final visible = [
    for (final part in parts)
      if (!hiddenFranchiseKinds.contains(part.kind)) part,
  ];
  final ids = {for (final part in visible) part.id};
  final byId = {for (final part in visible) part.id: part};

  final derived = <int>{};
  final chain = <int, Set<int>>{};
  final alternatives = <(int, int)>[];
  for (final relation in relations) {
    if (!ids.contains(relation.animeId)) continue;
    if (relation.relation == 'parent_story' ||
        relation.relation == 'full_story') {
      derived.add(relation.animeId);
    }
    if (!ids.contains(relation.relatedId)) continue;
    if (relation.relation == 'sequel' || relation.relation == 'prequel') {
      chain.putIfAbsent(relation.animeId, () => {}).add(relation.relatedId);
      chain.putIfAbsent(relation.relatedId, () => {}).add(relation.animeId);
    }
    if (relation.relation == 'alternative_version' ||
        relation.relation == 'alternative_setting') {
      alternatives.add((relation.animeId, relation.relatedId));
    }
  }

  bool isCore(Anime anime, Set<String> kinds) =>
      kinds.contains(anime.kind) && !derived.contains(anime.id);
  bool hasCore(Set<int> component) =>
      component.any((id) => isCore(byId[id]!, const {'tv', 'ona', 'movie'}));

  final componentOf = <int, Set<int>>{};
  for (final start in ids) {
    if (componentOf.containsKey(start)) continue;
    final component = <int>{start};
    final stack = [start];
    while (stack.isNotEmpty) {
      for (final next in chain[stack.removeLast()] ?? const <int>{}) {
        if (component.add(next)) stack.add(next);
      }
    }
    for (final id in component) {
      componentOf[id] = component;
    }
  }

  final main = <int>{
    for (final component in componentOf.values)
      if (component.length > 1 && hasCore(component)) ...component,
  };
  var grown = main.isNotEmpty;
  while (grown) {
    grown = false;
    for (final (from, to) in alternatives) {
      final other = main.contains(from)
          ? to
          : (main.contains(to) ? from : null);
      if (other == null || main.contains(other)) continue;
      final component = componentOf[other]!;
      if (hasCore(component)) {
        main.addAll(component);
        grown = true;
      }
    }
  }
  if (main.isEmpty) {
    main.addAll([
      for (final part in visible)
        if (isCore(part, const {'tv', 'ona', 'movie', 'ova'})) part.id,
    ]);
  }
  if (main.isEmpty) main.addAll(ids);

  return WatchOrder(
    main: [
      for (final part in visible)
        if (main.contains(part.id)) part,
    ]..sort(compareByAirDate),
    extra: [
      for (final part in visible)
        if (!main.contains(part.id)) part,
    ]..sort(compareByAirDate),
  );
}

/// Сравнение по дате выхода.
int compareByAirDate(Anime a, Anime b) {
  final diff = _dateKey(a.airedOn).compareTo(_dateKey(b.airedOn));
  return diff != 0 ? diff : a.id.compareTo(b.id);
}

/// Ключ сортировки по дате.
String _dateKey(String? airedOn) {
  if (airedOn == null || airedOn.isEmpty) return '9999-99-99';
  final parts = airedOn.split('-');
  return [
    parts[0],
    parts.length > 1 ? parts[1] : '99',
    parts.length > 2 ? parts[2] : '99',
  ].join('-');
}

/// Тайтл или франшиза в библиотеке.
sealed class LibraryUnit {
  const LibraryUnit();
}

class TitleUnit extends LibraryUnit {
  const TitleUnit(this.item, {this.franchiseName});

  final LibraryItem item;

  final String? franchiseName;
}

class FranchiseUnit extends LibraryUnit {
  const FranchiseUnit({
    required this.key,
    required this.name,
    required this.items,
    required this.cover,
    this.all,
  });

  final String key;
  final String name;

  final List<LibraryItem> items;

  final LibraryItem cover;

  /// Все части в библиотеке, если в [items] только части с одним статусом.
  final List<LibraryItem>? all;

  /// Просмотренные серии частей.
  int get watchedEpisodes =>
      items.fold(0, (sum, item) => sum + item.progress.watched);

  /// Вышедшие серии частей.
  int get availableEpisodes =>
      items.fold(0, (sum, item) => sum + item.anime.release.availableEpisodes);

  int get completedCount =>
      items.where((item) => item.status == WatchStatus.completed).length;

  /// Сколько частей уже вышло: невышедшая часть не делает франшизу
  /// недосмотренной.
  int get releasedCount =>
      items.where((item) => !item.anime.release.isAnnounced).length;

  /// Доля просмотренных среди вышедших частей; у частей с одним статусом
  /// доля просмотренных серий.
  double get progress {
    if (all != null) {
      final available = availableEpisodes;
      return available == 0 ? 0 : watchedEpisodes / available;
    }
    return releasedCount == 0 ? 0 : completedCount / releasedCount;
  }

  int countOf(WatchStatus status) =>
      items.where((item) => item.status == status).length;

  bool has(WatchStatus status) => items.any((item) => item.status == status);

  double? get averageScore => averageScoreOf(items);
}

double? averageScoreOf(Iterable<LibraryItem> items) {
  final scores = [
    for (final item in items)
      if (item.entry.score != null) item.entry.score!,
  ];
  if (scores.isEmpty) return null;
  return scores.reduce((a, b) => a + b) / scores.length;
}

String franchiseName(Franchise? row, List<LibraryItem> items) {
  final custom = row?.name;
  if (custom != null && custom.isNotEmpty) return custom;
  final auto = row?.autoName;
  if (auto != null && auto.isNotEmpty) return auto;
  if (items.isEmpty) return 'Франшиза';
  final sorted = [...items]..sort((a, b) => compareByAirDate(a.anime, b.anime));
  return sorted.first.anime.title;
}

/// Собирает тайтлы во франшизы.
List<LibraryUnit> groupLibrary(
  List<LibraryItem> items,
  Map<String, Franchise> franchises,
) {
  final byKey = <String, List<LibraryItem>>{};
  final units = <LibraryUnit>[];
  for (final item in items) {
    final key = franchiseKeyOf(item.entry, item.anime);
    if (key == null) {
      units.add(TitleUnit(item));
    } else {
      byKey.putIfAbsent(key, () => []).add(item);
    }
  }
  for (final MapEntry(:key, value: parts) in byKey.entries) {
    if (parts.length == 1) {
      units.add(TitleUnit(parts.single));
      continue;
    }
    parts.sort((a, b) => compareByAirDate(a.anime, b.anime));
    final row = franchises[key];
    units.add(
      FranchiseUnit(
        key: key,
        name: franchiseName(row, parts),
        items: parts,
        cover: parts.firstWhere(
          (item) => item.anime.id == row?.coverAnimeId,
          orElse: () => parts.first,
        ),
      ),
    );
  }
  return units;
}
