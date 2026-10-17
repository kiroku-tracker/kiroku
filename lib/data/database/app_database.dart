import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../shikimori/anime_info.dart';
import '../shikimori/release_facts.dart';

part 'app_database.g.dart';

/// Данные тайтлов из Shikimori.
class Animes extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text().withDefault(const Constant(''))();
  TextColumn get russian => text().withDefault(const Constant(''))();
  TextColumn get kind => text().nullable()();
  RealColumn get shikimoriScore => real().nullable()();
  IntColumn get episodes => integer().withDefault(const Constant(0))();
  IntColumn get episodesAired => integer().withDefault(const Constant(0))();

  TextColumn get releaseStatus => text().nullable()();
  DateTimeColumn get nextEpisodeAt => dateTime().nullable()();

  TextColumn get airedOn => text().nullable()();
  TextColumn get posterUrl => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  TextColumn get description => text().nullable()();

  TextColumn get genres => text().nullable()();
  TextColumn get studios => text().nullable()();
  IntColumn get episodeDuration => integer().nullable()();
  TextColumn get ageRating => text().nullable()();
  DateTimeColumn get detailsLoadedAt => dateTime().nullable()();

  TextColumn get franchise => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Тайтлы в библиотеке.
class LibraryEntries extends Table {
  TextColumn get id => text()();
  IntColumn get animeId => integer().unique().references(Animes, #id)();

  TextColumn get status => text()();
  IntColumn get score => integer().nullable()();
  TextColumn get note => text().withDefault(const Constant(''))();
  DateTimeColumn get addedAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  TextColumn get franchiseOverride => text().nullable()();

  BoolColumn get muted => boolean().withDefault(const Constant(false))();

  BoolColumn get alertsOn => boolean().withDefault(const Constant(false))();

  TextColumn get dubbing => text().nullable()();

  TextColumn get dubbingSeen => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class WatchCycles extends Table {
  TextColumn get id => text()();
  TextColumn get entryId => text().references(LibraryEntries, #id)();
  IntColumn get number => integer()();

  TextColumn get state => text()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get finishedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class WatchEvents extends Table {
  TextColumn get id => text()();
  TextColumn get cycleId => text().references(WatchCycles, #id)();
  IntColumn get episode => integer()();

  DateTimeColumn get watchedAt => dateTime().nullable()();

  DateTimeColumn get markedAt => dateTime()();
  BoolColumn get beforeAired => boolean().withDefault(const Constant(false))();

  BoolColumn get bulk => boolean().withDefault(const Constant(false))();

  TextColumn get source => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

/// Связи между тайтлами.
class AnimeRelations extends Table {
  IntColumn get animeId => integer()();
  IntColumn get relatedId => integer()();
  TextColumn get relation => text()();

  @override
  Set<Column> get primaryKey => {animeId, relatedId};
}

class Franchises extends Table {
  TextColumn get key => text()();

  TextColumn get name => text().nullable()();

  TextColumn get autoName => text().nullable()();
  IntColumn get coverAnimeId => integer().nullable()();

  TextColumn get dubbing => text().nullable()();

  TextColumn get dubbingSeen => text().nullable()();

  BoolColumn get muted => boolean().withDefault(const Constant(false))();

  BoolColumn get alertsOn => boolean().withDefault(const Constant(false))();
  DateTimeColumn get partsLoadedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}

class UserGroups extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class UserGroupMembers extends Table {
  TextColumn get groupId => text().references(UserGroups, #id)();
  TextColumn get memberKey => text()();
  DateTimeColumn get addedAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {groupId, memberKey};
}

/// Очереди просмотра франшиз.
class WatchQueues extends Table {
  TextColumn get id => text()();
  TextColumn get franchiseKey => text()();

  TextColumn get state => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Части в очереди.
class WatchQueueItems extends Table {
  TextColumn get queueId => text().references(WatchQueues, #id)();
  IntColumn get animeId => integer()();
  IntColumn get position => integer()();

  TextColumn get mode => text()();

  TextColumn get state => text()();

  @override
  Set<Column> get primaryKey => {queueId, animeId};
}

/// Свои ссылки на просмотр.
class WatchLinks extends Table {
  TextColumn get id => text()();
  IntColumn get animeId => integer()();
  TextColumn get label => text()();
  TextColumn get url => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Серии на YummyAnime по озвучкам.
class SiteEpisodes extends Table {
  IntColumn get animeId => integer()();

  TextColumn get dubbing => text()();

  IntColumn get episodes => integer()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {animeId, dubbing};
}

/// Уведомления в центре уведомлений.
class Notices extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get category => text()();
  IntColumn get animeId => integer()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get read => boolean().withDefault(const Constant(false))();
}

/// Сеансы совместного просмотра: что, с кем и до какой серии смотрели.
class PartySessions extends Table {
  TextColumn get id => text()();

  TextColumn get role => text()();
  TextColumn get address => text().withDefault(const Constant(''))();
  IntColumn get animeId => integer().nullable()();
  TextColumn get title => text()();
  TextColumn get uri => text()();
  IntColumn get episodeFrom => integer().nullable()();
  IntColumn get episodeTo => integer().nullable()();
  RealColumn get position => real().withDefault(const Constant(0))();

  TextColumn get people => text().withDefault(const Constant(''))();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Люди из совместного просмотра: постоянный номер их Kiroku и последнее
/// имя.
class PartyPeople extends Table {
  TextColumn get uid => text()();
  TextColumn get name => text()();
  DateTimeColumn get seenAt => dateTime()();

  @override
  Set<Column> get primaryKey => {uid};
}

@DriftDatabase(
  tables: [
    Animes,
    LibraryEntries,
    WatchCycles,
    WatchEvents,
    AppSettings,
    AnimeRelations,
    Franchises,
    UserGroups,
    UserGroupMembers,
    WatchQueues,
    WatchQueueItems,
    WatchLinks,
    SiteEpisodes,
    Notices,
    PartySessions,
    PartyPeople,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => currentSchema;

  static const currentSchema = 11;

  static const fileName = 'kiroku';

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await _addColumn(migrator, animes, animes.description);
        await _addColumn(migrator, animes, animes.genres);
        await _addColumn(migrator, animes, animes.studios);
        await _addColumn(migrator, animes, animes.episodeDuration);
        await _addColumn(migrator, animes, animes.ageRating);
        await _addColumn(migrator, animes, animes.detailsLoadedAt);
        await migrator.createTable(watchCycles);
        await migrator.createTable(watchEvents);
      }
      if (from < 3) {
        await migrator.createTable(appSettings);
      }
      if (from < 4) {
        await _addColumn(migrator, animes, animes.franchise);
        await _addColumn(
          migrator,
          libraryEntries,
          libraryEntries.franchiseOverride,
        );
        await migrator.createTable(animeRelations);
        await migrator.createTable(franchises);
        await migrator.createTable(userGroups);
        await migrator.createTable(userGroupMembers);
        await migrator.createTable(watchQueues);
        await migrator.createTable(watchQueueItems);
      }
      if (from < 5) {
        await _addColumn(migrator, libraryEntries, libraryEntries.muted);
      }
      if (from < 6) {
        await migrator.createTable(watchLinks);
      }
      if (from < 7) {
        await _addColumn(migrator, watchEvents, watchEvents.source);
        await _addColumn(migrator, libraryEntries, libraryEntries.dubbing);
        await migrator.createTable(siteEpisodes);
      }
      if (from < 8) {
        await _addColumn(migrator, libraryEntries, libraryEntries.dubbingSeen);
        await _addColumn(migrator, franchises, franchises.dubbing);
        await _addColumn(migrator, franchises, franchises.dubbingSeen);
      }
      if (from < 9) {
        await _addColumn(migrator, libraryEntries, libraryEntries.alertsOn);
        await _addColumn(migrator, franchises, franchises.muted);
        await _addColumn(migrator, franchises, franchises.alertsOn);
        await migrator.createTable(notices);
      }
      if (from < 10) {
        await migrator.createTable(partySessions);
      }
      if (from < 11) {
        await migrator.createTable(partyPeople);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Добавляет колонку, если её ещё нет: базу могла открыть старая версия
  /// Kiroku и вернуть прежний номер схемы.
  Future<void> _addColumn(
    Migrator migrator,
    TableInfo<Table, dynamic> table,
    GeneratedColumn<Object> column,
  ) async {
    final columns = await customSelect(
      'PRAGMA table_info("${table.actualTableName}")',
    ).get();
    if (columns.any((row) => row.read<String>('name') == column.name)) return;
    await migrator.addColumn(table, column);
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: fileName,
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }
}

extension AnimeRowX on Anime {
  String get title => russian.isNotEmpty ? russian : name;

  ReleaseFacts get release => ReleaseFacts(
    status: releaseStatus,
    episodes: episodes,
    aired: episodesAired,
  );

  int? get year => int.tryParse(airedOn?.split('-').first ?? '');

  List<String> get genreList =>
      genres == null || genres!.isEmpty ? const [] : genres!.split('|');

  List<String> get studioList =>
      studios == null || studios!.isEmpty ? const [] : studios!.split('|');

  /// Тайтл в формате Shikimori.
  AnimeInfo toInfo() => AnimeInfo(
    id: id,
    name: name,
    russian: russian,
    kind: kind,
    score: shikimoriScore,
    episodes: episodes,
    episodesAired: episodesAired,
    releaseStatus: releaseStatus,
    nextEpisodeAt: nextEpisodeAt,
    airedOn: airedOn,
    posterUrl: posterUrl,
    franchise: franchise,
  );
}
