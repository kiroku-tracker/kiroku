import 'package:flutter_test/flutter_test.dart';

import 'package:kiroku/features/autotrack/recognition.dart';

const _title =
    'Пламенная бригада пожарных — смотреть аниме онлайн бесплатно на '
    'YummyAnime | Ями Аниме';
const _page =
    'https://old.yummyani.me/catalog/item/plamennaya-brigada-pozharnyh';
const _cvh =
    'https://ru.yummyani.me/iframeCVH.html?dubbing_code=AnilibriaTV&'
    'anime_id=38671&episode=10&dubbing=%D0%9E&start_from=1407';
const _kodik =
    'https://kodikplayer.com/season/48273/bea15b4a182353314d7c486247855213/'
    '720p?translations=false&only_episode=true&only_season=true&episode=10&'
    'skip_button=%5Bopening%5D149-238';

MediaSession _session({
  String title = _title,
  List<String> urls = const [],
  double position = 600,
}) => MediaSession(
  app: 'vivaldi.exe',
  title: title,
  status: 4,
  position: position,
  duration: 1440,
  documents: [for (final url in urls) (name: '', url: url)],
);

void main() {
  test('плеер CVH', () {
    final result = recognizeYummy(_session(urls: [_page, _cvh]))!;
    expect(result.title, 'Пламенная бригада пожарных');
    expect(result.shikimoriId, 38671);
    expect(result.episode, 10);
    expect(result.slug, 'plamennaya-brigada-pozharnyh');
  });

  test('плеер Kodik', () {
    final result = recognizeYummy(_session(urls: [_page, _kodik]))!;
    expect(result.shikimoriId, isNull);
    expect(result.slug, 'plamennaya-brigada-pozharnyh');
    expect(result.episode, 10);
  });

  test('неактивная вкладка', () {
    final result = recognizeYummy(_session())!;
    expect(result.title, 'Пламенная бригада пожарных');
    expect(result.episode, isNull);
    expect(result.slug, isNull);
  });

  test('другой сайт', () {
    expect(recognizeYummy(_session(title: 'Какое-то видео - YouTube')), isNull);
  });

  test('доля просмотренного', () {
    expect(_session(position: 1224).ratio, closeTo(0.85, 0.001));
    expect(
      const MediaSession(
        app: '',
        title: '',
        status: 5,
        position: 10,
        duration: 0,
      ).ratio,
      0,
    );
  });

  test('другое видео под старым названием', () {
    final youtube = MediaSession(
      app: 'vivaldi.exe',
      title: _title,
      status: 4,
      position: 500,
      duration: 615,
    );
    expect(sameVideo(youtube, 1440), isFalse);
    expect(sameVideo(youtube, null), isFalse);
    expect(sameVideo(_session(), 1440), isTrue);
    expect(sameVideo(_session(urls: [_page]), null), isTrue);
  });
}
