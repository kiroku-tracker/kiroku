import 'package:drift/drift.dart';

import 'app_database.dart';

/// Уведомления центра уведомлений.
class NoticesRepository {
  NoticesRepository(this._db);

  final AppDatabase _db;

  static const keep = 200;

  /// Последние уведомления, новые сверху.
  Stream<List<Notice>> watchAll() =>
      (_db.select(_db.notices)
            ..orderBy([
              (notice) => OrderingTerm.desc(notice.createdAt),
              (notice) => OrderingTerm.desc(notice.id),
            ])
            ..limit(keep))
          .watch();

  /// Число непрочитанных.
  Stream<int> watchUnread() {
    final count = _db.notices.id.count();
    final query = _db.selectOnly(_db.notices)
      ..addColumns([count])
      ..where(_db.notices.read.equals(false));
    return query.watchSingle().map((row) => row.read(count) ?? 0);
  }

  /// Добавляет уведомления и удаляет самые старые сверх [keep].
  Future<void> add(
    List<({String category, int animeId, String title, String body})> items,
  ) async {
    if (items.isEmpty) return;
    final now = DateTime.now();
    await _db.batch((batch) {
      batch.insertAll(_db.notices, [
        for (final item in items)
          NoticesCompanion.insert(
            category: item.category,
            animeId: item.animeId,
            title: item.title,
            body: item.body,
            createdAt: now,
          ),
      ]);
    });
    final old =
        await (_db.select(_db.notices)
              ..orderBy([(notice) => OrderingTerm.desc(notice.id)])
              ..limit(1, offset: keep))
            .getSingleOrNull();
    if (old != null) {
      await (_db.delete(
        _db.notices,
      )..where((notice) => notice.id.isSmallerOrEqualValue(old.id))).go();
    }
  }

  /// Последнее уведомление каждого тайтла из [animeIds].
  Future<Map<int, Notice>> latestFor(Iterable<int> animeIds) async {
    final rows =
        await (_db.select(_db.notices)
              ..where((notice) => notice.animeId.isIn(animeIds))
              ..orderBy([(notice) => OrderingTerm.asc(notice.id)]))
            .get();
    return {for (final row in rows) row.animeId: row};
  }

  Future<void> markAllRead() =>
      (_db.update(_db.notices)..where((notice) => notice.read.equals(false)))
          .write(const NoticesCompanion(read: Value(true)));
}
