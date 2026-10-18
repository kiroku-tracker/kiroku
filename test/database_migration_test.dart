import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kiroku/data/database/app_database.dart';

void main() {
  test('база с прежним номером схемы и новыми колонками открывается', () async {
    final folder = Directory.systemTemp.createTempSync('kiroku_migration_');
    addTearDown(() => folder.deleteSync(recursive: true));
    final file = File('${folder.path}/kiroku.sqlite');

    final fresh = AppDatabase(NativeDatabase(file));
    await fresh.select(fresh.libraryEntries).get();
    await fresh.customStatement('PRAGMA user_version = 8');
    await fresh.close();

    final reopened = AppDatabase(NativeDatabase(file));
    addTearDown(reopened.close);
    expect(await reopened.select(reopened.libraryEntries).get(), isEmpty);
    final version = await reopened
        .customSelect('PRAGMA user_version')
        .getSingle();
    expect(version.read<int>('user_version'), AppDatabase.currentSchema);
  });

  test('прежние отметки уведомлений переходят в выбор', () async {
    final folder = Directory.systemTemp.createTempSync('kiroku_migration_');
    addTearDown(() => folder.deleteSync(recursive: true));
    final file = File('${folder.path}/kiroku.sqlite');

    final old = AppDatabase(NativeDatabase(file));
    for (final id in [1, 2, 3]) {
      await old
          .into(old.animes)
          .insert(
            AnimesCompanion.insert(id: Value(id), updatedAt: DateTime(2026)),
          );
      await old
          .into(old.libraryEntries)
          .insert(
            LibraryEntriesCompanion.insert(
              id: 'e$id',
              animeId: id,
              status: 'watching',
              addedAt: DateTime(2026),
              updatedAt: DateTime(2026),
              muted: Value(id == 1),
              alertsOn: Value(id == 2),
            ),
          );
    }
    await old.customStatement('PRAGMA user_version = 13');
    await old.close();

    final reopened = AppDatabase(NativeDatabase(file));
    addTearDown(reopened.close);
    final entries = await reopened.select(reopened.libraryEntries).get();
    expect(
      {for (final entry in entries) entry.animeId: entry.alertMode},
      {1: 'off', 2: 'episodes', 3: null},
    );
  });
}
