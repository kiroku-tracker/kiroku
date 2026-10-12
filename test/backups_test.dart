import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiroku/data/database/app_database.dart';
import 'package:kiroku/data/database/library_repository.dart';
import 'package:kiroku/data/database/status_action.dart';
import 'package:kiroku/data/shikimori/anime_info.dart';
import 'package:kiroku/system/backups.dart';
import 'package:path/path.dart' as p;

AnimeInfo _anime(int id) => AnimeInfo(
  id: id,
  name: 'Anime $id',
  russian: 'Аниме $id',
  kind: 'tv',
  episodes: 12,
  episodesAired: 12,
  releaseStatus: 'released',
);

void main() {
  late Directory folder;
  late AppDatabase database;
  late Backups backups;

  setUp(() async {
    folder = await Directory.systemTemp.createTemp('kiroku_backups_');
    database = AppDatabase(NativeDatabase.memory());
    backups = Backups(folder);
    final library = LibraryRepository(database);
    await library.add(_anime(1), StatusAction.watching);
    await library.add(_anime(2), StatusAction.planned);
  });

  tearDown(() async {
    await database.close();
    await folder.delete(recursive: true);
  });

  test('создание копии', () async {
    final copy = await backups.create(database, BackupKind.manual);
    expect(copy.titles, 2);
    expect(copy.kind, BackupKind.manual);
    expect(Backups.inspect(copy.file.path), 2);
  });

  test('автоматическая копия', () async {
    final start = DateTime(2026, 10, 12, 9);
    expect(await backups.autoIfDue(database, now: start), isTrue);
    expect(
      await backups.autoIfDue(
        database,
        now: start.add(const Duration(hours: 5)),
      ),
      isFalse,
    );
    expect(
      await backups.autoIfDue(
        database,
        now: start.add(const Duration(hours: 21)),
      ),
      isTrue,
    );
    expect((await backups.list()).length, 2);
  });

  test('старые копии удаляются', () async {
    final start = DateTime(2026, 1, 1);
    for (var day = 0; day < 12; day++) {
      await backups.create(
        database,
        BackupKind.auto,
        now: start.add(Duration(days: day)),
      );
    }
    await backups.create(database, BackupKind.manual, now: start);
    final copies = await backups.list();
    expect(
      copies.where((copy) => copy.kind == BackupKind.auto).length,
      Backups.keep,
    );
    expect(copies.where((copy) => copy.kind == BackupKind.manual).length, 1);
    expect(copies.first.createdAt, start.add(const Duration(days: 11)));
  });

  test('чужой файл', () async {
    final text = File(p.join(folder.path, 'notes.kiroku'));
    await text.writeAsString('не база');
    expect(() => Backups.inspect(text.path), throwsA(isA<BackupException>()));
  });

  test('восстановление', () async {
    final export = p.join(folder.path, 'transfer.kiroku');
    await Backups.exportTo(database, export);
    final base = File(p.join(folder.path, 'kiroku.sqlite'));
    await base.writeAsString('старая база');

    expect(await backups.applyPending(), isFalse);
    await backups.prepareRestore(database, export);
    expect((await backups.list()).single.kind, BackupKind.beforeRestore);

    expect(await backups.applyPending(), isTrue);
    expect(Backups.inspect(base.path), 2);
    expect(await backups.applyPending(), isFalse);
  });
}
