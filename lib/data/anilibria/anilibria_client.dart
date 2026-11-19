import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

/// Ошибка запроса к AniLibria.
class AniLibriaException implements Exception {
  const AniLibriaException(this.message, {this.unauthorized = false});

  final String message;
  final bool unauthorized;

  @override
  String toString() => message;
}

/// Сколько страниц списков загружено из уже известного числа.
class AniLibriaProgress {
  AniLibriaProgress([this.onChange]);

  final void Function(int done, int total)? onChange;
  var _loaded = 0;
  var _total = 0;

  void _add(int pages) {
    _total += pages;
    onChange?.call(_loaded, _total);
  }

  void _done() {
    _loaded++;
    onChange?.call(_loaded, _total);
  }
}

/// Ограничение числа одновременных запросов.
class _Gate {
  _Gate(this._free);

  int _free;
  final _waiting = <Completer<void>>[];

  Future<T> run<T>(Future<T> Function() task) async {
    if (_free > 0) {
      _free--;
    } else {
      final turn = Completer<void>();
      _waiting.add(turn);
      await turn.future;
    }
    try {
      return await task();
    } finally {
      if (_waiting.isNotEmpty) {
        _waiting.removeAt(0).complete();
      } else {
        _free++;
      }
    }
  }
}

/// Код для входа на сайте AniLibria.
class AniLibriaOtp {
  const AniLibriaOtp({required this.code, required this.lifetime});

  final String code;

  /// Сколько секунд код ещё действует.
  final Duration lifetime;
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
  static const _maxPages = 400;

  final http.Client _http;

  /// Не больше четырёх запросов списков одновременно: AniLibria отвечает
  /// по 2–3 секунды на страницу, по одной загрузка шла минуту.
  final _gate = _Gate(_waveSize);
  static const _waveSize = 4;

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
    final body = _decode(response) as Map;
    final seconds = _int(body['remaining_time']);
    return AniLibriaOtp(
      code: '${(body['otp'] as Map)['code']}',
      lifetime: Duration(seconds: seconds ?? 120),
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
    // Пока код не введён на сайте, AniLibria отвечает 500, а не 401,
    // как написано в её документации.
    if (response.statusCode >= 400 && response.statusCode <= 500) return null;
    if (response.statusCode > 500) {
      throw AniLibriaException('AniLibria ответила ${response.statusCode}');
    }
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

  /// Одна страница списка и сколько всего страниц.
  Future<({List<Map<String, dynamic>> rows, int total})> _page(
    String path,
    String token,
    Map<String, String> extra,
    int page,
  ) async {
    final response = await _gate.run(
      () => _send(
        () => _http.get(
          _uri(path, {...extra, 'page': '$page', 'limit': '$_pageSize'}),
          headers: _headers(token),
        ),
      ),
    );
    final body = _decode(response) as Map;
    final rows = [
      for (final item in body['data'] as List? ?? const [])
        (item as Map).cast<String, dynamic>(),
    ];
    final pagination = ((body['meta'] as Map?)?['pagination'] as Map?) ?? {};
    return (rows: rows, total: _int(pagination['total_pages']) ?? page);
  }

  /// Все страницы списка; обрыв на любой из них — исключение. Первая
  /// страница сообщает, сколько их всего, остальные грузятся параллельно.
  Future<List<Map<String, dynamic>>> _pages(
    String path,
    String token, {
    Map<String, String> extra = const {},
    AniLibriaProgress? progress,
  }) async {
    progress?._add(1);
    final first = await _page(path, token, extra, 1);
    progress?._done();
    final total = first.total.clamp(1, _maxPages);
    if (first.rows.isEmpty || total == 1) return first.rows;
    progress?._add(total - 1);
    final result = [...first.rows];
    // Волнами по четыре: пустая страница значит, что число страниц
    // в ответе неверное, и дальше грузить нечего.
    for (var start = 2; start <= total; start += _waveSize) {
      final wave = await Future.wait([
        for (
          var page = start;
          page <= min(start + _waveSize - 1, total);
          page++
        )
          _page(path, token, extra, page).then((loaded) {
            progress?._done();
            return loaded.rows;
          }),
      ]);
      for (final rows in wave) {
        result.addAll(rows);
      }
      if (wave.any((rows) => rows.isEmpty)) break;
    }
    return result;
  }

  /// Целое число из числа или строки.
  static int? _int(Object? value) =>
      value is num ? value.toInt() : int.tryParse('$value');

  int? _shikimori(Map release) => _int((release['shikimori'] as Map?)?['id']);

  String _title(Map release) {
    final name = release['name'];
    if (name is Map) return '${name['main'] ?? name['english'] ?? ''}';
    return '${name ?? ''}';
  }

  /// Коллекции: пять типов, все страницы.
  Future<List<AniLibriaCollectionItem>> collections(
    String token, {
    AniLibriaProgress? progress,
  }) async {
    final lists = await Future.wait([
      for (final type in collectionTypes)
        _pages(
          '/accounts/users/me/collections/releases',
          token,
          extra: {'type_of_collection': type},
          progress: progress,
        ),
    ]);
    final result = <AniLibriaCollectionItem>[];
    for (final (index, rows) in lists.indexed) {
      final type = collectionTypes[index];
      for (final release in rows) {
        result.add(
          AniLibriaCollectionItem(
            releaseId: _int(release['id']) ?? 0,
            shikimoriId: _shikimori(release),
            title: _title(release),
            episodesTotal: _int(release['episodes_total']) ?? 0,
            collection: type,
          ),
        );
      }
    }
    return result;
  }

  /// Избранное.
  Future<List<AniLibriaFavorite>> favorites(
    String token, {
    AniLibriaProgress? progress,
  }) async {
    final rows = await _pages(
      '/accounts/users/me/favorites/releases',
      token,
      progress: progress,
    );
    return [
      for (final release in rows)
        AniLibriaFavorite(
          releaseId: _int(release['id']) ?? 0,
          shikimoriId: _shikimori(release),
          title: _title(release),
          episodesTotal: _int(release['episodes_total']) ?? 0,
        ),
    ];
  }

  /// История просмотренных серий.
  Future<List<AniLibriaView>> history(
    String token, {
    AniLibriaProgress? progress,
  }) async {
    final rows = await _pages(
      '/accounts/users/me/views/history',
      token,
      progress: progress,
    );
    return [
      for (final row in rows)
        if (row['release_episode'] case final Map episode)
          if (episode['release'] case final Map release)
            AniLibriaView(
              releaseId: _int(release['id']) ?? 0,
              shikimoriId: _shikimori(release),
              title: _title(release),
              episodesTotal: _int(release['episodes_total']) ?? 0,
              ordinal: (episode['ordinal'] as num?) ?? 0,
              watched: row['is_watched'] == true,
              updatedAt:
                  DateTime.tryParse('${row['updated_at']}') ?? DateTime.now(),
            ),
    ];
  }
}
