import 'package:drift/drift.dart';

import 'app_database.dart';
import 'library_repository.dart';

/// История совместного просмотра.
class PartyHistoryRepository {
  PartyHistoryRepository(this._db);

  final AppDatabase _db;

  /// Сеансы, последние сверху.
  Stream<List<PartySession>> watchAll() => (_db.select(
    _db.partySessions,
  )..orderBy([(session) => OrderingTerm.desc(session.endedAt)])).watch();

  Future<void> save(PartySession session) =>
      _db.into(_db.partySessions).insertOnConflictUpdate(session);

  /// Последние имена людей по номеру их Kiroku.
  Stream<Map<String, String>> watchPeople() => _db
      .select(_db.partyPeople)
      .watch()
      .map((rows) => {for (final row in rows) row.uid: row.name});

  /// Запоминает имена людей из комнаты.
  Future<void> rememberPeople(Map<String, String> people) async {
    if (people.isEmpty) return;
    final now = DateTime.now();
    await _db.batch(
      (batch) => batch.insertAllOnConflictUpdate(_db.partyPeople, [
        for (final MapEntry(key: uid, value: name) in people.entries)
          PartyPeopleCompanion.insert(uid: uid, name: name, seenAt: now),
      ]),
    );
  }

  Future<void> delete(String id) => (_db.delete(
    _db.partySessions,
  )..where((session) => session.id.equals(id))).go();
}

/// Участники сеанса: номера их Kiroku (в старых записях имена).
List<String> partyPeople(PartySession session) => [
  for (final name in session.people.split('|'))
    if (name.isNotEmpty) name,
];

/// Запись сеанса после очередного отчёта: для другого тайтла новая, для
/// того же обновлённая.
PartySession partyRecord(
  PartySession? current, {
  required String role,
  required String address,
  required int? animeId,
  required String title,
  required String uri,
  required int? episode,
  required double position,
  required Iterable<String> people,
  required DateTime now,
}) {
  if (current == null || current.uri != uri) {
    return PartySession(
      id: newId(),
      role: role,
      address: address,
      animeId: animeId,
      title: title,
      uri: uri,
      episodeFrom: episode,
      episodeTo: episode,
      position: position,
      people: {...people}.join('|'),
      startedAt: now,
      endedAt: now,
    );
  }
  final from = current.episodeFrom;
  return current.copyWith(
    role: role,
    address: address.isEmpty ? current.address : address,
    episodeFrom: Value(
      from == null || (episode != null && episode < from) ? episode : from,
    ),
    episodeTo: Value(episode ?? current.episodeTo),
    position: position,
    people: {...partyPeople(current), ...people}.join('|'),
    endedAt: now,
  );
}
