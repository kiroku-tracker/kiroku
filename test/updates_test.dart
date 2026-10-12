import 'package:flutter_test/flutter_test.dart';
import 'package:kiroku/system/updates.dart';

Map<String, Object?> _release(
  String tag, {
  String body = '',
  bool draft = false,
  bool prerelease = false,
  bool setup = true,
}) => {
  'tag_name': tag,
  'body': body,
  'draft': draft,
  'prerelease': prerelease,
  'assets': [
    if (setup)
      {
        'name': 'Kiroku-Setup-${tag.substring(1)}.exe',
        'browser_download_url':
            'https://github.com/kiroku-tracker/kiroku/releases/download/$tag/'
            'Kiroku-Setup-${tag.substring(1)}.exe',
        'digest': 'sha256:abc123',
      },
  ],
};

void main() {
  test('сравнение версий', () {
    final older = AppVersion.parse('0.9.12')!;
    final newer = AppVersion.parse('v0.10.0+3')!;
    expect(newer > older, isTrue);
    expect(older > newer, isFalse);
    expect(AppVersion.parse('1.2.3'), const AppVersion(1, 2, 3));
    expect(AppVersion.parse('версия'), isNull);
  });

  test('описание версии', () {
    final notes = parseReleaseNotes(
      '## 1.2.0\r\n'
      '* Добавлен экспорт\r\n'
      '- Изменён поиск\r\n'
      '\r\n'
      'Спасибо за отзывы\r\n',
    );
    expect(notes, [
      (text: 'Добавлен экспорт', bullet: true),
      (text: 'Изменён поиск', bullet: true),
      (text: 'Спасибо за отзывы', bullet: false),
    ]);
  });

  test('список версий', () {
    final releases = parseReleases([
      _release('v1.0.0', body: '* Первая'),
      _release('v1.2.0', body: '* Третья'),
      _release('v1.1.0', body: '* Вторая'),
      _release('v1.3.0', draft: true),
      _release('v1.4.0', prerelease: true),
      _release('v1.5.0', setup: false),
      _release('черновик'),
    ], 'kiroku-tracker/kiroku');
    expect(
      [for (final release in releases) '${release.version}'],
      ['1.2.0', '1.1.0', '1.0.0'],
    );
    expect(releases.first.notes.single.text, 'Третья');
    expect(releases.first.sha256, 'abc123');
  });

  test('регистр имени репозитория', () {
    final release = _release('v2.0.0');
    ((release['assets'] as List).single as Map)['browser_download_url'] =
        'https://github.com/kiroku-tracker/Kiroku/releases/download/v2.0.0/'
        'Kiroku-Setup-2.0.0.exe';
    expect(parseReleases([release], 'kiroku-tracker/kiroku'), hasLength(1));
  });

  test('чужой адрес установщика', () {
    final foreign = _release('v2.0.0');
    ((foreign['assets'] as List).single as Map)['browser_download_url'] =
        'https://example.com/Kiroku-Setup-2.0.0.exe';
    expect(parseReleases([foreign], 'kiroku-tracker/kiroku'), isEmpty);
  });
}
