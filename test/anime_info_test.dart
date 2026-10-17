import 'package:flutter_test/flutter_test.dart';

import 'package:kiroku/data/shikimori/anime_info.dart';

void main() {
  test('постер берётся крупный, а для страницы тайтла оригинал', () {
    final info = AnimeInfo.fromGraphql({
      'id': '1',
      'name': 'Show',
      'russian': 'Тайтл',
      'poster': {
        'mainUrl': 'https://shikimori.io/uploads/poster/animes/1/main-a.webp',
        'main2xUrl':
            'https://shikimori.io/uploads/poster/animes/1/main_2x-b.webp',
        'originalUrl': 'https://shikimori.io/uploads/poster/animes/1/c.jpeg',
      },
    });
    expect(info.posterUrl, endsWith('main_2x-b.webp'));
    expect(info.posterOriginalUrl, endsWith('c.jpeg'));

    final old = AnimeInfo.fromGraphql({
      'id': '2',
      'name': 'Old',
      'russian': '',
      'poster': {'mainUrl': 'https://shikimori.io/main-d.webp'},
    });
    expect(old.posterUrl, endsWith('main-d.webp'));
    expect(old.posterOriginalUrl, isNull);
  });
}
