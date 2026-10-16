import 'package:flutter_test/flutter_test.dart';
import 'package:kiroku/data/yummy/yummy_client.dart';
import 'package:kiroku/features/player/site_catalog.dart';

YummyVideo _video(int episode, String dubbing, String player) => YummyVideo(
  episode: episode,
  dubbing: dubbing,
  player: null,
  siteDubbing: 'Озвучка $dubbing',
  sitePlayer: 'Плеер $player',
);

void main() {
  final catalog = SiteCatalog([
    for (var e = 1; e <= 12; e++) _video(e, 'AniLibria', 'Alloha'),
    for (var e = 1; e <= 12; e++) _video(e, 'AniLibria', 'Kodik'),
    for (var e = 1; e <= 8; e++) _video(e, 'AniDUB', 'Kodik'),
  ]);

  test('озвучки, плееры и серии', () {
    expect(catalog.dubbings, ['Озвучка AniLibria', 'Озвучка AniDUB']);
    expect(catalog.players('Озвучка AniLibria'), [
      'Плеер Alloha',
      'Плеер Kodik',
    ]);
    expect(catalog.episodeCount('Озвучка AniDUB'), 8);
    expect(catalog.episodes('Озвучка AniDUB', 'Плеер Kodik').last, 8);
  });

  test('смена озвучки', () {
    final next = catalog.withDubbing((
      dubbing: 'Озвучка AniLibria',
      player: 'Плеер Alloha',
      episode: 10,
    ), 'Озвучка AniDUB');
    expect(next.player, 'Плеер Kodik');
    expect(next.episode, 1);

    final same = catalog.withDubbing((
      dubbing: 'Озвучка AniLibria',
      player: 'Плеер Kodik',
      episode: 5,
    ), 'Озвучка AniDUB');
    expect(same.player, 'Плеер Kodik');
    expect(same.episode, 5);
  });

  test('короткие подписи', () {
    expect(shortDubbing('Озвучка AniDUB'), 'AniDUB');
    expect(shortDubbing('Субтитры SubVost'), 'Субтитры SubVost');
    expect(shortPlayer('Плеер Kodik'), 'Kodik');
  });
}
