import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../database/library_repository.dart';

/// Свои ссылки на просмотр.
class WatchLinksRepository {
  WatchLinksRepository(this._db);

  final AppDatabase _db;

  Stream<List<WatchLink>> watchLinks(int animeId) =>
      (_db.select(_db.watchLinks)
            ..where(
              (link) => link.animeId.equals(animeId) & link.deletedAt.isNull(),
            )
            ..orderBy([(link) => OrderingTerm.asc(link.createdAt)]))
          .watch();

  Future<void> add(int animeId, String label, String url) {
    final now = DateTime.now();
    return _db
        .into(_db.watchLinks)
        .insert(
          WatchLinksCompanion.insert(
            id: newId(),
            animeId: animeId,
            label: label,
            url: url,
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<void> edit(String id, String label, String url) =>
      (_db.update(_db.watchLinks)..where((link) => link.id.equals(id))).write(
        WatchLinksCompanion(
          label: Value(label),
          url: Value(url),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<Future<void> Function()> remove(String id) async {
    Future<void> write(DateTime? deletedAt) =>
        (_db.update(_db.watchLinks)..where((link) => link.id.equals(id))).write(
          WatchLinksCompanion(
            deletedAt: Value(deletedAt),
            updatedAt: Value(DateTime.now()),
          ),
        );
    await write(DateTime.now());
    return () => write(null);
  }
}
