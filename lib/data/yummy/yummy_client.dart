import 'dart:convert';

import 'package:http/http.dart' as http;

class YummyException implements Exception {
  const YummyException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Тайтл на YummyAnime.
class YummyTitle {
  const YummyTitle({required this.slug, this.id});

  final String slug;

  final int? id;
}

/// Запросы к API YummyAnime.
class YummyClient {
  YummyClient({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  static final _base = Uri.parse('https://api.yani.tv');
  static const _timeout = Duration(seconds: 15);
  static const _headers = {'Accept': 'application/json', 'Lang': 'ru'};

  final http.Client _http;

  /// Тайтл по номеру Shikimori.
  Future<YummyTitle?> findByShikimoriId(int shikimoriId) async {
    final json = await _get(
      _base.replace(
        path: '/anime',
        queryParameters: {'shikimori_ids': '$shikimoriId'},
      ),
    );
    final list = json is Map ? json['response'] : null;
    if (list is! List || list.isEmpty || list.first is! Map) return null;
    final first = list.first as Map;
    final slug = first['anime_url'];
    final id = first['anime_id'];
    if (slug is! String || slug.isEmpty) return null;
    return YummyTitle(slug: slug, id: id is num ? id.toInt() : null);
  }

  Future<String?> slugByShikimoriId(int shikimoriId) async =>
      (await findByShikimoriId(shikimoriId))?.slug;

  /// Номер Shikimori по адресу тайтла.
  Future<int?> shikimoriIdBySlug(String slug) async {
    final response = await _http
        .get(
          _base.replace(path: '/anime/${Uri.encodeComponent(slug)}'),
          headers: _headers,
        )
        .timeout(_timeout);
    if (response.statusCode != 200) return null;
    final json = jsonDecode(utf8.decode(response.bodyBytes));
    final ids = (json is Map ? json['response'] : null) is Map
        ? (json['response'] as Map)['remote_ids']
        : null;
    final id = ids is Map ? ids['shikimori_id'] : null;
    return id is num && id > 0 ? id.toInt() : null;
  }

  Future<List<YummyVideo>> videos(int yummyId) async {
    final json = await _get(_base.replace(path: '/anime/$yummyId/videos'));
    final list = json is Map ? json['response'] : null;
    if (list is! List) return const [];
    return [
      for (final video in list)
        if (video is Map)
          if ((
                number: int.tryParse('${video['number']}'),
                dubbing: video['data'] is Map
                    ? dubbingName((video['data'] as Map)['dubbing'])
                    : null,
              )
              case (number: final number?, dubbing: final dubbing?))
            YummyVideo(
              episode: number,
              dubbing: dubbing,
              player: playerKey('${video['iframe_url'] ?? ''}'),
            ),
    ];
  }

  /// Серии по озвучкам.
  Future<Map<String, int>> episodesByDubbing(int yummyId) async {
    final result = <String, int>{};
    for (final video in await videos(yummyId)) {
      if (video.episode > (result[video.dubbing] ?? 0)) {
        result[video.dubbing] = video.episode;
      }
    }
    return result;
  }

  Future<String?> dubbingOfPlayer(int yummyId, String playerUrl) async {
    final key = playerKey(playerUrl);
    if (key == null) return null;
    for (final video in await videos(yummyId)) {
      if (video.player == key) return video.dubbing;
    }
    return null;
  }

  /// Озвучка из адреса плеера.
  static String? dubbingInPlayerUrl(String url) {
    final uri = Uri.tryParse(url.startsWith('//') ? 'https:$url' : url);
    final value = uri?.queryParameters['dubbing'] ?? '';
    final full = value.startsWith('Озвучка ') || value.startsWith('Субтитры ');
    return full ? dubbingName(value) : null;
  }

  static String? playerKey(String url) {
    final uri = Uri.tryParse(url.startsWith('//') ? 'https:$url' : url);
    if (uri == null) return null;
    if (uri.host.contains('kodik')) {
      final path = uri.pathSegments.where((part) => part.isNotEmpty).take(3);
      return path.length < 3 ? null : 'kodik:${path.join('/')}';
    }
    if (uri.path.contains('iframeCVH')) {
      final code = uri.queryParameters['dubbing_code'];
      return code == null || code.isEmpty ? null : 'cvh:$code';
    }
    return null;
  }

  static String? dubbingName(Object? value) {
    if (value is! String) return null;
    final name = value.trim().replaceFirst(RegExp(r'^Озвучка\s+'), '');
    return name.isEmpty ? null : name;
  }

  /// Озвучка, а не субтитры.
  static bool isVoiceOver(String dubbing) => !dubbing.startsWith('Субтитры');

  Future<Object?> _get(Uri uri) async {
    final response = await _http.get(uri, headers: _headers).timeout(_timeout);
    if (response.statusCode != 200) {
      throw YummyException('YummyAnime ответил ошибкой ${response.statusCode}');
    }
    return jsonDecode(utf8.decode(response.bodyBytes));
  }
}

class YummyVideo {
  const YummyVideo({
    required this.episode,
    required this.dubbing,
    required this.player,
  });

  final int episode;

  final String dubbing;

  final String? player;
}
