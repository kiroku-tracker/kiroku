import 'package:drift/drift.dart';

import '../shikimori/anime_info.dart';
import 'app_database.dart';
import 'library_repository.dart';
import 'status_action.dart';

/// Активная очередь франшизы.
class ActiveQueue {
  const ActiveQueue({required this.queue, required this.items});

  final WatchQueue queue;

  final List<WatchQueueItem> items;

  String get franchiseKey => queue.franchiseKey;

  WatchQueueItem? get active =>
      items.where((item) => item.state == 'active').firstOrNull;

  int get activePosition => active == null ? 0 : items.indexOf(active!) + 1;

  String? stateOf(int animeId) =>
      items.where((item) => item.animeId == animeId).firstOrNull?.state;
}

/// Часть для очереди.
class QueuePlanItem {
  const QueuePlanItem({
    required this.anime,
    required this.inLibrary,
    required this.mode,
    this.done = false,
  });

  final AnimeInfo anime;
  final bool inLibrary;

  final String mode;

  final bool done;
}

/// Переход очереди к следующей части.
class QueueStep {
  const QueueStep({required this.undo, this.next, this.finished = false});

  final Future<void> Function() undo;

  final Anime? next;

  final bool finished;
}

/// Очереди просмотра франшиз.
class QueueRepository {
  QueueRepository(this._db, this._library);

  final AppDatabase _db;
  final LibraryRepository _library;

  Stream<Map<String, ActiveQueue>> watchActive() {
    final query =
        _db.select(_db.watchQueueItems).join([
            innerJoin(
              _db.watchQueues,
              _db.watchQueues.id.equalsExp(_db.watchQueueItems.queueId),
            ),
          ])
          ..where(_db.watchQueues.state.equals('active'))
          ..orderBy([OrderingTerm.asc(_db.watchQueueItems.position)]);
    return query.watch().map((rows) {
      final queues = <String, WatchQueue>{};
      final items = <String, List<WatchQueueItem>>{};
      for (final row in rows) {
        final queue = row.readTable(_db.watchQueues);
        queues[queue.id] = queue;
        items
            .putIfAbsent(queue.id, () => [])
            .add(row.readTable(_db.watchQueueItems));
      }
      return {
        for (final queue in queues.values)
          queue.franchiseKey: ActiveQueue(
            queue: queue,
            items: items[queue.id]!,
          ),
      };
    });
  }

  Future<Future<void> Function()> start(
    String franchiseKey,
    List<QueuePlanItem> plan,
  ) async {
    final libraryUndos = <Future<void> Function()>[];
    final before = await _queuesOf(franchiseKey);
    final now = DateTime.now();
    final queueId = newId();

    for (final part in plan) {
      if (!part.inLibrary) {
        libraryUndos.add(
          (await _library.add(part.anime, StatusAction.planned)).undo,
        );
      }
    }
    await _db.transaction(() async {
      await (_db.update(_db.watchQueues)..where(
            (queue) =>
                queue.franchiseKey.equals(franchiseKey) &
                queue.state.equals('active'),
          ))
          .write(
            WatchQueuesCompanion(
              state: const Value('stopped'),
              updatedAt: Value(now),
            ),
          );
      await _db
          .into(_db.watchQueues)
          .insert(
            WatchQueuesCompanion.insert(
              id: queueId,
              franchiseKey: franchiseKey,
              state: 'active',
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _db.batch((batch) {
        batch.insertAll(_db.watchQueueItems, [
          for (final (index, part) in plan.indexed)
            WatchQueueItemsCompanion.insert(
              queueId: queueId,
              animeId: part.anime.id,
              position: index,
              mode: part.mode,
              state: part.done ? 'done' : 'queued',
            ),
        ]);
      });
    });

    final first = plan.where((part) => !part.done).firstOrNull;
    if (first != null) {
      libraryUndos.add(await _activate(queueId, first.anime.id, first.mode));
    } else {
      await _setQueueState(queueId, 'finished');
    }

    return () async {
      for (final undo in libraryUndos.reversed) {
        await undo();
      }
      await _restoreQueues(franchiseKey, before);
    };
  }

  /// Переводит очередь на следующую часть.
  Future<QueueStep?> onFinished(int animeId) async {
    final row =
        await (_db.select(_db.watchQueueItems).join([
              innerJoin(
                _db.watchQueues,
                _db.watchQueues.id.equalsExp(_db.watchQueueItems.queueId),
              ),
            ])..where(
              _db.watchQueueItems.animeId.equals(animeId) &
                  _db.watchQueueItems.state.equals('active') &
                  _db.watchQueues.state.equals('active'),
            ))
            .getSingleOrNull();
    if (row == null) return null;
    final queue = row.readTable(_db.watchQueues);
    final before = await _queuesOf(queue.franchiseKey);

    await _setItemState(queue.id, animeId, 'done');
    final next =
        await (_db.select(_db.watchQueueItems)
              ..where(
                (item) =>
                    item.queueId.equals(queue.id) & item.state.equals('queued'),
              )
              ..orderBy([(item) => OrderingTerm.asc(item.position)])
              ..limit(1))
            .getSingleOrNull();

    Future<void> Function()? libraryUndo;
    Anime? nextAnime;
    if (next == null) {
      await _setQueueState(queue.id, 'finished');
    } else {
      libraryUndo = await _activate(queue.id, next.animeId, next.mode);
      nextAnime = await (_db.select(
        _db.animes,
      )..where((anime) => anime.id.equals(next.animeId))).getSingle();
    }
    return QueueStep(
      next: nextAnime,
      finished: next == null,
      undo: () async {
        await libraryUndo?.call();
        await _restoreQueues(queue.franchiseKey, before);
      },
    );
  }

  Future<Future<void> Function()> stop(String franchiseKey) async {
    final before = await _queuesOf(franchiseKey);
    await (_db.update(_db.watchQueues)..where(
          (queue) =>
              queue.franchiseKey.equals(franchiseKey) &
              queue.state.equals('active'),
        ))
        .write(
          WatchQueuesCompanion(
            state: const Value('stopped'),
            updatedAt: Value(DateTime.now()),
          ),
        );
    return () => _restoreQueues(franchiseKey, before);
  }

  /// Делает часть текущей.
  Future<Future<void> Function()> _activate(
    String queueId,
    int animeId,
    String mode,
  ) async {
    await _setItemState(queueId, animeId, 'active');
    final entry = await (_db.select(
      _db.libraryEntries,
    )..where((row) => row.animeId.equals(animeId))).getSingle();
    final change = mode == 'restart' && entry.status != 'completed'
        ? await _library.restartViewing(animeId)
        : await _library.applyAction(animeId, StatusAction.watching);
    return change.undo;
  }

  Future<void> _setItemState(String queueId, int animeId, String state) =>
      (_db.update(_db.watchQueueItems)..where(
            (item) =>
                item.queueId.equals(queueId) & item.animeId.equals(animeId),
          ))
          .write(WatchQueueItemsCompanion(state: Value(state)));

  Future<void> _setQueueState(String queueId, String state) =>
      (_db.update(
        _db.watchQueues,
      )..where((queue) => queue.id.equals(queueId))).write(
        WatchQueuesCompanion(
          state: Value(state),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<(List<WatchQueue>, List<WatchQueueItem>)> _queuesOf(
    String franchiseKey,
  ) async {
    final queues = await (_db.select(
      _db.watchQueues,
    )..where((queue) => queue.franchiseKey.equals(franchiseKey))).get();
    final items = await (_db.select(
      _db.watchQueueItems,
    )..where((item) => item.queueId.isIn(queues.map((q) => q.id)))).get();
    return (queues, items);
  }

  /// Восстанавливает очереди из снимка.
  Future<void> _restoreQueues(
    String franchiseKey,
    (List<WatchQueue>, List<WatchQueueItem>) snapshot,
  ) {
    final (queues, items) = snapshot;
    return _db.transaction(() async {
      final current = await _queuesOf(franchiseKey);
      final ids = current.$1.map((queue) => queue.id);
      await (_db.delete(
        _db.watchQueueItems,
      )..where((item) => item.queueId.isIn(ids))).go();
      await (_db.delete(
        _db.watchQueues,
      )..where((queue) => queue.id.isIn(ids))).go();
      await _db.batch((batch) {
        batch.insertAll(_db.watchQueues, [
          for (final queue in queues) queue.toCompanion(false),
        ]);
        batch.insertAll(_db.watchQueueItems, [
          for (final item in items) item.toCompanion(false),
        ]);
      });
    });
  }
}
