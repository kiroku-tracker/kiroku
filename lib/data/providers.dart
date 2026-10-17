import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database/app_database.dart';
import 'database/franchise_repository.dart';
import 'database/franchise_rules.dart';
import 'database/library_repository.dart';
import 'database/notices_repository.dart';
import 'database/party_history_repository.dart';
import 'database/queue_repository.dart';
import 'database/settings_repository.dart';
import 'database/user_groups_repository.dart';
import 'database/watch_status.dart';
import 'shikimori/anime_query.dart';
import 'shikimori/shikimori_client.dart';
import 'watch/watch_links_repository.dart';
import 'watch/site_episodes_repository.dart';
import 'watch/watch_sources.dart';
import 'yummy/yummy_client.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final shikimoriClientProvider = Provider<ShikimoriClient>(
  (ref) => ShikimoriClient(),
);

final libraryRepositoryProvider = Provider<LibraryRepository>(
  (ref) => LibraryRepository(ref.watch(databaseProvider)),
);

final _libraryRowsProvider = StreamProvider<List<LibraryItem>>(
  (ref) => ref.watch(libraryRepositoryProvider).watchItems(),
);

final _libraryProgressProvider = StreamProvider<Map<String, WatchProgress>>(
  (ref) => ref.watch(libraryRepositoryProvider).watchProgress(),
);

final libraryItemsProvider = Provider<AsyncValue<List<LibraryItem>>>((ref) {
  final rows = ref.watch(_libraryRowsProvider);
  final progress = ref.watch(_libraryProgressProvider).value ?? const {};
  return rows.whenData(
    (items) => [
      for (final item in items)
        LibraryItem(
          entry: item.entry,
          anime: item.anime,
          progress: progress[item.entry.id] ?? const WatchProgress(),
        ),
    ],
  );
});

final libraryStatusesProvider = StreamProvider<Map<int, WatchStatus>>(
  (ref) => ref.watch(libraryRepositoryProvider).watchStatuses(),
);

final animeProvider = StreamProvider.family<Anime?, int>(
  (ref, animeId) => ref.watch(libraryRepositoryProvider).watchAnime(animeId),
);

final libraryEntryProvider = StreamProvider.family<LibraryEntry?, int>(
  (ref, animeId) => ref.watch(libraryRepositoryProvider).watchEntry(animeId),
);

final titleProgressProvider = Provider.family<WatchProgress, int>((
  ref,
  animeId,
) {
  final entry = ref.watch(libraryEntryProvider(animeId)).value;
  if (entry == null) return const WatchProgress(watched: 0);
  return ref.watch(_libraryProgressProvider).value?[entry.id] ??
      const WatchProgress();
});

final titleHistoryProvider = StreamProvider.family<List<CycleHistory>, int>(
  (ref, animeId) => ref.watch(libraryRepositoryProvider).watchHistory(animeId),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(databaseProvider)),
);

class LibraryPrefsNotifier extends AsyncNotifier<LibraryPrefs> {
  @override
  Future<LibraryPrefs> build() async => LibraryPrefs.fromSettings(
    await ref.read(settingsRepositoryProvider).readAll(),
  );

  Future<void> change(LibraryPrefs Function(LibraryPrefs) edit) async {
    final next = edit(state.value ?? const LibraryPrefs());
    state = AsyncData(next);
    final settings = ref.read(settingsRepositoryProvider);
    await settings.write('library.view', next.view.name);
    await settings.write('library.sort', next.sort.name);
    await settings.write('library.kind', next.kind.name);
    await settings.write(
      'library.groupFranchises',
      next.groupFranchises.toString(),
    );
  }
}

final libraryPrefsProvider =
    AsyncNotifierProvider<LibraryPrefsNotifier, LibraryPrefs>(
      LibraryPrefsNotifier.new,
    );

final franchiseRepositoryProvider = Provider<FranchiseRepository>(
  (ref) => FranchiseRepository(
    ref.watch(databaseProvider),
    ref.watch(libraryRepositoryProvider),
  ),
);

final franchisesProvider = StreamProvider<Map<String, Franchise>>(
  (ref) => ref.watch(franchiseRepositoryProvider).watchFranchises(),
);

final _franchisePartsProvider = StreamProvider.family<List<Anime>, String>(
  (ref, key) => ref.watch(franchiseRepositoryProvider).watchParts(key),
);

final _franchiseRelationsProvider =
    StreamProvider.family<List<AnimeRelation>, String>(
      (ref, key) => ref.watch(franchiseRepositoryProvider).watchRelations(key),
    );

final watchOrderProvider = Provider.family<AsyncValue<WatchOrder>, String>((
  ref,
  key,
) {
  final parts = ref.watch(_franchisePartsProvider(key));
  final relations = ref.watch(_franchiseRelationsProvider(key));
  if (parts.hasError) return AsyncError(parts.error!, parts.stackTrace!);
  if (!parts.hasValue || !relations.hasValue) return const AsyncLoading();
  return AsyncData(buildWatchOrder(parts.value!, relations.value!));
});

final noticesRepositoryProvider = Provider<NoticesRepository>(
  (ref) => NoticesRepository(ref.watch(databaseProvider)),
);

final noticesProvider = StreamProvider<List<Notice>>(
  (ref) => ref.watch(noticesRepositoryProvider).watchAll(),
);

final unreadNoticesProvider = StreamProvider<int>(
  (ref) => ref.watch(noticesRepositoryProvider).watchUnread(),
);

final partyHistoryRepositoryProvider = Provider<PartyHistoryRepository>(
  (ref) => PartyHistoryRepository(ref.watch(databaseProvider)),
);

final partyHistoryProvider = StreamProvider<List<PartySession>>(
  (ref) => ref.watch(partyHistoryRepositoryProvider).watchAll(),
);

final partyPeopleProvider = StreamProvider<Map<String, String>>(
  (ref) => ref.watch(partyHistoryRepositoryProvider).watchPeople(),
);

final userGroupsRepositoryProvider = Provider<UserGroupsRepository>(
  (ref) => UserGroupsRepository(ref.watch(databaseProvider)),
);

final userGroupsProvider = StreamProvider<List<UserGroup>>(
  (ref) => ref.watch(userGroupsRepositoryProvider).watchGroups(),
);

final groupMembersProvider = StreamProvider<Map<String, Set<String>>>(
  (ref) => ref.watch(userGroupsRepositoryProvider).watchMembers(),
);

final queueRepositoryProvider = Provider<QueueRepository>(
  (ref) => QueueRepository(
    ref.watch(databaseProvider),
    ref.watch(libraryRepositoryProvider),
  ),
);

final activeQueuesProvider = StreamProvider<Map<String, ActiveQueue>>(
  (ref) => ref.watch(queueRepositoryProvider).watchActive(),
);

class AppPrefsNotifier extends AsyncNotifier<AppPrefs> {
  @override
  Future<AppPrefs> build() async => AppPrefs.fromSettings(
    await ref.read(settingsRepositoryProvider).readAll(),
  );

  Future<void> change(AppPrefs Function(AppPrefs) edit) async {
    final next = edit(state.value ?? const AppPrefs());
    state = AsyncData(next);
    final settings = ref.read(settingsRepositoryProvider);
    for (final MapEntry(:key, :value) in next.toSettings().entries) {
      await settings.write(key, value);
    }
  }
}

final appPrefsProvider = AsyncNotifierProvider<AppPrefsNotifier, AppPrefs>(
  AppPrefsNotifier.new,
);

final watchLinksRepositoryProvider = Provider<WatchLinksRepository>(
  (ref) => WatchLinksRepository(ref.watch(databaseProvider)),
);

final watchLinksProvider = StreamProvider.family<List<WatchLink>, int>(
  (ref, animeId) => ref.watch(watchLinksRepositoryProvider).watchLinks(animeId),
);

final watchSourceProvider = Provider<WatchSource>(
  (ref) => YummyAnimeSource(
    client: ref.watch(yummyClientProvider),
    settings: ref.watch(settingsRepositoryProvider),
    host: ref.watch(appPrefsProvider).value?.effectiveYummyHost ?? YummyHost.ru,
  ),
);

final yummyClientProvider = Provider<YummyClient>((ref) => YummyClient());

final siteEpisodesRepositoryProvider = Provider<SiteEpisodesRepository>(
  (ref) => SiteEpisodesRepository(
    ref.watch(databaseProvider),
    ref.watch(settingsRepositoryProvider),
    ref.watch(yummyClientProvider),
  ),
);

final siteEpisodesProvider = StreamProvider.family<SiteEpisodesInfo, int>(
  (ref, animeId) => ref.watch(siteEpisodesRepositoryProvider).watch(animeId),
);

final siteEpisodesRefreshProvider = FutureProvider.family<void, int>((
  ref,
  animeId,
) async {
  final repository = ref.read(siteEpisodesRepositoryProvider);
  final info = await repository.read(animeId);
  final checkedAt = info.checkedAt;
  if (checkedAt != null &&
      DateTime.now().difference(checkedAt) < const Duration(hours: 1)) {
    return;
  }
  try {
    await repository.refresh(animeId);
  } catch (_) {}
});

final journalProvider = StreamProvider<List<JournalEvent>>(
  (ref) => ref.watch(libraryRepositoryProvider).watchJournal(),
);

final animeGenresProvider = FutureProvider<List<AnimeGenre>>(
  (ref) => ref.watch(shikimoriClientProvider).animeGenres(),
);
