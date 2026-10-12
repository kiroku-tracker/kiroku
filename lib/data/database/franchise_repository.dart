import 'package:drift/drift.dart';

import '../shikimori/shikimori_client.dart';
import 'app_database.dart';
import 'franchise_rules.dart';
import 'library_repository.dart';

class FranchiseRepository {
  FranchiseRepository(this._db, this._library);

  final AppDatabase _db;
  final LibraryRepository _library;

  static const refreshAfter = Duration(days: 2);

  /// Франшизы по ключу.
  Stream<Map<String, Franchise>> watchFranchises() => _db
      .select(_db.franchises)
      .watch()
      .map((rows) => {for (final row in rows) row.key: row});

  Stream<List<Anime>> watchParts(String key) => (_db.select(
    _db.animes,
  )..where((anime) => anime.franchise.equals(key))).watch();

  /// Связи между частями франшизы.
  Stream<List<AnimeRelation>> watchRelations(String key) {
    final query = _db.select(_db.animeRelations).join([
      innerJoin(
        _db.animes,
        _db.animes.id.equalsExp(_db.animeRelations.animeId),
      ),
    ])..where(_db.animes.franchise.equals(key));
    return query.watch().map(
      (rows) => [for (final row in rows) row.readTable(_db.animeRelations)],
    );
  }

  /// Франшизы, которые нужно загрузить.
  Future<List<int>> franchisesToLoad() async {
    final query = _db.select(_db.libraryEntries).join([
      innerJoin(
        _db.animes,
        _db.animes.id.equalsExp(_db.libraryEntries.animeId),
      ),
    ])..where(_db.libraryEntries.deletedAt.isNull());
    final byKey = <String, List<int>>{};
    for (final row in await query.get()) {
      final anime = row.readTable(_db.animes);
      final key = anime.franchise;
      if (key == null || key.isEmpty) continue;
      byKey.putIfAbsent(key, () => []).add(anime.id);
    }
    final loaded = {
      for (final row in await _db.select(_db.franchises).get())
        row.key: row.partsLoadedAt,
    };
    final now = DateTime.now();
    return [
      for (final MapEntry(:key, value: ids) in byKey.entries)
        if (_isStale(loaded[key], now)) ids.first,
    ];
  }

  /// Нужно ли загрузить франшизу.
  Future<bool> needsLoading(String key) async {
    final row = await (_db.select(
      _db.franchises,
    )..where((row) => row.key.equals(key))).getSingleOrNull();
    return _isStale(row?.partsLoadedAt, DateTime.now());
  }

  static bool _isStale(DateTime? loadedAt, DateTime now) =>
      loadedAt == null || now.difference(loadedAt) > refreshAfter;

  /// Сохраняет части франшизы и возвращает новые.
  Future<List<Anime>> saveParts(FranchiseParts data) {
    return _db.transaction(() async {
      final ids = [for (final part in data.parts) part.id];
      final previous = await (_db.select(
        _db.franchises,
      )..where((row) => row.key.equals(data.key))).getSingleOrNull();
      final known = {
        for (final anime in await (_db.select(
          _db.animes,
        )..where((anime) => anime.franchise.equals(data.key))).get())
          anime.id,
      };
      for (final part in data.parts) {
        await _library.saveAnime(part);
      }
      await (_db.delete(
        _db.animeRelations,
      )..where((row) => row.animeId.isIn(ids))).go();
      await _db.batch((batch) {
        batch.insertAllOnConflictUpdate(_db.animeRelations, [
          for (final part in data.parts)
            for (final relation in part.relations ?? const [])
              AnimeRelationsCompanion.insert(
                animeId: part.id,
                relatedId: relation.relatedId,
                relation: relation.relation,
              ),
        ]);
      });

      final parts = await (_db.select(
        _db.animes,
      )..where((anime) => anime.franchise.equals(data.key))).get();
      final relations = await (_db.select(
        _db.animeRelations,
      )..where((row) => row.animeId.isIn(ids))).get();
      final order = buildWatchOrder(parts, relations);
      final first = order.main.isNotEmpty
          ? order.main.first
          : (order.extra.isNotEmpty ? order.extra.first : null);
      final now = DateTime.now();
      await _db
          .into(_db.franchises)
          .insertOnConflictUpdate(
            FranchisesCompanion(
              key: Value(data.key),
              autoName: Value(first?.title),
              partsLoadedAt: Value(now),
              updatedAt: Value(now),
            ),
          );
      if (previous?.partsLoadedAt == null) return const <Anime>[];
      return [
        for (final part in parts)
          if (!known.contains(part.id)) part,
      ];
    });
  }

  Future<Future<void> Function()> rename(String key, String? name) =>
      _editRow(key, (now) => FranchisesCompanion(name: Value(name)));

  /// Меняет обложку франшизы.
  Future<Future<void> Function()> setCover(String key, int? animeId) =>
      _editRow(key, (now) => FranchisesCompanion(coverAnimeId: Value(animeId)));

  /// Меняет озвучку франшизы.
  Future<Future<void> Function()> setDubbing(String key, String? dubbing) =>
      _editRow(key, (now) => FranchisesCompanion(dubbing: Value(dubbing)));

  /// Запоминает озвучку при просмотре.
  Future<void> setDubbingSeen(String key, String dubbing) => _db
      .into(_db.franchises)
      .insert(
        FranchisesCompanion.insert(
          key: key,
          dubbingSeen: Value(dubbing),
          updatedAt: DateTime.now(),
        ),
        onConflict: DoUpdate(
          (_) => FranchisesCompanion(dubbingSeen: Value(dubbing)),
        ),
      );

  Future<Future<void> Function()> _editRow(
    String key,
    FranchisesCompanion Function(DateTime now) edit,
  ) async {
    final before = await (_db.select(
      _db.franchises,
    )..where((row) => row.key.equals(key))).getSingleOrNull();
    final now = DateTime.now();
    await _db
        .into(_db.franchises)
        .insertOnConflictUpdate(
          edit(now).copyWith(key: Value(key), updatedAt: Value(now)),
        );
    return () async {
      if (before == null) {
        await (_db.delete(
          _db.franchises,
        )..where((row) => row.key.equals(key))).go();
      } else {
        await _db
            .into(_db.franchises)
            .insertOnConflictUpdate(before.toCompanion(false));
      }
    };
  }

  /// Создаёт свою франшизу.
  Future<String> createCustom(String name) async {
    final key = 'custom:${newId()}';
    await _db
        .into(_db.franchises)
        .insert(
          FranchisesCompanion.insert(
            key: key,
            name: Value(name),
            updatedAt: DateTime.now(),
          ),
        );
    return key;
  }

  /// Меняет франшизу тайтла.
  Future<Future<void> Function()> setOverride(
    int animeId,
    String? override,
  ) async {
    final entry = await (_db.select(
      _db.libraryEntries,
    )..where((row) => row.animeId.equals(animeId))).getSingle();
    Future<void> write(String? value) =>
        (_db.update(
          _db.libraryEntries,
        )..where((row) => row.id.equals(entry.id))).write(
          LibraryEntriesCompanion(
            franchiseOverride: Value(value),
            updatedAt: Value(DateTime.now()),
          ),
        );
    await write(override);
    return () => write(entry.franchiseOverride);
  }
}
