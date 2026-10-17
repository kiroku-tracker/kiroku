import 'dart:convert';

import 'package:http/http.dart' as http;

import 'anime_info.dart';
import 'anime_query.dart';
import 'rate_limiter.dart';
import 'user_rate.dart';

class FranchiseParts {
  const FranchiseParts({required this.key, required this.parts});

  final String key;
  final List<AnimeInfo> parts;
}

class ShikimoriException implements Exception {
  const ShikimoriException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Запросы к Shikimori.
class ShikimoriClient {
  ShikimoriClient({http.Client? httpClient, RateLimiter? rateLimiter})
    : _http = httpClient ?? http.Client(),
      _limiter = rateLimiter ?? RateLimiter();

  static const siteUrl = 'https://shikimori.io';
  static final _graphqlUrl = Uri.parse('$siteUrl/api/graphql');

  static const _userAgent = 'Kiroku';
  static const _timeout = Duration(seconds: 15);

  static const _animeFields = '''
    id name russian kind score episodes episodesAired status nextEpisodeAt
    franchise
    airedOn { year month day }
    poster { mainUrl main2xUrl originalUrl }
    statusesStats { status count }
  ''';

  static const _relationFields = 'related { relationKind anime { id } }';

  static const _detailFields = '''
    description duration rating
    genres { russian }
    studios { name }
  ''';

  final http.Client _http;
  final RateLimiter _limiter;

  /// Страница тайтла на Shikimori.
  static Uri animePage(int id) => Uri.parse('$siteUrl/animes/$id');

  /// Страница франшизы на Shikimori.
  static Uri franchisePage(int id) =>
      Uri.parse('$siteUrl/animes/$id/franchise');

  /// Поиск по названию.
  Future<List<AnimeInfo>> searchAnimes(String query, {int limit = 30}) async {
    final data = await _graphql(
      'query (\$search: String!, \$limit: Int!) '
      '{ animes(search: \$search, limit: \$limit) { $_animeFields } }',
      {'search': query, 'limit': limit},
    );
    final animes = _parseAnimes(data);
    return animes..sort((left, right) => right.popularity - left.popularity);
  }

  /// Каталог с фильтрами.
  Future<List<AnimeInfo>> browseAnimes(
    AnimeQuery query, {
    int page = 1,
    int limit = 40,
  }) async {
    final search = query.search.trim();
    final args = [
      'limit: $limit',
      'page: $page',
      'order: ${query.order.code}',
      if (search.isNotEmpty) r'search: $search',
      if (query.season case final season?) 'season: ${jsonEncode(season)}',
      if (query.kind.code case final kind?) 'kind: ${jsonEncode(kind)}',
      if (query.status.code case final status?) 'status: ${jsonEncode(status)}',
      if (query.genre case final genre?) 'genre: "${genre.id}"',
    ];
    final data = await _graphql(
      '${search.isEmpty ? 'query' : r'query ($search: String!)'} '
      '{ animes(${args.join(', ')}) { $_animeFields } }',
      {if (search.isNotEmpty) 'search': search},
    );
    return _parseAnimes(data);
  }

  Future<List<AnimeGenre>> animeGenres() async {
    final data = await _graphql(
      'query { genres(entryType: Anime) { id russian } }',
      const {},
    );
    return [
      for (final genre in (data['genres'] as List?) ?? const [])
        if (int.tryParse('${(genre as Map)['id']}') case final id?)
          AnimeGenre(id: id, name: '${genre['russian']}'),
    ]..sort((left, right) => left.name.compareTo(right.name));
  }

  /// Данные нескольких тайтлов.
  Future<List<AnimeInfo>> getAnimes(
    List<int> ids, {
    bool withRelations = false,
  }) async {
    final fields = withRelations
        ? '$_animeFields $_relationFields'
        : _animeFields;
    final result = <AnimeInfo>[];
    for (var start = 0; start < ids.length; start += 50) {
      final chunk = ids.skip(start).take(50).toList();
      final data = await _graphql(
        'query (\$ids: String!, \$limit: Int!) '
        '{ animes(ids: \$ids, limit: \$limit) { $fields } }',
        {'ids': chunk.join(','), 'limit': chunk.length},
      );
      result.addAll(_parseAnimes(data));
    }
    return result;
  }

  /// Все части франшизы тайтла.
  Future<FranchiseParts?> getFranchise(int id) async {
    final data = await _graphql(
      'query (\$ids: String!) '
      '{ animes(ids: \$ids, limit: 1) { id franchise chronology { id } } }',
      {'ids': '$id'},
    );
    final animes = (data['animes'] as List?) ?? const [];
    if (animes.isEmpty) return null;
    final json = animes.first as Map<String, dynamic>;
    final key = json['franchise'] as String?;
    if (key == null || key.isEmpty) return null;
    final ids = {
      id,
      for (final part in (json['chronology'] as List?) ?? const [])
        int.parse((part as Map)['id'].toString()),
    };
    final parts = await getAnimes(ids.toList(), withRelations: true);
    return FranchiseParts(key: key, parts: parts);
  }

  /// Тайтл с подробностями.
  Future<AnimeInfo?> getAnime(int id) async {
    final data = await _graphql(
      'query (\$ids: String!) '
      '{ animes(ids: \$ids, limit: 1) { $_animeFields $_detailFields } }',
      {'ids': '$id'},
    );
    final animes = _parseAnimes(data);
    return animes.isEmpty ? null : animes.first;
  }

  /// Пользователь по нику или ссылке.
  Future<ShikimoriUser?> findUser(String input) async {
    final nickname = nicknameOf(input);
    if (nickname.isEmpty) return null;
    final response = await _limiter.run(
      () => _http
          .get(
            Uri.parse('$siteUrl/api/users/${Uri.encodeComponent(nickname)}')
                .replace(queryParameters: {'is_nickname': '1'}),
            headers: {'User-Agent': _userAgent},
          )
          .timeout(_timeout),
    );
    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) {
      throw ShikimoriException(
        'Shikimori ответил ошибкой ${response.statusCode}',
      );
    }
    final json = jsonDecode(utf8.decode(response.bodyBytes));
    if (json is! Map || json['id'] == null) return null;
    return ShikimoriUser(
      id: int.parse(json['id'].toString()),
      nickname: (json['nickname'] as String?) ?? nickname,
      avatar: json['avatar'] as String?,
    );
  }

  /// Ник из строки или ссылки.
  static String nicknameOf(String input) {
    final text = input.trim();
    final uri = Uri.tryParse(
      text.contains('://') || !text.contains('/') ? text : 'https://$text',
    );
    if (uri != null && uri.host.contains('shiki')) {
      return uri.pathSegments.isEmpty ? '' : uri.pathSegments.first;
    }
    return text;
  }

  /// Список аниме пользователя.
  Future<List<UserRate>> userRates(
    int userId, {
    void Function(int loaded)? onProgress,
  }) async {
    const limit = 50;
    final result = <UserRate>[];
    for (var page = 1; ; page++) {
      final data = await _graphql(
        'query (\$userId: ID!, \$page: PositiveInt!, \$limit: PositiveInt!) '
        '{ userRates(userId: \$userId, targetType: Anime, page: \$page, '
        'limit: \$limit, order: { field: id, order: asc }) '
        '{ status score episodes rewatches text createdAt updatedAt '
        'anime { $_animeFields } } }',
        {'userId': '$userId', 'page': page, 'limit': limit},
      );
      final rows = (data['userRates'] as List?) ?? const [];
      for (final row in rows) {
        final json = row as Map<String, dynamic>;
        if (json['anime'] is Map) result.add(UserRate.fromGraphql(json));
      }
      onProgress?.call(result.length);
      if (rows.length < limit) return result;
    }
  }

  List<AnimeInfo> _parseAnimes(Map<String, dynamic> data) => [
    for (final json in (data['animes'] as List?) ?? const [])
      AnimeInfo.fromGraphql(json as Map<String, dynamic>),
  ];

  Future<Map<String, dynamic>> _graphql(
    String query,
    Map<String, dynamic> variables, {
    bool retried = false,
  }) async {
    final response = await _limiter.run(
      () => _http
          .post(
            _graphqlUrl,
            headers: {
              'Content-Type': 'application/json',
              'User-Agent': _userAgent,
            },
            body: jsonEncode({'query': query, 'variables': variables}),
          )
          .timeout(_timeout),
    );

    if (response.statusCode == 429 && !retried) {
      final seconds = int.tryParse(response.headers['retry-after'] ?? '') ?? 1;
      await Future<void>.delayed(Duration(seconds: seconds.clamp(1, 5)));
      return _graphql(query, variables, retried: true);
    }
    if (response.statusCode != 200) {
      throw ShikimoriException(
        'Shikimori ответил ошибкой ${response.statusCode}',
      );
    }

    final payload =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final errors = payload['errors'] as List?;
    if (errors != null && errors.isNotEmpty) {
      throw ShikimoriException(
        errors.map((error) => (error as Map)['message']).join('; '),
      );
    }
    return (payload['data'] as Map<String, dynamic>?) ?? const {};
  }
}
