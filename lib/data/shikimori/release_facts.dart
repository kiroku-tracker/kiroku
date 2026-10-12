/// Состояние эфира тайтла.
class ReleaseFacts {
  const ReleaseFacts({
    required this.status,
    required this.episodes,
    required this.aired,
  });

  final String? status;

  final int episodes;

  final int aired;

  String? get effectiveStatus {
    if (const {'anons', 'ongoing', 'released'}.contains(status)) return status;
    if (episodes > 0 && aired >= episodes) return 'released';
    if (aired > 0) return 'ongoing';
    return null;
  }

  bool get isAnnounced => effectiveStatus == 'anons';
  bool get isOngoing => effectiveStatus == 'ongoing';
  bool get isReleased => effectiveStatus == 'released';

  int get availableEpisodes {
    if (isReleased) return episodes > 0 ? episodes : aired;
    if (aired > 0) return aired;
    return isAnnounced ? 0 : episodes;
  }

  /// Серия ещё не вышла.
  bool isUnaired(int episode) {
    if (isReleased || episode <= aired) return false;
    return aired > 0 || isOngoing || isAnnounced;
  }

  bool get canComplete => isReleased && availableEpisodes > 0;
}
