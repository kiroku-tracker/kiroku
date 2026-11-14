import '../database/watch_status.dart';
import '../shikimori/anime_info.dart';

/// Отмеченная серия, дата просмотра необязательна.
class ImportEpisode {
  const ImportEpisode(this.number, [this.at]);

  final int number;
  final DateTime? at;
}

/// Один просмотр тайтла.
class ImportViewing {
  const ImportViewing({required this.completed, required this.episodes});

  final bool completed;
  final List<ImportEpisode> episodes;
}

/// Куда попадёт тайтл при переносе.
enum ImportGroup { add, existing, notFound }

/// Тайтл из чужого списка.
class ImportItem {
  const ImportItem({
    required this.sourceTitle,
    this.anime,
    this.status = WatchStatus.planned,
    this.score = 0,
    this.note = '',
    this.favorite = false,
    this.viewings = const [],
    this.createdAt,
    this.updatedAt,
  });

  final String sourceTitle;
  final AnimeInfo? anime;
  final WatchStatus status;
  final int score;
  final String note;
  final bool favorite;
  final List<ImportViewing> viewings;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  int? get shikimoriId => anime?.id;

  /// Серий в последнем просмотре.
  int get episodesMarked =>
      viewings.isEmpty ? 0 : viewings.last.episodes.length;

  ImportItem _copy({
    AnimeInfo? anime,
    WatchStatus? status,
    bool? favorite,
    List<ImportViewing>? viewings,
  }) => ImportItem(
    sourceTitle: sourceTitle,
    anime: anime ?? this.anime,
    status: status ?? this.status,
    score: score,
    note: note,
    favorite: favorite ?? this.favorite,
    viewings: viewings ?? this.viewings,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  ImportItem withFavorite(bool value) => _copy(favorite: value);

  ImportItem withAnime(AnimeInfo value) => _copy(anime: value);

  /// Меняет статус; «Просмотрено» отмечает все серии и завершает просмотр.
  ImportItem withStatus(WatchStatus value) {
    final head = viewings.isEmpty
        ? const <ImportViewing>[]
        : viewings.sublist(0, viewings.length - 1);
    final last = viewings.isEmpty
        ? const ImportViewing(completed: false, episodes: [])
        : viewings.last;
    if (value != WatchStatus.completed) {
      return _copy(
        status: value,
        viewings: [
          ...head,
          if (viewings.isNotEmpty)
            ImportViewing(completed: false, episodes: last.episodes),
        ],
      );
    }
    final total = _totalEpisodes();
    final episodes = [
      for (var n = 1; n <= total; n++)
        ImportEpisode(n, _dateOf(last.episodes, n)),
    ];
    return _copy(
      status: value,
      viewings: [
        ...head,
        ImportViewing(completed: true, episodes: episodes),
      ],
    );
  }

  /// Оставляет в последнем просмотре серии с первой по [count].
  ImportItem withEpisodeCount(int count) {
    final head = viewings.isEmpty
        ? const <ImportViewing>[]
        : viewings.sublist(0, viewings.length - 1);
    final last = viewings.isEmpty
        ? const ImportViewing(completed: false, episodes: [])
        : viewings.last;
    final episodes = [
      for (var n = 1; n <= count; n++)
        ImportEpisode(n, _dateOf(last.episodes, n)),
    ];
    return _copy(
      viewings: [
        ...head,
        ImportViewing(completed: last.completed, episodes: episodes),
      ],
    );
  }

  int _totalEpisodes() {
    final release = anime?.release;
    if (release == null) return episodesMarked;
    return release.episodes > 0 ? release.episodes : release.availableEpisodes;
  }

  static DateTime? _dateOf(List<ImportEpisode> episodes, int number) {
    for (final episode in episodes) {
      if (episode.number == number) return episode.at;
    }
    return null;
  }
}

/// Список из чужого сервиса, готовый к переносу.
class ImportPlan {
  const ImportPlan({
    required this.sourceName,
    required this.userName,
    required this.items,
  });

  final String sourceName;
  final String userName;
  final List<ImportItem> items;
}
