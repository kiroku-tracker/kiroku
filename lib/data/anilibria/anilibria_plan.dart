import '../database/watch_status.dart';
import '../import/import_plan.dart';
import '../shikimori/anime_info.dart';
import 'anilibria_client.dart';

/// Данные тайтлов Shikimori по номерам.
typedef AnimeLookup = Future<Map<int, AnimeInfo>> Function(List<int> ids);

const _priority = ['WATCHING', 'WATCHED', 'POSTPONED', 'ABANDONED', 'PLANNED'];

WatchStatus _statusOf(String collection) => switch (collection) {
  'WATCHING' => WatchStatus.watching,
  'WATCHED' => WatchStatus.completed,
  'POSTPONED' => WatchStatus.paused,
  'ABANDONED' => WatchStatus.dropped,
  _ => WatchStatus.planned,
};

class _Release {
  _Release(this.title, this.shikimoriId);

  final String title;
  final int? shikimoriId;
  String? collection;
  var favorite = false;
  final watched = <int, DateTime>{};

  void collect(String type) {
    final current = collection;
    if (current == null ||
        _priority.indexOf(type) < _priority.indexOf(current)) {
      collection = type;
    }
  }
}

/// Список AniLibria в виде тайтлов для переноса.
Future<List<ImportItem>> aniLibriaItems({
  required List<AniLibriaCollectionItem> collections,
  required List<AniLibriaFavorite> favorites,
  required List<AniLibriaView> history,
  required AnimeLookup lookup,
}) async {
  final releases = <int, _Release>{};
  _Release release(int id, String title, int? shikimoriId) =>
      releases.putIfAbsent(id, () => _Release(title, shikimoriId));

  for (final item in collections) {
    release(
      item.releaseId,
      item.title,
      item.shikimoriId,
    ).collect(item.collection);
  }
  for (final item in favorites) {
    release(item.releaseId, item.title, item.shikimoriId).favorite = true;
  }
  for (final view in history) {
    final entry = release(view.releaseId, view.title, view.shikimoriId);
    final number = view.ordinal.toInt();
    if (!view.watched || view.ordinal != number || number < 1) continue;
    final known = entry.watched[number];
    if (known == null || view.updatedAt.isAfter(known)) {
      entry.watched[number] = view.updatedAt;
    }
  }

  final ids = {
    for (final entry in releases.values)
      if (entry.shikimoriId != null) entry.shikimoriId!,
  }.toList();
  final animes = ids.isEmpty ? const <int, AnimeInfo>{} : await lookup(ids);

  final items = <ImportItem>[];
  for (final entry in releases.values) {
    final anime = entry.shikimoriId == null ? null : animes[entry.shikimoriId];
    final episodes = [
      for (final number in entry.watched.keys.toList()..sort())
        ImportEpisode(number, entry.watched[number]),
    ];

    WatchStatus? status;
    if (entry.collection != null) {
      status = _statusOf(entry.collection!);
    } else if (episodes.isNotEmpty) {
      final aired = anime?.release.availableEpisodes ?? 0;
      status = aired > 0 && episodes.length >= aired
          ? WatchStatus.completed
          : WatchStatus.watching;
    } else if (entry.favorite) {
      status = WatchStatus.planned;
    }
    if (status == null) continue;

    var item = ImportItem(
      sourceTitle: entry.title,
      anime: anime,
      status: WatchStatus.watching,
      favorite: entry.favorite,
      viewings: episodes.isEmpty
          ? const []
          : [ImportViewing(completed: false, episodes: episodes)],
    );
    if (status != WatchStatus.watching) item = item.withStatus(status);
    items.add(item);
  }
  return items;
}
