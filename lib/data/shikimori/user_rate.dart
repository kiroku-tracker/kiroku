import '../database/watch_status.dart';
import 'anime_info.dart';

class ShikimoriUser {
  const ShikimoriUser({required this.id, required this.nickname, this.avatar});

  final int id;
  final String nickname;
  final String? avatar;
}

/// Тайтл из списка пользователя.
class UserRate {
  const UserRate({
    required this.anime,
    required this.status,
    this.score = 0,
    this.episodes = 0,
    this.rewatches = 0,
    this.text,
    this.createdAt,
    this.updatedAt,
  });

  factory UserRate.fromGraphql(Map<String, dynamic> json) => UserRate(
    anime: AnimeInfo.fromGraphql(json['anime'] as Map<String, dynamic>),
    status: (json['status'] as String?) ?? 'planned',
    score: (json['score'] as num?)?.toInt() ?? 0,
    episodes: (json['episodes'] as num?)?.toInt() ?? 0,
    rewatches: (json['rewatches'] as num?)?.toInt() ?? 0,
    text: json['text'] as String?,
    createdAt: DateTime.tryParse((json['createdAt'] as String?) ?? ''),
    updatedAt: DateTime.tryParse((json['updatedAt'] as String?) ?? ''),
  );

  final AnimeInfo anime;

  final String status;

  final int score;

  final int episodes;

  final int rewatches;

  final String? text;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  WatchStatus get watchStatus => switch (status) {
    'watching' || 'rewatching' => WatchStatus.watching,
    'completed' => WatchStatus.completed,
    'on_hold' => WatchStatus.paused,
    'dropped' => WatchStatus.dropped,
    _ => WatchStatus.planned,
  };

  int get completedViewings => switch (status) {
    'completed' || 'rewatching' => 1 + rewatches,
    _ => 0,
  };

  int get completedEpisodes {
    if (status == 'completed' && episodes > 0) return episodes;
    final release = anime.release;
    return release.episodes > 0 ? release.episodes : release.availableEpisodes;
  }

  int get currentEpisodes => status == 'completed' ? 0 : episodes;
}
