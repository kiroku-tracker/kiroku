import 'dart:io';

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
}
