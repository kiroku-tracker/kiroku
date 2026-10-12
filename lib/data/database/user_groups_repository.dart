import 'package:drift/drift.dart';

import 'app_database.dart';
import 'franchise_rules.dart';
import 'library_repository.dart';

class UserGroupsRepository {
  UserGroupsRepository(this._db);

  final AppDatabase _db;

  /// Группы по дате создания.
  Stream<List<UserGroup>> watchGroups() =>
      (_db.select(_db.userGroups)
            ..where((group) => group.deletedAt.isNull())
            ..orderBy([(group) => OrderingTerm.asc(group.createdAt)]))
          .watch();

  Stream<Map<String, Set<String>>> watchMembers() =>
      (_db.select(
        _db.userGroupMembers,
      )..where((member) => member.deletedAt.isNull())).watch().map((rows) {
        final result = <String, Set<String>>{};
        for (final row in rows) {
          result.putIfAbsent(row.groupId, () => {}).add(row.memberKey);
        }
        return result;
      });

  Future<String> create(String name) async {
    final id = newId();
    final now = DateTime.now();
    await _db
        .into(_db.userGroups)
        .insert(
          UserGroupsCompanion.insert(
            id: id,
            name: name,
            createdAt: now,
            updatedAt: now,
          ),
        );
    return id;
  }

  Future<void> rename(String id, String name) =>
      (_db.update(_db.userGroups)..where((group) => group.id.equals(id))).write(
        UserGroupsCompanion(
          name: Value(name),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<Future<void> Function()> delete(String id) async {
    Future<void> write(DateTime? deletedAt) =>
        (_db.update(
          _db.userGroups,
        )..where((group) => group.id.equals(id))).write(
          UserGroupsCompanion(
            deletedAt: Value(deletedAt),
            updatedAt: Value(DateTime.now()),
          ),
        );
    await write(DateTime.now());
    return () => write(null);
  }

  /// Добавляет в группу или убирает из неё.
  Future<Future<void> Function()> setMember(
    String groupId,
    String memberKey, {
    required bool member,
  }) async {
    final before =
        await (_db.select(_db.userGroupMembers)..where(
              (row) =>
                  row.groupId.equals(groupId) & row.memberKey.equals(memberKey),
            ))
            .getSingleOrNull();
    final now = DateTime.now();
    await _db
        .into(_db.userGroupMembers)
        .insertOnConflictUpdate(
          UserGroupMembersCompanion(
            groupId: Value(groupId),
            memberKey: Value(memberKey),
            addedAt: member || before == null
                ? Value(now)
                : Value(before.addedAt),
            updatedAt: Value(now),
            deletedAt: Value(member ? null : now),
          ),
        );
    return () async {
      if (before == null) {
        await (_db.delete(_db.userGroupMembers)..where(
              (row) =>
                  row.groupId.equals(groupId) & row.memberKey.equals(memberKey),
            ))
            .go();
      } else {
        await _db
            .into(_db.userGroupMembers)
            .insertOnConflictUpdate(before.toCompanion(false));
      }
    };
  }
}

/// Ключ франшизы в группе.
String franchiseMemberKey(String franchiseKey) => 'f:$franchiseKey';

/// Ключ тайтла в группе.
String memberKeyOf(LibraryItem item) {
  final key = franchiseKeyOf(item.entry, item.anime);
  return key != null ? franchiseMemberKey(key) : 'a:${item.anime.id}';
}

List<LibraryItem> groupItems(List<LibraryItem> library, Set<String> members) {
  final keys = <String>{
    for (final member in members)
      if (member.startsWith('f:')) member.substring(2),
  };
  final ids = <int>{
    for (final member in members)
      if (member.startsWith('a:')) ?int.tryParse(member.substring(2)),
  };
  for (final item in library) {
    if (ids.contains(item.anime.id)) {
      final key = franchiseKeyOf(item.entry, item.anime);
      if (key != null) keys.add(key);
    }
  }
  return [
    for (final item in library)
      if (ids.contains(item.anime.id) ||
          keys.contains(franchiseKeyOf(item.entry, item.anime)))
        item,
  ];
}

Set<String> groupsOf(LibraryItem item, Map<String, Set<String>> members) {
  final key = franchiseKeyOf(item.entry, item.anime);
  return {
    for (final MapEntry(key: groupId, value: keys) in members.entries)
      if (keys.contains('a:${item.anime.id}') ||
          (key != null && keys.contains(franchiseMemberKey(key))))
        groupId,
  };
}
