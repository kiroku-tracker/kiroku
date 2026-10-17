import 'release_facts.dart';

/// Тайтл из Shikimori.
/// Оригиналы постеров по адресу обычного постера, для тайтлов, которых нет
/// в базе (например, в поиске).
final knownPosterOriginals = <String, String>{};

class AnimeInfo {
  const AnimeInfo({
    required this.id,
    required this.name,
    required this.russian,
    this.kind,
    this.score,
    this.episodes = 0,
    this.episodesAired = 0,
    this.releaseStatus,
    this.nextEpisodeAt,
    this.airedOn,
    this.posterUrl,
    this.posterOriginalUrl,
    this.popularity = 0,
    this.details,
    this.franchise,
    this.relations,
  });

  factory AnimeInfo.fromGraphql(Map<String, dynamic> json) {
    final poster = json['poster'] as Map?;
    final posterUrl =
        poster?['main2xUrl'] as String? ?? poster?['mainUrl'] as String?;
    final posterOriginalUrl = poster?['originalUrl'] as String?;
    if (posterUrl != null && posterOriginalUrl != null) {
      knownPosterOriginals[posterUrl] = posterOriginalUrl;
    }
    final stats = (json['statusesStats'] as List?) ?? const [];
    final hasDetails = json.containsKey('description');
    return AnimeInfo(
      id: int.parse(json['id'].toString()),
      name: (json['name'] as String?) ?? '',
      russian: (json['russian'] as String?) ?? '',
      kind: json['kind'] as String?,
      score: (json['score'] as num?)?.toDouble(),
      episodes: (json['episodes'] as num?)?.toInt() ?? 0,
      episodesAired: (json['episodesAired'] as num?)?.toInt() ?? 0,
      releaseStatus: json['status'] as String?,
      nextEpisodeAt: DateTime.tryParse(
        (json['nextEpisodeAt'] as String?) ?? '',
      ),
      airedOn: _incompleteDate(json['airedOn']),
      posterUrl: posterUrl,
      posterOriginalUrl: posterOriginalUrl,
      popularity: stats.fold<int>(
        0,
        (total, entry) =>
            total + (((entry as Map)['count'] as num?)?.toInt() ?? 0),
      ),
      franchise: json.containsKey('franchise')
          ? (json['franchise'] as String?) ?? ''
          : null,
      relations: json.containsKey('related')
          ? [
              for (final related in (json['related'] as List?) ?? const [])
                if ((related as Map)['anime'] is Map)
                  RelatedAnime(
                    relatedId: int.parse(
                      (related['anime'] as Map)['id'].toString(),
                    ),
                    relation: (related['relationKind'] as String?) ?? 'other',
                  ),
            ]
          : null,
      details: hasDetails
          ? AnimeDetails(
              description: cleanDescription(json['description'] as String?),
              genres: [
                for (final genre in (json['genres'] as List?) ?? const [])
                  if ((genre as Map)['russian'] is String)
                    genre['russian'] as String,
              ],
              studios: [
                for (final studio in (json['studios'] as List?) ?? const [])
                  if ((studio as Map)['name'] is String)
                    studio['name'] as String,
              ],
              episodeDuration: (json['duration'] as num?)?.toInt(),
              ageRating: json['rating'] as String?,
            )
          : null,
    );
  }

  final int id;
  final String name;
  final String russian;
  final String? kind;
  final double? score;
  final int episodes;
  final int episodesAired;

  final String? releaseStatus;
  final DateTime? nextEpisodeAt;

  final String? airedOn;

  /// Постер для карточек и списков, 450 точек в ширину.
  final String? posterUrl;

  /// Постер в полном размере для страницы тайтла.
  final String? posterOriginalUrl;

  final int popularity;

  final AnimeDetails? details;

  final String? franchise;

  final List<RelatedAnime>? relations;

  String get title => russian.isNotEmpty ? russian : name;

  int? get year => int.tryParse(airedOn?.split('-').first ?? '');

  ReleaseFacts get release => ReleaseFacts(
    status: releaseStatus,
    episodes: episodes,
    aired: episodesAired,
  );

  static String? _incompleteDate(Object? value) {
    if (value is! Map) return null;
    final year = (value['year'] as num?)?.toInt();
    if (year == null) return null;
    final month = (value['month'] as num?)?.toInt();
    final day = (value['day'] as num?)?.toInt();
    final parts = [
      '$year',
      if (month != null) month.toString().padLeft(2, '0'),
      if (month != null && day != null) day.toString().padLeft(2, '0'),
    ];
    return parts.join('-');
  }
}

/// Связь с другим тайтлом.
class RelatedAnime {
  const RelatedAnime({required this.relatedId, required this.relation});

  final int relatedId;
  final String relation;
}

class AnimeDetails {
  const AnimeDetails({
    this.description,
    this.genres = const [],
    this.studios = const [],
    this.episodeDuration,
    this.ageRating,
  });

  final String? description;
  final List<String> genres;
  final List<String> studios;

  final int? episodeDuration;

  final String? ageRating;
}

/// Убирает разметку из описания.
String? cleanDescription(String? value) {
  if (value == null) return null;
  final text = value
      .replaceAll(RegExp(r'\[/?[a-z_]+(?:=[^\]]*)?\]'), '')
      .replaceAll('\r\n', '\n')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .trim();
  return text.isEmpty ? null : text;
}
