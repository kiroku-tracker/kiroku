import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/labels.dart';
import '../../data/database/app_database.dart';
import '../../data/database/franchise_rules.dart';
import '../../data/database/library_repository.dart';
import '../../data/database/settings_repository.dart';
import '../../data/database/user_groups_repository.dart';
import '../../data/database/watch_status.dart';
import '../../data/providers.dart';
import '../library/library_filter.dart';

/// Группа с содержимым.
class GroupView {
  const GroupView({
    required this.group,
    required this.members,
    required this.items,
    required this.units,
  });

  final UserGroup group;

  final Set<String> members;

  final List<LibraryItem> items;

  final List<LibraryUnit> units;

  int get franchiseCount => units.whereType<FranchiseUnit>().length;

  int get completedCount =>
      items.where((item) => item.status == WatchStatus.completed).length;

  double? get averageScore => averageScoreOf(items);

  List<String?> get coverUrls => [
    for (final unit in units.take(4))
      switch (unit) {
        TitleUnit(:final item) => item.anime.posterUrl,
        FranchiseUnit(:final cover) => cover.anime.posterUrl,
      },
  ];

  String get summary {
    final titles =
        '${items.length} ${plural(items.length, 'тайтл', 'тайтла', 'тайтлов')}';
    final franchises = franchiseCount;
    return franchises == 0
        ? titles
        : '$titles · $franchises '
              '${plural(franchises, 'франшиза', 'франшизы', 'франшиз')}';
  }
}

final groupViewsProvider = Provider<AsyncValue<List<GroupView>>>((ref) {
  final groups = ref.watch(userGroupsProvider);
  final members = ref.watch(groupMembersProvider).value ?? const {};
  final library = ref.watch(libraryItemsProvider).value ?? const [];
  final franchises = ref.watch(franchisesProvider).value ?? const {};
  return groups.whenData(
    (groups) => [
      for (final group in groups)
        _view(group, members[group.id] ?? const {}, library, franchises),
    ],
  );
});

GroupView _view(
  UserGroup group,
  Set<String> members,
  List<LibraryItem> library,
  Map<String, Franchise> franchises,
) {
  final items = groupItems(library, members);
  return GroupView(
    group: group,
    members: members,
    items: items,
    units: libraryUnits(
      items,
      status: null,
      query: '',
      kind: KindFilter.all,
      sort: LibrarySort.updated,
      groupFranchises: true,
      franchises: franchises,
    ),
  );
}
