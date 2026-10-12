// Распознавание тайтла и серии.

class MediaSession {
  const MediaSession({
    required this.app,
    required this.title,
    required this.status,
    required this.position,
    required this.duration,
    this.documents = const [],
  });

  factory MediaSession.fromMap(Map<Object?, Object?> map) => MediaSession(
    app: map['app'] as String? ?? '',
    title: map['title'] as String? ?? '',
    status: (map['status'] as num?)?.toInt() ?? 0,
    position: (map['position'] as num?)?.toDouble() ?? 0,
    duration: (map['duration'] as num?)?.toDouble() ?? 0,
    documents: [
      for (final document in (map['documents'] as List?) ?? const [])
        if (document is Map)
          (
            name: document['name'] as String? ?? '',
            url: document['url'] as String? ?? '',
          ),
    ],
  );

  final String app;

  final String title;

  final int status;

  final double position;
  final double duration;

  final List<({String name, String url})> documents;

  bool get playing => status == 4;

  double get ratio => duration <= 0 ? 0 : (position / duration).clamp(0, 1);
}

class Recognized {
  const Recognized({
    required this.title,
    this.shikimoriId,
    this.slug,
    this.episode,
    this.host,
    this.player,
  });

  final String title;

  final int? shikimoriId;

  final String? slug;

  final int? episode;

  final String? host;

  final String? player;
}

const yummyKeywords = ['YummyAnime', 'Ями Аниме'];

final _catalogItem = RegExp(
  r'//([a-z0-9.-]*yummyani.[a-z]+)/catalog/item/([^/?#]+)',
);
final _episodeParam = RegExp(r'[?&]episode=(\d+)');
final _animeIdParam = RegExp(r'[?&]anime_id=(\d+)');

/// Распознаёт серию YummyAnime.
Recognized? recognizeYummy(MediaSession session) {
  final isYummy =
      yummyKeywords.any(session.title.contains) ||
      session.documents.any((d) => d.url.contains('yummyani.'));
  if (!isYummy) return null;

  String? slug;
  String? host;
  int? episode;
  int? shikimoriId;
  String? player;
  for (final (name: _, :url) in session.documents) {
    final page = _catalogItem.firstMatch(url);
    if (page != null) {
      host ??= page.group(1);
      slug ??= page.group(2);
    }
    final isPlayer = url.contains('iframeCVH') || url.contains('kodik');
    if (!isPlayer) continue;
    player ??= url;
    episode ??= int.tryParse(_episodeParam.firstMatch(url)?.group(1) ?? '');
    if (url.contains('iframeCVH')) {
      shikimoriId ??= int.tryParse(
        _animeIdParam.firstMatch(url)?.group(1) ?? '',
      );
    }
  }
  return Recognized(
    title: cleanYummyTitle(session.title),
    shikimoriId: shikimoriId,
    slug: slug,
    episode: episode,
    host: host,
    player: player,
  );
}

/// Видео то же, что было, когда страница сайта была видна.
bool sameVideo(MediaSession session, double? knownDuration) {
  if (session.documents.isNotEmpty) return true;
  return knownDuration != null && (knownDuration - session.duration).abs() <= 2;
}

/// Название тайтла из заголовка вкладки.
String cleanYummyTitle(String title) {
  var result = title;
  for (final separator in const [' — смотреть', ' - смотреть', ' | ']) {
    final index = result.indexOf(separator);
    if (index > 0) result = result.substring(0, index);
  }
  return result.trim();
}
