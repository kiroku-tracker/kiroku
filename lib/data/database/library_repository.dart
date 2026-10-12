import 'dart:math';

import 'package:drift/drift.dart';

import '../shikimori/anime_info.dart';
import '../shikimori/user_rate.dart';
import 'app_database.dart';
import 'status_action.dart';
import 'watch_status.dart';

class WatchProgress {
  const WatchProgress({
    this.watched = 0,
    this.cycleNumber = 1,
    this.nextEpisode = 1,
  });

  final int watched;

  final int cycleNumber;

  final int nextEpisode;
}

/// Тайтл библиотеки с прогрессом.
class LibraryItem {
  const LibraryItem({
    required this.entry,
    required this.anime,
    this.progress = const WatchProgress(),
  });

  final LibraryEntry entry;
  final Anime anime;
  final WatchProgress progress;

  WatchStatus get status => WatchStatus.fromName(entry.status);
}

/// Результат изменения с отменой.
class LibraryChange {
  const LibraryChange({
    required this.undo,
    this.markedEpisodes = 0,
    this.startedRewatch = false,
    this.episode,
    this.finished = false,
  });

  final Future<void> Function() undo;

  final int markedEpisodes;

  final bool startedRewatch;

  final int? episode;

  final bool finished;
}

/// Ожидается новый просмотр.
bool isNewViewingPending({
  required String state,
  required WatchStatus status,
}) =>
    state == 'unfinished' ||
    (state == 'completed' && status == WatchStatus.watching);

class CurrentViewing {
  const CurrentViewing({required this.cycle, required this.ordinal});

  final CycleHistory? cycle;

  final int ordinal;

  Map<int, WatchEvent> get events => cycle?.events ?? const {};

  static CurrentViewing of(List<CycleHistory> history, WatchStatus status) {
    if (history.isEmpty) return const CurrentViewing(cycle: null, ordinal: 1);
    final last = history.last;
    return isNewViewingPending(state: last.cycle.state, status: status)
        ? CurrentViewing(cycle: null, ordinal: history.length + 1)
        : CurrentViewing(cycle: last, ordinal: history.length);
  }
}

/// Просмотр с отметками.
class CycleHistory {
  const CycleHistory({required this.cycle, required this.events});

  final WatchCycle cycle;

  final Map<int, WatchEvent> events;

  bool get isCompleted => cycle.state == 'completed';
  bool get isUnfinished => cycle.state == 'unfinished';

  /// Даты первой и последней серии.
  (DateTime?, DateTime?) get dateRange {
    final dates = [
      for (final event in events.values)
        if (event.watchedAt != null) event.watchedAt!,
    ]..sort();
    return dates.isEmpty ? (null, null) : (dates.first, dates.last);
  }
}

/// Отметка для журнала.
class JournalEvent {
  const JournalEvent({
    required this.event,
    required this.cycle,
    required this.anime,
  });

  final WatchEvent event;
  final WatchCycle cycle;
  final Anime anime;

  DateTime get at => (event.watchedAt ?? event.markedAt).toLocal();
}

class ImportResult {
  const ImportResult({
    required this.added,
    required this.replaced,
    required this.skipped,
    required this.undo,
  });

  final int added;

  final int replaced;

  final int skipped;

  final Future<void> Function() undo;
}

class LibraryRepository {
  LibraryRepository(this._db);

  final AppDatabase _db;

  Stream<List<LibraryItem>> watchItems() {
    final query =
        _db.select(_db.libraryEntries).join([
            innerJoin(
              _db.animes,
              _db.animes.id.equalsExp(_db.libraryEntries.animeId),
            ),
          ])
          ..where(_db.libraryEntries.deletedAt.isNull())
          ..orderBy([OrderingTerm.desc(_db.libraryEntries.addedAt)]);
    return query.watch().map(
      (rows) => [
        for (final row in rows)
          LibraryItem(
            entry: row.readTable(_db.libraryEntries),
            anime: row.readTable(_db.animes),
          ),
      ],
    );
  }

  /// Прогресс по записям библиотеки.
  Stream<Map<String, WatchProgress>> watchProgress() {
    return _db
        .customSelect(
          '''
      SELECT c.entry_id AS entry_id, c.state AS state, e.status AS status,
             COUNT(DISTINCT ev.episode) AS watched,
             GROUP_CONCAT(DISTINCT ev.episode) AS episodes
      FROM watch_cycles c
      JOIN library_entries e ON e.id = c.entry_id
      LEFT JOIN watch_events ev ON ev.cycle_id = c.id AND ev.deleted_at IS NULL
      WHERE c.deleted_at IS NULL
      GROUP BY c.id
      ORDER BY c.entry_id, c.number
      ''',
          readsFrom: {_db.libraryEntries, _db.watchCycles, _db.watchEvents},
        )
        .watch()
        .map((rows) {
          final count = <String, int>{};
          final last = <String, QueryRow>{};
          for (final row in rows) {
            final id = row.read<String>('entry_id');
            count[id] = (count[id] ?? 0) + 1;
            last[id] = row;
          }
          return {
            for (final MapEntry(key: id, value: row) in last.entries)
              id:
                  isNewViewingPending(
                    state: row.read<String>('state'),
                    status: WatchStatus.fromName(row.read<String>('status')),
                  )
                  ? WatchProgress(watched: 0, cycleNumber: count[id]! + 1)
                  : WatchProgress(
                      watched: row.read<int>('watched'),
                      cycleNumber: count[id]!,
                      nextEpisode: _firstMissing(
                        row.readNullable<String>('episodes'),
                      ),
                    ),
          };
        });
  }

  /// Первая неотмеченная серия.
  static int _firstMissing(String? episodes) {
    final watched = {
      for (final part in (episodes ?? '').split(',')) ?int.tryParse(part),
    };
    var next = 1;
    while (watched.contains(next)) {
      next++;
    }
    return next;
  }

  /// Тайтлы для обновления из Shikimori.
  Future<List<int>> idsToRefresh() async {
    final query = _db.select(_db.libraryEntries).join([
      innerJoin(
        _db.animes,
        _db.animes.id.equalsExp(_db.libraryEntries.animeId),
      ),
    ])..where(_db.libraryEntries.deletedAt.isNull());
    return [
      for (final row in await query.get())
        if (!row.readTable(_db.animes).release.isReleased ||
            row.readTable(_db.animes).franchise == null)
          row.readTable(_db.animes).id,
    ];
  }

  Future<Map<int, Anime>> animesByIds(Iterable<int> ids) async => {
    for (final anime in await (_db.select(
      _db.animes,
    )..where((anime) => anime.id.isIn(ids))).get())
      anime.id: anime,
  };

  Future<Set<int>> trackedIds() async => {
    for (final entry
        in await (_db.select(_db.libraryEntries)..where(
              (entry) =>
                  entry.deletedAt.isNull() &
                  entry.muted.equals(false) &
                  entry.status.isIn([
                    WatchStatus.watching.name,
                    WatchStatus.planned.name,
                  ]),
            ))
            .get())
      entry.animeId,
  };

  Stream<Anime?> watchAnime(int animeId) => (_db.select(
    _db.animes,
  )..where((anime) => anime.id.equals(animeId))).watchSingleOrNull();

  Stream<LibraryEntry?> watchEntry(int animeId) =>
      (_db.select(_db.libraryEntries)..where(
            (entry) => entry.animeId.equals(animeId) & entry.deletedAt.isNull(),
          ))
          .watchSingleOrNull();

  Stream<List<CycleHistory>> watchHistory(int animeId) {
    final query =
        _db.select(_db.watchCycles).join([
            innerJoin(
              _db.libraryEntries,
              _db.libraryEntries.id.equalsExp(_db.watchCycles.entryId),
            ),
            leftOuterJoin(
              _db.watchEvents,
              _db.watchEvents.cycleId.equalsExp(_db.watchCycles.id) &
                  _db.watchEvents.deletedAt.isNull(),
            ),
          ])
          ..where(
            _db.libraryEntries.animeId.equals(animeId) &
                _db.libraryEntries.deletedAt.isNull() &
                _db.watchCycles.deletedAt.isNull(),
          )
          ..orderBy([OrderingTerm.asc(_db.watchCycles.number)]);
    return query.watch().map((rows) {
      final cycles = <String, WatchCycle>{};
      final events = <String, Map<int, WatchEvent>>{};
      for (final row in rows) {
        final cycle = row.readTable(_db.watchCycles);
        cycles.putIfAbsent(cycle.id, () => cycle);
        final event = row.readTableOrNull(_db.watchEvents);
        final map = events.putIfAbsent(cycle.id, () => {});
        if (event != null) map[event.episode] = event;
      }
      return [
        for (final cycle in cycles.values)
          CycleHistory(cycle: cycle, events: events[cycle.id] ?? const {}),
      ];
    });
  }

  /// Отметки для журнала.
  Stream<List<JournalEvent>> watchJournal({int limit = 300}) {
    final at = coalesce([_db.watchEvents.watchedAt, _db.watchEvents.markedAt]);
    final query =
        _db.select(_db.watchEvents).join([
            innerJoin(
              _db.watchCycles,
              _db.watchCycles.id.equalsExp(_db.watchEvents.cycleId),
            ),
            innerJoin(
              _db.libraryEntries,
              _db.libraryEntries.id.equalsExp(_db.watchCycles.entryId),
            ),
            innerJoin(
              _db.animes,
              _db.animes.id.equalsExp(_db.libraryEntries.animeId),
            ),
          ])
          ..where(
            _db.watchEvents.deletedAt.isNull() &
                _db.watchCycles.deletedAt.isNull() &
                _db.libraryEntries.deletedAt.isNull() &
                (_db.watchEvents.source.isNull() |
                    _db.watchEvents.source.equals('import').not()),
          )
          ..orderBy([
            OrderingTerm.desc(at),
            OrderingTerm.desc(_db.watchEvents.episode),
          ])
          ..limit(limit);
    return query.watch().map(
      (rows) => [
        for (final row in rows)
          JournalEvent(
            event: row.readTable(_db.watchEvents),
            cycle: row.readTable(_db.watchCycles),
            anime: row.readTable(_db.animes),
          ),
      ],
    );
  }

  Stream<Map<int, WatchStatus>> watchStatuses() {
    final query = _db.select(_db.libraryEntries)
      ..where((entry) => entry.deletedAt.isNull());
    return query.watch().map(
      (entries) => {
        for (final entry in entries)
          entry.animeId: WatchStatus.fromName(entry.status),
      },
    );
  }

  /// Добавляет тайтл в библиотеку.
  Future<LibraryChange> add(AnimeInfo anime, StatusAction action) async {
    await saveAnime(anime);
    final snapshot = await _snapshot(anime.id);
    final now = DateTime.now();

    final existing = snapshot.entry;
    if (existing == null) {
      await _db
          .into(_db.libraryEntries)
          .insert(
            LibraryEntriesCompanion.insert(
              id: newId(),
              animeId: anime.id,
              status: WatchStatus.planned.name,
              addedAt: now,
              updatedAt: now,
            ),
          );
    } else if (existing.deletedAt != null) {
      await (_db.update(
        _db.libraryEntries,
      )..where((entry) => entry.id.equals(existing.id))).write(
        LibraryEntriesCompanion(
          addedAt: Value(now),
          updatedAt: Value(now),
          deletedAt: const Value(null),
        ),
      );
    }

    final result = await _apply(anime.id, action);
    return LibraryChange(
      undo: () => _restore(anime.id, snapshot),
      markedEpisodes: result.marked,
      startedRewatch: result.rewatch,
    );
  }

  Future<LibraryChange> applyAction(int animeId, StatusAction action) async {
    final snapshot = await _snapshot(animeId);
    final result = await _apply(animeId, action);
    return LibraryChange(
      undo: () => _restore(animeId, snapshot),
      markedEpisodes: result.marked,
      startedRewatch: result.rewatch,
    );
  }

  /// Отмечает следующую серию.
  Future<LibraryChange> markNextEpisode(int animeId) async {
    final snapshot = await _snapshot(animeId);
    final result = await _db.transaction(() async {
      final entry = await _entryFor(animeId);
      final anime = await (_db.select(
        _db.animes,
      )..where((a) => a.id.equals(animeId))).getSingle();
      final release = anime.release;
      final now = DateTime.now();

      final cycle = await _cycleForEditing(entry, now);

      final watched = {
        for (final event
            in await (_db.select(_db.watchEvents)..where(
                  (event) =>
                      event.cycleId.equals(cycle.id) & event.deletedAt.isNull(),
                ))
                .get())
          event.episode,
      };
      var episode = 1;
      while (watched.contains(episode)) {
        episode++;
      }
      if (episode > release.availableEpisodes) {
        return (episode: null, finished: false);
      }

      await _db
          .into(_db.watchEvents)
          .insert(
            WatchEventsCompanion.insert(
              id: newId(),
              cycleId: cycle.id,
              episode: episode,
              watchedAt: Value(now),
              markedAt: now,
              updatedAt: now,
            ),
          );
      final finished =
          release.canComplete &&
          watched.length + 1 >= release.availableEpisodes;
      if (finished) await _finishCycle(cycle, now);
      await (_db.update(
        _db.libraryEntries,
      )..where((row) => row.id.equals(entry.id))).write(
        LibraryEntriesCompanion(
          status: Value(
            (finished ? WatchStatus.completed : WatchStatus.watching).name,
          ),
          updatedAt: Value(now),
        ),
      );
      return (episode: episode, finished: finished);
    });
    return LibraryChange(
      undo: () => _restore(animeId, snapshot),
      markedEpisodes: result.episode == null ? 0 : 1,
      episode: result.episode,
      finished: result.finished,
    );
  }

  /// Отмечает серию или снимает отметку.
  Future<LibraryChange> toggleEpisode(
    int animeId,
    int episode, {
    String? source,
  }) {
    return _change(animeId, (entry, anime, now) async {
      final cycle = await _cycleForEditing(entry, now);
      final existing = await _activeEvents(
        cycle.id,
        from: episode,
        to: episode,
      );
      if (existing.isNotEmpty) {
        await _deleteEvents(existing, now);
        await _afterUnmarking(entry, cycle, now);
        return (marked: 0, finished: false);
      }
      await _db
          .into(_db.watchEvents)
          .insert(
            WatchEventsCompanion.insert(
              id: newId(),
              cycleId: cycle.id,
              episode: episode,
              watchedAt: Value(now),
              markedAt: now,
              beforeAired: Value(anime.release.isUnaired(episode)),
              source: Value(source),
              updatedAt: now,
            ),
          );
      final finished = await _afterMarking(entry, cycle, anime, now);
      return (marked: 1, finished: finished);
    });
  }

  /// Отмечает серии from–to.
  Future<LibraryChange> markRange(int animeId, int from, int to) {
    return _change(animeId, (entry, anime, now) async {
      final cycle = await _cycleForEditing(entry, now);
      final watched = {
        for (final event in await _activeEvents(cycle.id)) event.episode,
      };
      final missing = [
        for (var episode = from; episode <= to; episode++)
          if (!watched.contains(episode)) episode,
      ];
      await _db.batch((batch) {
        batch.insertAll(_db.watchEvents, [
          for (final episode in missing)
            WatchEventsCompanion.insert(
              id: newId(),
              cycleId: cycle.id,
              episode: episode,
              markedAt: now,
              beforeAired: Value(anime.release.isUnaired(episode)),
              bulk: const Value(true),
              updatedAt: now,
            ),
        ]);
      });
      final finished = await _afterMarking(entry, cycle, anime, now);
      return (marked: missing.length, finished: finished);
    });
  }

  /// Снимает отметки серий from–to.
  Future<LibraryChange> unmarkRange(int animeId, int from, int to) {
    return _change(animeId, (entry, anime, now) async {
      final cycle = await _cycleForEditing(entry, now);
      final events = await _activeEvents(cycle.id, from: from, to: to);
      await _deleteEvents(events, now);
      await _afterUnmarking(entry, cycle, now);
      return (marked: 0, finished: false);
    });
  }

  /// Снимает отметки серий в любом просмотре.
  Future<LibraryChange> unmarkEpisodes(
    int animeId,
    String cycleId,
    List<int> episodes,
  ) {
    return _change(animeId, (entry, anime, now) async {
      final events =
          await (_db.select(_db.watchEvents)..where(
                (event) =>
                    event.cycleId.equals(cycleId) &
                    event.episode.isIn(episodes) &
                    event.deletedAt.isNull(),
              ))
              .get();
      await _deleteEvents(events, now);
      final current = await _currentCycle(entry.id);
      if (current?.id == cycleId) {
        await _afterUnmarking(entry, current!, now);
      }
      return (marked: 0, finished: false);
    });
  }

  /// Меняет дату просмотра серии.
  Future<LibraryChange> setEpisodeDate(
    int animeId,
    String cycleId,
    int episode,
    DateTime? watchedAt,
  ) => setEpisodesDate(animeId, cycleId, [episode], watchedAt);

  /// Меняет дату просмотра нескольких серий.
  Future<LibraryChange> setEpisodesDate(
    int animeId,
    String cycleId,
    List<int> episodes,
    DateTime? watchedAt,
  ) {
    return _change(animeId, (entry, anime, now) async {
      await (_db.update(_db.watchEvents)..where(
            (event) =>
                event.cycleId.equals(cycleId) &
                event.episode.isIn(episodes) &
                event.deletedAt.isNull(),
          ))
          .write(
            WatchEventsCompanion(
              watchedAt: Value(watchedAt),
              bulk: const Value(false),
              updatedAt: Value(now),
            ),
          );
      final cycle = await (_db.select(
        _db.watchCycles,
      )..where((row) => row.id.equals(cycleId))).getSingle();
      if (cycle.state == 'completed') await _finishCycle(cycle, now);
      return (marked: 0, finished: false);
    });
  }

  /// Удаляет просмотр с отметками.
  Future<LibraryChange> deleteCycle(int animeId, String cycleId) {
    return _change(animeId, (entry, anime, now) async {
      await (_db.update(
        _db.watchEvents,
      )..where((event) => event.cycleId.equals(cycleId))).write(
        WatchEventsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
      );
      await (_db.update(
        _db.watchCycles,
      )..where((cycle) => cycle.id.equals(cycleId))).write(
        WatchCyclesCompanion(deletedAt: Value(now), updatedAt: Value(now)),
      );
      final remaining =
          await (_db.select(_db.watchCycles)..where(
                (cycle) =>
                    cycle.entryId.equals(entry.id) & cycle.deletedAt.isNull(),
              ))
              .get();
      final current = await _currentCycle(entry.id);
      final hasCompleted = remaining.any((cycle) => cycle.state == 'completed');
      final currentHasMarks =
          current != null && (await _activeEvents(current.id)).isNotEmpty;
      final WatchStatus status;
      if (current != null && current.state == 'completed') {
        status = WatchStatus.completed;
      } else if (currentHasMarks) {
        status = WatchStatus.watching;
      } else if (hasCompleted) {
        status = WatchStatus.completed;
      } else {
        status = WatchStatus.planned;
      }
      await _setStatus(entry.id, status, now);
      return (marked: 0, finished: false);
    });
  }

  /// Начинает просмотр заново.
  Future<LibraryChange> restartViewing(int animeId) {
    return _change(animeId, (entry, anime, now) async {
      final current = await _currentCycle(entry.id);
      if (current != null &&
          current.state == 'active' &&
          (await _activeEvents(current.id)).isNotEmpty) {
        await (_db.update(
          _db.watchCycles,
        )..where((cycle) => cycle.id.equals(current.id))).write(
          WatchCyclesCompanion(
            state: const Value('unfinished'),
            finishedAt: const Value(null),
            updatedAt: Value(now),
          ),
        );
      }
      await _setStatus(entry.id, WatchStatus.watching, now);
      return (marked: 0, finished: false);
    });
  }

  Future<void> setScore(int animeId, int? score) =>
      (_db.update(
        _db.libraryEntries,
      )..where((entry) => entry.animeId.equals(animeId))).write(
        LibraryEntriesCompanion(
          score: Value(score),
          updatedAt: Value(DateTime.now()),
        ),
      );

  /// Включает или выключает уведомления тайтла.
  Future<void> setMuted(int animeId, bool muted) =>
      (_db.update(
        _db.libraryEntries,
      )..where((entry) => entry.animeId.equals(animeId))).write(
        LibraryEntriesCompanion(
          muted: Value(muted),
          updatedAt: Value(DateTime.now()),
        ),
      );

  /// Меняет озвучку тайтла.
  Future<void> setDubbing(int animeId, String? dubbing) =>
      (_db.update(
        _db.libraryEntries,
      )..where((entry) => entry.animeId.equals(animeId))).write(
        LibraryEntriesCompanion(
          dubbing: Value(dubbing),
          updatedAt: Value(DateTime.now()),
        ),
      );

  /// Запоминает озвучку при просмотре.
  Future<void> setDubbingSeen(int animeId, String dubbing) =>
      (_db.update(_db.libraryEntries)
            ..where((entry) => entry.animeId.equals(animeId)))
          .write(LibraryEntriesCompanion(dubbingSeen: Value(dubbing)));

  Future<void> setNote(int animeId, String note) =>
      (_db.update(
        _db.libraryEntries,
      )..where((entry) => entry.animeId.equals(animeId))).write(
        LibraryEntriesCompanion(
          note: Value(note),
          updatedAt: Value(DateTime.now()),
        ),
      );

  /// Убирает тайтл из библиотеки.
  Future<LibraryChange> remove(int animeId) async {
    final snapshot = await _snapshot(animeId);
    final now = DateTime.now();
    await (_db.update(_db.libraryEntries)..where(
          (entry) => entry.animeId.equals(animeId) & entry.deletedAt.isNull(),
        ))
        .write(
          LibraryEntriesCompanion(updatedAt: Value(now), deletedAt: Value(now)),
        );
    return LibraryChange(undo: () => _restore(animeId, snapshot));
  }

  /// Убирает несколько тайтлов из библиотеки.
  Future<LibraryChange> removeMany(List<int> animeIds) async {
    final changes = [for (final id in animeIds) await remove(id)];
    return LibraryChange(
      undo: () async {
        for (final change in changes.reversed) {
          await change.undo();
        }
      },
    );
  }

  /// Импорт списка Shikimori.
  Future<ImportResult> importRates(
    List<UserRate> rates, {
    required bool replace,
  }) async {
    final snapshots = <int, _Snapshot>{};
    var added = 0;
    var replaced = 0;
    var skipped = 0;
    await _db.transaction(() async {
      for (final rate in rates) {
        final animeId = rate.anime.id;
        if (snapshots.containsKey(animeId)) continue;
        final snapshot = await _snapshot(animeId);
        final existing = snapshot.entry;
        final active = existing != null && existing.deletedAt == null;
        if (active && !replace) {
          skipped++;
          continue;
        }
        snapshots[animeId] = snapshot;
        await saveAnime(rate.anime);
        final now = DateTime.now();

        if (existing != null) {
          final cycleIds = [for (final cycle in snapshot.cycles) cycle.id];
          await (_db.update(
            _db.watchEvents,
          )..where((row) => row.cycleId.isIn(cycleIds))).write(
            WatchEventsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
          );
          await (_db.update(
            _db.watchCycles,
          )..where((row) => row.id.isIn(cycleIds))).write(
            WatchCyclesCompanion(deletedAt: Value(now), updatedAt: Value(now)),
          );
        }

        final entryId = existing?.id ?? newId();
        final note = rate.text?.trim() ?? '';
        await _db
            .into(_db.libraryEntries)
            .insertOnConflictUpdate(
              LibraryEntriesCompanion(
                id: Value(entryId),
                animeId: Value(animeId),
                status: Value(rate.watchStatus.name),
                score: Value(rate.score > 0 ? rate.score : existing?.score),
                note: Value(note.isNotEmpty ? note : existing?.note ?? ''),
                addedAt: Value(
                  active ? existing.addedAt : rate.createdAt ?? now,
                ),
                updatedAt: Value(rate.updatedAt ?? now),
                deletedAt: const Value(null),
              ),
            );

        var number = snapshot.cycles.fold(0, (top, c) => max(top, c.number));
        final cycles = <WatchCyclesCompanion>[];
        final events = <WatchEventsCompanion>[];
        void addCycle(String state, int episodes) {
          final cycleId = newId();
          cycles.add(
            WatchCyclesCompanion.insert(
              id: cycleId,
              entryId: entryId,
              number: ++number,
              state: state,
              updatedAt: now,
            ),
          );
          for (var episode = 1; episode <= episodes; episode++) {
            events.add(
              WatchEventsCompanion.insert(
                id: newId(),
                cycleId: cycleId,
                episode: episode,
                markedAt: now,
                bulk: const Value(true),
                source: const Value('import'),
                updatedAt: now,
              ),
            );
          }
        }

        for (var i = 0; i < rate.completedViewings; i++) {
          addCycle('completed', rate.completedEpisodes);
        }
        if (rate.currentEpisodes > 0) addCycle('active', rate.currentEpisodes);
        await _db.batch((batch) {
          batch.insertAll(_db.watchCycles, cycles);
          batch.insertAll(_db.watchEvents, events);
        });
        if (active) {
          replaced++;
        } else {
          added++;
        }
      }
    });
    return ImportResult(
      added: added,
      replaced: replaced,
      skipped: skipped,
      undo: () async {
        for (final MapEntry(key: animeId, value: snapshot)
            in snapshots.entries.toList().reversed) {
          await _restore(animeId, snapshot);
        }
      },
    );
  }

  /// Сохраняет данные тайтла из Shikimori.
  Future<void> saveAnime(AnimeInfo anime) {
    final details = anime.details;
    return _db
        .into(_db.animes)
        .insertOnConflictUpdate(
          AnimesCompanion(
            id: Value(anime.id),
            name: Value(anime.name),
            russian: Value(anime.russian),
            kind: Value(anime.kind),
            shikimoriScore: Value(anime.score),
            episodes: Value(anime.episodes),
            episodesAired: Value(anime.episodesAired),
            releaseStatus: Value(anime.releaseStatus),
            nextEpisodeAt: Value(anime.nextEpisodeAt),
            airedOn: Value(anime.airedOn),
            posterUrl: Value(anime.posterUrl),
            franchise: anime.franchise == null
                ? const Value.absent()
                : Value(anime.franchise),
            updatedAt: Value(DateTime.now()),
            description: details == null
                ? const Value.absent()
                : Value(details.description),
            genres: details == null
                ? const Value.absent()
                : Value(details.genres.join('|')),
            studios: details == null
                ? const Value.absent()
                : Value(details.studios.join('|')),
            episodeDuration: details == null
                ? const Value.absent()
                : Value(details.episodeDuration),
            ageRating: details == null
                ? const Value.absent()
                : Value(details.ageRating),
            detailsLoadedAt: details == null
                ? const Value.absent()
                : Value(DateTime.now()),
          ),
        );
  }

  /// Применяет действие к записи.
  Future<({int marked, bool rewatch})> _apply(
    int animeId,
    StatusAction action,
  ) {
    return _db.transaction(() async {
      final entry = await _entryFor(animeId);
      final anime = await (_db.select(
        _db.animes,
      )..where((a) => a.id.equals(animeId))).getSingle();
      final now = DateTime.now();
      var marked = 0;
      var rewatch = false;

      switch (action) {
        case StatusAction.watching:
          final current = await _currentCycle(entry.id);
          rewatch =
              entry.status == WatchStatus.completed.name &&
              current?.state == 'completed';
        case StatusAction.completed:
        case StatusAction.caughtUp:
          final episodes = anime.release.availableEpisodes;
          final cycle = await _cycleForMarking(entry.id, now);
          marked = await _markUpTo(cycle, episodes, now);
          if (action == StatusAction.completed) await _finishCycle(cycle, now);
        case StatusAction.planned:
        case StatusAction.paused:
        case StatusAction.dropped:
          break;
      }

      await (_db.update(
        _db.libraryEntries,
      )..where((row) => row.id.equals(entry.id))).write(
        LibraryEntriesCompanion(
          status: Value(action.status.name),
          updatedAt: Value(now),
        ),
      );
      return (marked: marked, rewatch: rewatch);
    });
  }

  Future<LibraryEntry> _entryFor(int animeId) => (_db.select(
    _db.libraryEntries,
  )..where((entry) => entry.animeId.equals(animeId))).getSingle();

  Future<WatchCycle?> _currentCycle(String entryId) =>
      (_db.select(_db.watchCycles)
            ..where(
              (cycle) =>
                  cycle.entryId.equals(entryId) & cycle.deletedAt.isNull(),
            )
            ..orderBy([(cycle) => OrderingTerm.desc(cycle.number)])
            ..limit(1))
          .getSingleOrNull();

  Future<WatchCycle> _createCycle(
    String entryId,
    int number,
    DateTime now,
  ) async {
    final cycle = WatchCycle(
      id: newId(),
      entryId: entryId,
      number: number,
      state: 'active',
      startedAt: now,
      updatedAt: now,
    );
    await _db.into(_db.watchCycles).insert(cycle);
    return cycle;
  }

  /// Просмотр для новых отметок.
  Future<WatchCycle> _cycleForMarking(String entryId, DateTime now) async {
    final current = await _currentCycle(entryId);
    if (current == null) return _createCycle(entryId, 1, now);
    if (current.state == 'unfinished') {
      return _createCycle(entryId, current.number + 1, now);
    }
    return current;
  }

  /// Отмечает серии с первой по episodes.
  Future<int> _markUpTo(WatchCycle cycle, int episodes, DateTime now) async {
    final existing =
        await (_db.select(_db.watchEvents)..where(
              (event) =>
                  event.cycleId.equals(cycle.id) & event.deletedAt.isNull(),
            ))
            .get();
    final watched = {for (final event in existing) event.episode};
    final missing = [
      for (var episode = 1; episode <= episodes; episode++)
        if (!watched.contains(episode)) episode,
    ];
    await _db.batch((batch) {
      batch.insertAll(_db.watchEvents, [
        for (final episode in missing)
          WatchEventsCompanion.insert(
            id: newId(),
            cycleId: cycle.id,
            episode: episode,
            markedAt: now,
            bulk: const Value(true),
            updatedAt: now,
          ),
      ]);
    });
    return missing.length;
  }

  Future<void> _finishCycle(WatchCycle cycle, DateTime now) async {
    final latest =
        await (_db.selectOnly(_db.watchEvents)
              ..addColumns([_db.watchEvents.watchedAt.max()])
              ..where(
                _db.watchEvents.cycleId.equals(cycle.id) &
                    _db.watchEvents.deletedAt.isNull(),
              ))
            .map((row) => row.read(_db.watchEvents.watchedAt.max()))
            .getSingleOrNull();
    await (_db.update(
      _db.watchCycles,
    )..where((row) => row.id.equals(cycle.id))).write(
      WatchCyclesCompanion(
        state: const Value('completed'),
        finishedAt: Value(latest),
        updatedAt: Value(now),
      ),
    );
  }

  /// Изменение в одной транзакции с отменой.
  Future<LibraryChange> _change(
    int animeId,
    Future<({int marked, bool finished})> Function(
      LibraryEntry entry,
      Anime anime,
      DateTime now,
    )
    body,
  ) async {
    final snapshot = await _snapshot(animeId);
    final result = await _db.transaction(() async {
      final entry = await _entryFor(animeId);
      final anime = await (_db.select(
        _db.animes,
      )..where((a) => a.id.equals(animeId))).getSingle();
      return body(entry, anime, DateTime.now());
    });
    return LibraryChange(
      undo: () => _restore(animeId, snapshot),
      markedEpisodes: result.marked,
      finished: result.finished,
    );
  }

  /// Просмотр для правки отметок.
  Future<WatchCycle> _cycleForEditing(LibraryEntry entry, DateTime now) async {
    final current = await _currentCycle(entry.id);
    if (current == null) return _createCycle(entry.id, 1, now);
    if (isNewViewingPending(
      state: current.state,
      status: WatchStatus.fromName(entry.status),
    )) {
      return _createCycle(entry.id, current.number + 1, now);
    }
    return current;
  }

  Future<List<WatchEvent>> _activeEvents(String cycleId, {int? from, int? to}) {
    final query = _db.select(_db.watchEvents)
      ..where(
        (event) => event.cycleId.equals(cycleId) & event.deletedAt.isNull(),
      );
    if (from != null) {
      query.where((event) => event.episode.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      query.where((event) => event.episode.isSmallerOrEqualValue(to));
    }
    return query.get();
  }

  Future<void> _deleteEvents(List<WatchEvent> events, DateTime now) =>
      (_db.update(
        _db.watchEvents,
      )..where((event) => event.id.isIn(events.map((e) => e.id)))).write(
        WatchEventsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
      );

  Future<void> _setStatus(String entryId, WatchStatus status, DateTime now) =>
      (_db.update(
        _db.libraryEntries,
      )..where((row) => row.id.equals(entryId))).write(
        LibraryEntriesCompanion(
          status: Value(status.name),
          updatedAt: Value(now),
        ),
      );

  /// Обновляет статус после отметки.
  Future<bool> _afterMarking(
    LibraryEntry entry,
    WatchCycle cycle,
    Anime anime,
    DateTime now,
  ) async {
    final release = anime.release;
    final watched = {
      for (final event in await _activeEvents(cycle.id)) event.episode,
    };
    final complete =
        release.canComplete &&
        [for (var e = 1; e <= release.availableEpisodes; e++) e]
            .every(watched.contains);
    if (complete) {
      await _finishCycle(cycle, now);
      await _setStatus(entry.id, WatchStatus.completed, now);
      return entry.status != WatchStatus.completed.name;
    }
    await _setStatus(entry.id, WatchStatus.watching, now);
    return false;
  }

  /// Обновляет статус после снятия отметки.
  Future<void> _afterUnmarking(
    LibraryEntry entry,
    WatchCycle cycle,
    DateTime now,
  ) async {
    if (cycle.state == 'completed') {
      await (_db.update(
        _db.watchCycles,
      )..where((row) => row.id.equals(cycle.id))).write(
        WatchCyclesCompanion(
          state: const Value('active'),
          finishedAt: const Value(null),
          updatedAt: Value(now),
        ),
      );
    }
    if (entry.status == WatchStatus.completed.name) {
      await _setStatus(entry.id, WatchStatus.watching, now);
    }
  }

  /// Снимок тайтла для отмены.
  Future<_Snapshot> _snapshot(int animeId) async {
    final entry = await (_db.select(
      _db.libraryEntries,
    )..where((row) => row.animeId.equals(animeId))).getSingleOrNull();
    if (entry == null) return const _Snapshot(null, [], []);
    final cycles = await (_db.select(
      _db.watchCycles,
    )..where((row) => row.entryId.equals(entry.id))).get();
    final events = await (_db.select(
      _db.watchEvents,
    )..where((row) => row.cycleId.isIn(cycles.map((cycle) => cycle.id)))).get();
    return _Snapshot(entry, cycles, events);
  }

  /// Восстанавливает тайтл из снимка.
  Future<void> _restore(int animeId, _Snapshot snapshot) {
    return _db.transaction(() async {
      final current = await _snapshot(animeId);
      final keptCycles = {for (final cycle in snapshot.cycles) cycle.id};
      final keptEvents = {for (final event in snapshot.events) event.id};

      await (_db.delete(_db.watchEvents)..where(
            (row) =>
                row.cycleId.isIn(current.cycles.map((cycle) => cycle.id)) &
                row.id.isNotIn(keptEvents),
          ))
          .go();
      await (_db.delete(_db.watchCycles)..where(
            (row) =>
                row.id.isIn(current.cycles.map((cycle) => cycle.id)) &
                row.id.isNotIn(keptCycles),
          ))
          .go();

      if (snapshot.entry == null) {
        if (current.entry != null) {
          await (_db.delete(
            _db.libraryEntries,
          )..where((row) => row.id.equals(current.entry!.id))).go();
        }
        return;
      }
      await _db
          .into(_db.libraryEntries)
          .insertOnConflictUpdate(snapshot.entry!.toCompanion(false));
      await _db.batch((batch) {
        batch.insertAllOnConflictUpdate(_db.watchCycles, [
          for (final cycle in snapshot.cycles) cycle.toCompanion(false),
        ]);
        batch.insertAllOnConflictUpdate(_db.watchEvents, [
          for (final event in snapshot.events) event.toCompanion(false),
        ]);
      });
    });
  }
}

class _Snapshot {
  const _Snapshot(this.entry, this.cycles, this.events);

  final LibraryEntry? entry;
  final List<WatchCycle> cycles;
  final List<WatchEvent> events;
}

final _random = Random.secure();

String newId() {
  final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex = bytes
      .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
      .join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-'
      '${hex.substring(16, 20)}-${hex.substring(20)}';
}
