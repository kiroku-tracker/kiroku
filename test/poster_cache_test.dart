import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:kiroku/core/poster_cache.dart';

void main() {
  late Directory folder;

  setUp(() {
    folder = Directory.systemTemp.createTempSync('kiroku_posters_');
    PosterCache.directory = () async => folder;
    PosterCache.reset();
  });
  tearDown(() => folder.deleteSync(recursive: true));

  test('постер скачивается один раз, потом берётся с диска', () async {
    var downloads = 0;
    PosterCache.fetch = (url) async {
      downloads++;
      return Uint8List.fromList([1, 2, 3]);
    };
    const url = 'https://shikimori.io/uploads/poster/animes/1/main_2x-a.webp';

    expect(await PosterCache.bytes(url), [1, 2, 3]);
    expect(await PosterCache.bytes(url), [1, 2, 3]);
    expect(downloads, 1);
    expect(folder.listSync().whereType<File>().single.path, endsWith('.webp'));
  });

  test('лишние постеры удаляются, начиная с давно не показанных', () async {
    final old = File('${folder.path}/old.webp')
      ..writeAsBytesSync(List.filled(600, 0));
    old.setLastModifiedSync(DateTime(2020));
    final fresh = File('${folder.path}/fresh.webp')
      ..writeAsBytesSync(List.filled(600, 0));

    await PosterCache.trim(limit: 1000);

    expect(old.existsSync(), isFalse);
    expect(fresh.existsSync(), isTrue);
  });
}
