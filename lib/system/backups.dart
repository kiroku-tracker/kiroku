import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import '../data/database/app_database.dart';

/// Вид резервной копии.
enum BackupKind {
  auto('auto', 'Автоматическая'),
  manual('manual', 'Создана вручную'),
  beforeRestore('before', 'Перед восстановлением');

  const BackupKind(this.code, this.label);

  final String code;
  final String label;
}

class BackupFile {
  const BackupFile({
    required this.file,
    required this.createdAt,
    required this.kind,
    required this.titles,
  });

  final File file;
  final DateTime createdAt;
  final BackupKind kind;

  final int? titles;
}

class BackupException implements Exception {
  const BackupException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Резервные копии и перенос данных.
class Backups {
  Backups(this.dataFolder);

  final Directory dataFolder;

  static const keep = 10;

  static const autoInterval = Duration(hours: 20);

  static const extension = 'kiroku';

  /// Данные восстановлены при запуске.
  static bool restoredAtStart = false;

  static Future<Backups> standard() async =>
      Backups(await getApplicationSupportDirectory());

  Directory get folder => Directory(p.join(dataFolder.path, 'backups'));

  File get _pending => File(p.join(dataFolder.path, 'restore-pending.sqlite'));

  static final _namePattern = RegExp(
    r'^kiroku-(\d{4})-(\d\d)-(\d\d)_(\d\d)-(\d\d)-(\d\d)-([a-z]+)\.sqlite$',
  );

  static String _two(int value) => value.toString().padLeft(2, '0');

  static String _name(DateTime time, BackupKind kind) =>
      'kiroku-${time.year}-${_two(time.month)}-${_two(time.day)}_'
      '${_two(time.hour)}-${_two(time.minute)}-${_two(time.second)}-'
      '${kind.code}.sqlite';

  /// Сохраняет базу в файл.
  static Future<void> exportTo(AppDatabase db, String path) async {
    final target = File(path);
    if (await target.exists()) await target.delete();
    await db.customStatement('VACUUM INTO ?', [path]);
  }

  /// Создаёт резервную копию.
  Future<BackupFile> create(
    AppDatabase db,
    BackupKind kind, {
    DateTime? now,
  }) async {
    await folder.create(recursive: true);
    final time = now ?? DateTime.now();
    final file = File(p.join(folder.path, _name(time, kind)));
    await exportTo(db, file.path);
    final copies = await list();
    for (final old in copies.where((copy) => copy.kind == kind).skip(keep)) {
      await old.file.delete();
    }
    return copies.firstWhere(
      (copy) => copy.file.path == file.path,
      orElse: () =>
          BackupFile(file: file, createdAt: time, kind: kind, titles: null),
    );
  }

  /// Создаёт автоматическую копию, если пора.
  Future<bool> autoIfDue(AppDatabase db, {DateTime? now}) async {
    final time = now ?? DateTime.now();
    final last = (await list())
        .where((copy) => copy.kind == BackupKind.auto)
        .firstOrNull;
    if (last != null && time.difference(last.createdAt) < autoInterval) {
      return false;
    }
    await create(db, BackupKind.auto, now: time);
    return true;
  }

  Future<List<BackupFile>> list() async {
    if (!await folder.exists()) return const [];
    final result = <BackupFile>[];
    await for (final entity in folder.list()) {
      if (entity is! File) continue;
      final match = _namePattern.firstMatch(p.basename(entity.path));
      if (match == null) continue;
      final kind = BackupKind.values
          .where((kind) => kind.code == match.group(7))
          .firstOrNull;
      if (kind == null) continue;
      final [year, month, day, hour, minute, second] = [
        for (var group = 1; group <= 6; group++) int.parse(match.group(group)!),
      ];
      int? titles;
      try {
        titles = inspect(entity.path);
      } on BackupException {
        titles = null;
      }
      result.add(
        BackupFile(
          file: entity,
          createdAt: DateTime(year, month, day, hour, minute, second),
          kind: kind,
          titles: titles,
        ),
      );
    }
    return result..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Проверяет файл данных и возвращает число тайтлов.
  static int inspect(String path) {
    const notKiroku = BackupException('Файл не похож на данные Kiroku.');
    final Database database;
    try {
      database = sqlite3.open(path, mode: OpenMode.readOnly);
    } on Object {
      throw notKiroku;
    }
    try {
      final tables = database
          .select(
            "SELECT name FROM sqlite_master WHERE type = 'table' "
            "AND name IN ('animes', 'library_entries')",
          )
          .length;
      if (tables != 2) throw notKiroku;
      if (database.userVersion > AppDatabase.currentSchema) {
        throw const BackupException(
          'Файл сохранён более новой версией Kiroku. Нужно обновить '
          'программу.',
        );
      }
      final check = database.select('PRAGMA quick_check').first.values.first;
      if (check != 'ok') {
        throw const BackupException('Файл повреждён.');
      }
      return database
              .select('SELECT count(*) FROM library_entries')
              .first
              .values
              .first
          as int;
    } on BackupException {
      rethrow;
    } on Object {
      throw notKiroku;
    } finally {
      database.close();
    }
  }

  /// Готовит восстановление из файла.
  Future<void> prepareRestore(AppDatabase db, String source) async {
    inspect(source);
    await create(db, BackupKind.beforeRestore);
    await File(source).copy(_pending.path);
  }

  /// Восстанавливает базу при запуске.
  Future<bool> applyPending() async {
    if (!await _pending.exists()) return false;
    final base = p.join(dataFolder.path, '${AppDatabase.fileName}.sqlite');
    for (final suffix in const ['', '-journal', '-wal', '-shm']) {
      final file = File('$base$suffix');
      if (await file.exists()) await file.delete();
    }
    await _pending.rename(base);
    return true;
  }
}

final backupsProvider = FutureProvider<Backups>((ref) => Backups.standard());
