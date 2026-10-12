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
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => currentSchema;

  static const currentSchema = 8;

  static const fileName = 'kiroku';

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.addColumn(animes, animes.description);
        await migrator.addColumn(animes, animes.genres);
        await migrator.addColumn(animes, animes.studios);
        await migrator.addColumn(animes, animes.episodeDuration);
        await migrator.addColumn(animes, animes.ageRating);
        await migrator.addColumn(animes, animes.detailsLoadedAt);
        await migrator.createTable(watchCycles);
        await migrator.createTable(watchEvents);
      }
      if (from < 3) {
        await migrator.createTable(appSettings);
      }
      if (from < 4) {
        await migrator.addColumn(animes, animes.franchise);
        await migrator.addColumn(
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
        await migrator.addColumn(libraryEntries, libraryEntries.muted);
      }
      if (from < 6) {
        await migrator.createTable(watchLinks);
      }
      if (from < 7) {
        await migrator.addColumn(watchEvents, watchEvents.source);
        await migrator.addColumn(libraryEntries, libraryEntries.dubbing);
        await migrator.createTable(siteEpisodes);
      }
      if (from < 8) {
        await migrator.addColumn(libraryEntries, libraryEntries.dubbingSeen);
        await migrator.addColumn(franchises, franchises.dubbing);
        await migrator.addColumn(franchises, franchises.dubbingSeen);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

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
