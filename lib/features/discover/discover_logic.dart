import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../data/database/franchise_rules.dart';
import '../../data/database/library_repository.dart';
import '../../data/database/watch_status.dart';
import '../../data/providers.dart';
import '../../data/shikimori/anime_info.dart';
import '../../data/shikimori/shikimori_client.dart';
import '../franchise/watch_order_list.dart';

/// Следующая непросмотренная часть начатой франшизы.
typedef Continuation = ({
  Anime anime,
  LibraryItem? item,
  String franchise,
  int left,
  DateTime lastSeen,
});

/// Похожий тайтл и на что он похож.
typedef SimilarPick = ({AnimeInfo anime, List<String> because});

/// Вышедшие части франшиз, которые начаты, но ещё не смотрелись: не в
/// библиотеке или в «Хочу посмотреть». Сначала недавние франшизы.
List<Continuation> franchiseContinuations(
  List<LibraryItem> library,
  Map<String, Franchise> franchises,
  WatchOrder? Function(String key) orderOf,
) {
  final keys = {
    for (final item in library)
      if (item.status == WatchStatus.completed ||
          item.status == WatchStatus.watching)
        ?franchiseKeyOf(item.entry, item.anime),
  };
  final result = <Continuation>[];
  for (final key in keys) {
    final parts = franchiseParts(key, orderOf(key), library);
    final next = [
      for (final part in parts.main)
        if (!part.anime.release.isAnnounced &&
            (part.item == null || part.item!.status == WatchStatus.planned))
          part,
    ];
    if (next.isEmpty) continue;
    final owned = [
      for (final part in [...parts.main, ...parts.extra])
        if (part.item != null) part.item!,
    ];
    if (owned.isEmpty) continue;
    result.add((
      anime: next.first.anime,
      item: next.first.item,
      franchise: franchiseName(franchises[key], owned),
      left: next.length,
      lastSeen: owned
          .map((item) => item.entry.updatedAt)
          .reduce((a, b) => a.isAfter(b) ? a : b),
    ));
  }
  result.sort((a, b) => b.lastSeen.compareTo(a.lastSeen));
  return result;
}

final franchiseContinuationsProvider = Provider<List<Continuation>>((ref) {
  final library = ref.watch(libraryItemsProvider).value ?? const [];
  final franchises = ref.watch(franchisesProvider).value ?? const {};
  return franchiseContinuations(
    library,
    franchises,
    (key) => ref.watch(watchOrderProvider(key)).value,
  );
});

/// Тайтлы, по которым ищется похожее: просмотренные с лучшими оценками.
List<LibraryItem> similarSeeds(List<LibraryItem> library, {int count = 12}) {
  final watched = [
    for (final item in library)
      if (item.status == WatchStatus.completed ||
          item.status == WatchStatus.watching)
        item,
  ];
  watched.sort((a, b) {
    final score = (b.entry.score ?? 0).compareTo(a.entry.score ?? 0);
    return score != 0 ? score : b.entry.updatedAt.compareTo(a.entry.updatedAt);
  });
  return watched.take(count).toList();
}

/// Похожие тайтлы по очкам: чем выше оценка исходного тайтла и чем выше
/// тайтл в его списке похожих, тем больше очков.
List<({int id, double points, List<String> because})> rankSimilar(
  Map<LibraryItem, List<int>> similar,
  Set<int> exclude,
) {
  final points = <int, double>{};
  final because = <int, List<String>>{};
  for (final MapEntry(key: seed, value: ids) in similar.entries) {
    final weight = (seed.entry.score ?? 7) / 10;
    for (final (rank, id) in ids.indexed) {
      if (exclude.contains(id)) continue;
      points[id] = (points[id] ?? 0) + weight / (1 + rank * 0.2);
      (because[id] ??= []).add(seed.anime.title);
    }
  }
  return [
    for (final MapEntry(key: id, value: value) in points.entries)
      (id: id, points: value, because: because[id]!),
  ]..sort((a, b) => b.points.compareTo(a.points));
}

/// Подбирает похожее на просмотренное: без тайтлов из библиотеки, их
/// франшиз и анонсов.
Future<List<SimilarPick>> loadSimilarPicks(
  ShikimoriClient client,
  List<LibraryItem> library,
) async {
  final seeds = similarSeeds(library);
  final similar = <LibraryItem, List<int>>{};
  for (final seed in seeds) {
    try {
      similar[seed] = await client.similarIds(seed.anime.id);
    } on Object {
      // Тайтл пропускается.
    }
  }
  if (similar.isEmpty && seeds.isNotEmpty) {
    throw const ShikimoriException('Shikimori не ответил');
  }
  final exclude = {for (final item in library) item.anime.id};
  final franchises = {for (final item in library) ?item.anime.franchise};
  final ranked = rankSimilar(similar, exclude).take(48).toList();
  if (ranked.isEmpty) return const [];
  final infos = {
    for (final info in await client.getAnimes([
      for (final pick in ranked) pick.id,
    ]))
      info.id: info,
  };
  return [
    for (final pick in ranked)
      if (infos[pick.id] case final info?
          when !franchises.contains(info.franchise) &&
              !info.release.isAnnounced &&
              !hiddenFranchiseKinds.contains(info.kind))
        (anime: info, because: pick.because.take(2).toList()),
  ].take(30).toList();
}

/// Тайтлы, отмеченные «Не интересно»: больше не предлагаются.
class DiscoverHiddenNotifier extends AsyncNotifier<Set<int>> {
  static const _key = 'discover.hidden';

  @override
  Future<Set<int>> build() async {
    final saved = await ref.read(settingsRepositoryProvider).readAll();
    return {
      for (final part in (saved[_key] ?? '').split(',')) ?int.tryParse(part),
    };
  }

  Future<void> hide(int id) => _save({...?state.value, id});

  Future<void> unhide(int id) => _save({...?state.value}..remove(id));

  Future<void> _save(Set<int> ids) async {
    state = AsyncData(ids);
    await ref.read(settingsRepositoryProvider).write(_key, ids.join(','));
  }
}

final discoverHiddenProvider =
    AsyncNotifierProvider<DiscoverHiddenNotifier, Set<int>>(
      DiscoverHiddenNotifier.new,
    );

/// Тайтл с описанием и жанрами для карточки.
final animeDetailsProvider = FutureProvider.family<AnimeInfo?, int>(
  (ref, id) => ref.read(shikimoriClientProvider).getAnime(id),
);
