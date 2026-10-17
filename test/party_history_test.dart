import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kiroku/data/database/app_database.dart';
import 'package:kiroku/data/database/party_history_repository.dart';

PartySession _record(
  PartySession? current, {
  String uri = 'https://ru.yummyani.me/catalog/item/a',
  int? episode = 3,
  double position = 100,
  List<String> people = const ['Вася'],
  DateTime? now,
}) => partyRecord(
  current,
  role: 'host',
  address: '26.1.2.3',
  animeId: 7,
  title: 'Тайтл',
  uri: uri,
  episode: episode,
  position: position,
  people: people,
  now: now ?? DateTime(2026, 10, 17, 20),
);

void main() {
  test('сеанс продолжается на том же тайтле', () {
    final first = _record(null);
    expect(first.episodeFrom, 3);
    expect(first.episodeTo, 3);
    expect(partyPeople(first), ['Вася']);

    final later = _record(
      first,
      episode: 4,
      position: 30,
      people: ['Петя', 'Вася'],
      now: DateTime(2026, 10, 17, 21),
    );
    expect(later.id, first.id);
    expect(later.episodeFrom, 3);
    expect(later.episodeTo, 4);
    expect(later.position, 30);
    expect(partyPeople(later), ['Вася', 'Петя']);
    expect(later.startedAt, first.startedAt);
    expect(later.endedAt, DateTime(2026, 10, 17, 21));

    final other = _record(later, uri: 'https://ru.yummyani.me/catalog/item/b');
    expect(other.id, isNot(first.id));
    expect(other.episodeFrom, 3);
  });

  test('история хранится и удаляется', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final history = PartyHistoryRepository(database);
    final old = _record(null, now: DateTime(2026, 10, 1));
    final fresh = _record(
      null,
      uri: 'https://ru.yummyani.me/catalog/item/b',
      now: DateTime(2026, 10, 16),
    );
    await history.save(old);
    await history.save(fresh);
    expect((await history.watchAll().first).map((r) => r.id), [
      fresh.id,
      old.id,
    ]);
    await history.delete(old.id);
    expect((await history.watchAll().first).single.id, fresh.id);
  });

  test('имена людей обновляются по номеру', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final history = PartyHistoryRepository(database);
    await history.rememberPeople({'u1': 'Вася', 'u2': 'Петя'});
    await history.rememberPeople({'u1': 'Василий'});
    expect(await history.watchPeople().first, {'u1': 'Василий', 'u2': 'Петя'});
  });
}
