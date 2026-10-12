import '../database/settings_repository.dart';
import '../yummy/yummy_client.dart';

/// Адрес для просмотра.
class WatchTarget {
  const WatchTarget({required this.uri, required this.found});

  final Uri uri;

  final bool found;
}

/// Сайт для просмотра.
abstract class WatchSource {
  String get id;
  String get name;

  /// Адрес тайтла на сайте.
  Future<WatchTarget> resolve({
    required int shikimoriId,
    required String title,
  });
}

class YummyAnimeSource implements WatchSource {
  YummyAnimeSource({
    required this.client,
    required this.settings,
    required this.host,
  });

  final YummyClient client;
  final SettingsRepository settings;
  final YummyHost host;

  @override
  String get id => 'yummy';

  @override
  String get name => 'YummyAnime';

  Uri itemUri(String slug) => Uri.https(host.domain, '/catalog/item/$slug');

  /// Поиск по названию.
  Uri searchUri(String title) => switch (host) {
    YummyHost.ru => Uri.https(host.domain, '/catalog', {'q': title}),
    YummyHost.old => Uri.https(host.domain, '/search', {'word': title}),
  };

  @override
  Future<WatchTarget> resolve({
    required int shikimoriId,
    required String title,
  }) async {
    final key = 'yummy.id.$shikimoriId';
    var slug = (await settings.readAll())[key];
    if (slug == null) {
      try {
        slug = await client.slugByShikimoriId(shikimoriId) ?? '';
        if (slug.isNotEmpty) {
          await settings.write(key, slug);
          await settings.write('yummy.$slug', '$shikimoriId');
        }
      } catch (_) {
        slug = '';
      }
    }
    return slug.isEmpty
        ? WatchTarget(uri: searchUri(title), found: false)
        : WatchTarget(uri: itemUri(slug), found: true);
  }
}
