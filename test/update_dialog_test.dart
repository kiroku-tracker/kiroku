import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kiroku/core/theme/app_theme.dart';
import 'package:kiroku/features/updates/update_dialog.dart';
import 'package:kiroku/system/updates.dart';

AppRelease _release(String version, String body) => AppRelease(
  version: AppVersion.parse(version)!,
  notes: parseReleaseNotes(body),
  setupUrl: Uri.parse('https://github.com/x/y/releases/download/v1/s.exe'),
);

Future<void> _open(WidgetTester tester, AppRelease release) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: AppTheme.dark(),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showUpdateDialog(context, [release]),
            child: const Text('открыть'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('открыть'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('основные пункты видны сразу, без заголовков', (tester) async {
    await _open(
      tester,
      _release('1.0.0', '* Добавлен экспорт\n* Изменён поиск\n* Удалён вид\n'),
    );
    for (final text in ['Добавлен экспорт', 'Изменён поиск', 'Удалён вид']) {
      expect(find.text(text), findsOneWidget);
    }
    expect(find.text('Небольшие изменения'), findsNothing);
  });

  testWidgets('небольшие изменения свёрнуты и раскрываются по нажатию', (
    tester,
  ) async {
    await _open(
      tester,
      _release(
        '1.0.0',
        '### Добавлено\n* Экспорт\n### Небольшие изменения\n* Другой цвет\n',
      ),
    );
    expect(find.text('Небольшие изменения'), findsOneWidget);
    expect(find.text('Другой цвет'), findsNothing);

    await tester.tap(find.text('Небольшие изменения'));
    await tester.pumpAndSettle();
    expect(find.text('Другой цвет'), findsOneWidget);

    await tester.tap(find.text('Небольшие изменения'));
    await tester.pumpAndSettle();
    expect(find.text('Другой цвет'), findsNothing);
  });

  testWidgets('описание без блоков показывается как раньше', (tester) async {
    await _open(tester, _release('1.0.0', '* Первая\n* Вторая\n'));
    expect(find.text('Первая'), findsOneWidget);
    expect(find.text('Вторая'), findsOneWidget);
    expect(find.text('Небольшие изменения'), findsNothing);
  });
}
