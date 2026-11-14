import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Ошибка запроса к AniLibria.
class AniLibriaException implements Exception {
  const AniLibriaException(this.message, {this.unauthorized = false});

  final String message;
  final bool unauthorized;

  @override
  String toString() => message;
}

/// Код для входа на сайте AniLibria.
class AniLibriaOtp {
  const AniLibriaOtp({required this.code, required this.expiresAt});

  final String code;
  final DateTime expiresAt;
}

/// Релиз из коллекции пользователя.
class AniLibriaCollectionItem {
  const AniLibriaCollectionItem({
    required this.releaseId,
    required this.shikimoriId,
    required this.title,
    required this.episodesTotal,
    required this.collection,
  });

  final int releaseId;
  final int? shikimoriId;
  final String title;
  final int episodesTotal;

  /// PLANNED, WATCHED, WATCHING, POSTPONED или ABANDONED.
  final String collection;
}

/// Релиз из избранного.
class AniLibriaFavorite {
  const AniLibriaFavorite({
    required this.releaseId,
    required this.shikimoriId,
    required this.title,
    required this.episodesTotal,
  });

  final int releaseId;
  final int? shikimoriId;
  final String title;
  final int episodesTotal;
}

/// Запись истории просмотра одной серии.
class AniLibriaView {
  const AniLibriaView({
    required this.releaseId,
    required this.shikimoriId,
    required this.title,
    required this.episodesTotal,
    required this.ordinal,
    required this.watched,
    required this.updatedAt,
  });

  final int releaseId;
  final int? shikimoriId;
  final String title;
  final int episodesTotal;
  final num ordinal;
  final bool watched;
  final DateTime updatedAt;
}

/// Запросы к AniLibria.
class AniLibriaClient {
  AniLibriaClient({http.Client? httpClient})
    : _http = httpClient ?? http.Client();

  static const baseUrl = 'https://anilibria.top/api/v1';
  static const collectionTypes = [
    'WATCHING',
    'PLANNED',
    'WATCHED',
    'POSTPONED',
    'ABANDONED',
  ];

  static const _timeout = Duration(seconds: 15);
  static const _pageSize = 50;

  final http.Client _http;

  Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.parse('$baseUrl$path').replace(queryParameters: query);

  Map<String, String> _headers([String? token]) => {
    'User-Agent': 'Kiroku',
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      return await request().timeout(_timeout);
    } on AniLibriaException {
      rethrow;
    } on Object catch (error) {
      throw AniLibriaException('AniLibria не ответила: $error');
    }
  }

  dynamic _decode(http.Response response) {
    if (response.statusCode == 401) {
      throw const AniLibriaException('Нет доступа', unauthorized: true);
    }
    if (response.statusCode >= 400) {
      throw AniLibriaException('AniLibria ответила ${response.statusCode}');
    }
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw const AniLibriaException('AniLibria вернула непонятный ответ');
    }
  }

  /// Запрашивает код для входа.
  Future<AniLibriaOtp> requestCode(String deviceId) async {
    final response = await _send(
      () => _http.post(
        _uri('/accounts/otp/get'),
        headers: _headers(),
        body: jsonEncode({'device_id': deviceId}),
      ),
    );
    final otp = (_decode(response) as Map)['otp'] as Map;
    return AniLibriaOtp(
      code: '${otp['code']}',
      expiresAt:
          DateTime.tryParse('${otp['expired_at']}') ??
          DateTime.now().add(const Duration(minutes: 2)),
    );
  }

  /// Токен, если код уже подтверждён на сайте; иначе null.
  Future<String?> login(String code, String deviceId) async {
    final response = await _send(
      () => _http.post(
        _uri('/accounts/otp/login'),
        headers: _headers(),
        body: jsonEncode({
          'code': int.tryParse(code) ?? code,
          'device_id': deviceId,
        }),
      ),
    );
    if (response.statusCode >= 500) {
      throw AniLibriaException('AniLibria ответила ${response.statusCode}');
    }
    if (response.statusCode >= 400) return null;
    final token = (_decode(response) as Map)['token'];
    return token is String && token.isNotEmpty ? token : null;
  }

  /// Ник пользователя.
  Future<String> profileName(String token) async {
    final response = await _send(
      () => _http.get(
        _uri('/accounts/users/me/profile'),
        headers: _headers(token),
      ),
    );
    final profile = _decode(response) as Map;
    final nickname = '${profile['nickname'] ?? ''}'.trim();
    return nickname.isNotEmpty ? nickname : '${profile['login'] ?? ''}';
  }

  /// Все страницы списка; обрыв на любой из них — исключение.
  Future<List<Map<String, dynamic>>> _pages(
    String path,
    String token, [
    Map<String, String> extra = const {},
  ]) async {
    final result = <Map<String, dynamic>>[];
    var page = 1;
    while (true) {
      final response = await _send(
        () => _http.get(
          _uri(path, {...extra, 'page': '$page', 'limit': '$_pageSize'}),
          headers: _headers(token),
        ),
      );
      final body = _decode(response) as Map;
      for (final item in (body['data'] as List? ?? const [])) {
        result.add((item as Map).cast<String, dynamic>());
      }
      final pagination = ((body['meta'] as Map?)?['pagination'] as Map?) ?? {};
      final current = (pagination['current_page'] as num?)?.toInt() ?? page;
      final total = (pagination['total_pages'] as num?)?.toInt() ?? page;
      if (current >= total) return result;
      page = current + 1;
    }
  }

  int? _shikimori(Map release) =>
      ((release['shikimori'] as Map?)?['id'] as num?)?.toInt();

  String _title(Map release) {
    final name = release['name'];
    if (name is Map) return '${name['main'] ?? name['english'] ?? ''}';
    return '${name ?? ''}';
  }

  /// Коллекции: пять типов, все страницы.
  Future<List<AniLibriaCollectionItem>> collections(String token) async {
    final result = <AniLibriaCollectionItem>[];
    for (final type in collectionTypes) {
      final rows = await _pages(
        '/accounts/users/me/collections/releases',
        token,
        {'type_of_collection': type},
      );
      for (final release in rows) {
        result.add(
          AniLibriaCollectionItem(
            releaseId: (release['id'] as num).toInt(),
            shikimoriId: _shikimori(release),
            title: _title(release),
            episodesTotal: (release['episodes_total'] as num?)?.toInt() ?? 0,
            collection: type,
          ),
        );
      }
    }
    return result;
  }

  /// Избранное.
  Future<List<AniLibriaFavorite>> favorites(String token) async {
    final rows = await _pages('/accounts/users/me/favorites/releases', token);
    return [
      for (final release in rows)
        AniLibriaFavorite(
          releaseId: (release['id'] as num).toInt(),
          shikimoriId: _shikimori(release),
          title: _title(release),
          episodesTotal: (release['episodes_total'] as num?)?.toInt() ?? 0,
        ),
    ];
  }

  /// История просмотренных серий.
  Future<List<AniLibriaView>> history(String token) async {
    final rows = await _pages('/accounts/users/me/views/history', token);
    return [
      for (final row in rows)
        if (row['release_episode'] case final Map episode)
          if (episode['release'] case final Map release)
            AniLibriaView(
              releaseId: (release['id'] as num).toInt(),
              shikimoriId: _shikimori(release),
              title: _title(release),
              episodesTotal: (release['episodes_total'] as num?)?.toInt() ?? 0,
              ordinal: (episode['ordinal'] as num?) ?? 0,
              watched: row['is_watched'] == true,
              updatedAt:
                  DateTime.tryParse('${row['updated_at']}') ?? DateTime.now(),
            ),
    ];
  }
}
