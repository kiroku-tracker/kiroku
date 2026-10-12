import 'package:flutter_test/flutter_test.dart';
import 'package:kiroku/features/autotrack/recognition.dart';
import 'package:kiroku/features/player/frame_reports.dart';

const _page = 'https://ru.yummyani.me/catalog/item/velikij-iz-brodyachih-psov';
const _player =
    'https://alloha.yani.tv/?kp=975895&translation=10&season=1&episode=2';

FrameReport _report(
  String url, {
  bool top = false,
  List<Map<String, Object>> videos = const [],
  DateTime? at,
}) => FrameReport.fromMessage({
  'kiroku': 1,
  'url': url,
  'title': top ? 'Великий из бродячих псов смотреть аниме онлайн' : 'Player',
  'top': top,
  'videos': videos,
}, at ?? DateTime(2026, 10, 13, 12))!;

void main() {
  final now = DateTime(2026, 10, 13, 12, 0, 3);

  test('играющее видео плеера', () {
    final session = embeddedSession([
      _report(_page, top: true),
      _report(
        'https://rutube.ru/play/embed/1?dist=adfinitystick',
        videos: [
          {'time': 7, 'duration': 440, 'paused': false, 'muted': true},
        ],
      ),
      _report(
        _player,
        videos: [
          {'time': 341, 'duration': 1440, 'paused': false, 'muted': false},
          {'time': 0, 'duration': -1, 'paused': true, 'muted': false},
        ],
      ),
    ], now: now)!;
    expect(session.playing, isTrue);
    expect(session.position, 341);
    expect(session.duration, 1440);

    final recognized = recognizeYummy(session)!;
    expect(recognized.episode, 2);
    expect(recognized.slug, 'velikij-iz-brodyachih-psov');
    expect(recognized.title, 'Великий из бродячих псов');
  });

  test('устаревшие фреймы не учитываются', () {
    final session = embeddedSession([
      _report(_page, top: true, at: now),
      _report(
        _player,
        videos: [
          {'time': 100, 'duration': 1440, 'paused': false, 'muted': false},
        ],
        at: now.subtract(const Duration(seconds: 30)),
      ),
    ], now: now);
    expect(session, isNull);
  });

  test('пауза', () {
    final session = embeddedSession([
      _report(_page, top: true),
      _report(
        _player,
        videos: [
          {'time': 100, 'duration': 1440, 'paused': true, 'muted': false},
        ],
      ),
    ], now: now)!;
    expect(session.playing, isFalse);
  });
}
