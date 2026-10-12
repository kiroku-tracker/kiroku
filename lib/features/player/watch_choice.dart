import '../../data/database/app_database.dart';
import '../../data/database/library_repository.dart';
import '../../data/database/watch_status.dart';

/// Серия и озвучка, которые открыть на сайте.
typedef WatchChoice = ({int? episode, String? dubbing});

/// Следующая серия и озвучка тайтла: выбранная у тайтла или франшизы,
/// иначе та, в которой смотрели последний раз.
WatchChoice watchChoice(LibraryItem? item, Franchise? franchise) {
  if (item == null) return (episode: null, dubbing: null);
  final available = item.anime.release.availableEpisodes;
  var episode = item.progress.nextEpisode;
  if (available > 0 && episode > available) {
    episode = item.status == WatchStatus.completed ? 1 : available;
  }
  String? nonEmpty(String? value) =>
      value == null || value.isEmpty ? null : value;
  final dubbing =
      nonEmpty(item.entry.dubbing) ??
      nonEmpty(franchise?.dubbing) ??
      nonEmpty(item.entry.dubbingSeen) ??
      nonEmpty(franchise?.dubbingSeen);
  return (episode: episode, dubbing: dubbing);
}

/// Подпись озвучки в списке на сайте.
String siteDubbingLabel(String dubbing) =>
    dubbing.startsWith('Субтитры') ? dubbing : 'Озвучка $dubbing';
