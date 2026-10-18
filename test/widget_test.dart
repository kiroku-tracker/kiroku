import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:kiroku/app.dart';
import 'package:kiroku/core/toast.dart';
import 'package:kiroku/core/widgets/setting_rows.dart';
import 'package:kiroku/core/widgets/status_menu.dart';
import 'package:kiroku/features/library/library_toolbar.dart';
import 'package:kiroku/data/database/app_database.dart';
import 'package:kiroku/data/database/library_repository.dart';
import 'package:kiroku/data/database/status_action.dart';
import 'package:kiroku/data/providers.dart';
import 'package:kiroku/data/shikimori/anime_info.dart';
import 'package:kiroku/data/shikimori/rate_limiter.dart';
import 'package:kiroku/data/shikimori/shikimori_client.dart';

const _frieren = AnimeInfo(
  id: 52991,
  name: 'Sousou no Frieren',
  russian: 'Провожающая в последний путь Фрирен',
  kind: 'tv',
  episodes: 28,
  episodesAired: 28,
  releaseStatus: 'released',
);

ShikimoriClient _fakeShikimori() => ShikimoriClient(
  rateLimiter: RateLimiter(interval: Duration.zero),
  httpClient: MockClient(
    (_) async => http.Response.bytes(
      utf8.encode(
        jsonEncode({
          'data': {
            'animes': [
              {
                'id': '52991',
                'name': 'Sousou no Frieren',
                'russian': 'Провожающая в последний путь Фрирен',
                'kind': 'tv',
                'score': 9.1,
                'episodes': 28,
                'episodesAired': 28,
                'status': 'released',
                'description':
                    '[character=1]Фрирен[/character] — эльфийка-маг.',
                'genres': [
                  {'russian': 'Приключения'},
                ],
                'studios': [
                  {'name': 'Madhouse'},
                ],
                'duration': 24,
                'rating': 'pg_13',
              },
            ],
          },
        }),
      ),
      200,
    ),
  ),
);

void main() {
  late AppDatabase database;

  setUp(() => database = AppDatabase(NativeDatabase.memory()));
  tearDown(() => database.close());

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          shikimoriClientProvider.overrideWithValue(_fakeShikimori()),
        ],
        child: const KirokuApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  }

  testWidgets('пустая библиотека', (tester) async {
    await pumpApp(tester);
    expect(find.text('Библиотека пока пустая'), findsOneWidget);

    await tester.tap(find.text('Перейти к поиску'));
    await settle(tester);
    expect(
      find.widgetWithText(TextField, 'Найти').hitTestable(),
      findsOneWidget,
    );
    expect(find.textContaining('символ'), findsNothing);

    await unmount(tester);
  });

  testWidgets('открытие тайтла', (tester) async {
    await LibraryRepository(database).add(_frieren, StatusAction.completed);
    await pumpApp(tester);

    expect(find.text('В «Смотрю» пока пусто'), findsOneWidget);
    await tester.tap(_tab('Просмотрено'));
    await settle(tester);
    expect(find.text('28 из 28 эп.'), findsOneWidget);
    expect(_statusButton('Просмотрено'), findsOneWidget);

    await tester.tap(find.text('Провожающая в последний путь Фрирен'));
    await settle(tester);

    expect(find.text('Назад в библиотеку'), findsOneWidget);
    expect(find.text('Фрирен — эльфийка-маг.'), findsOneWidget);
    expect(find.text('Madhouse'), findsOneWidget);

    await tester.tap(find.text('Назад в библиотеку'));
    await settle(tester);
    expect(find.text('Библиотека'), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('смена статуса', (tester) async {
    await LibraryRepository(database).add(_frieren, StatusAction.completed);
    await pumpApp(tester);
    await tester.tap(_tab('Все'));
    await settle(tester);

    await tester.tap(_statusButton('Просмотрено'));
    await settle(tester);
    for (final label in [
      'Смотрю',
      'Хочу посмотреть',
      'Просмотрено',
      'Отложено',
      'Брошено',
      'Убрать из библиотеки',
    ]) {
      expect(_menuItem(label), findsOneWidget);
    }

    await tester.tap(_menuItem('Отложено'));
    await settle(tester);
    expect(find.textContaining('перенесено в «Отложено»'), findsOneWidget);
    expect(_statusButton('Отложено'), findsOneWidget);

    await tester.tap(find.text('Отменить'));
    await settle(tester);
    expect(_statusButton('Просмотрено'), findsOneWidget);
    expect(find.text('Отменить'), findsNothing);

    await unmount(tester);
  });

  testWidgets('отметка серий', (tester) async {
    await LibraryRepository(database).add(_frieren, StatusAction.watching);
    tester.view.physicalSize = const Size(1400, 2400);
    await pumpApp(tester);

    await tester.tap(find.text('Провожающая в последний путь Фрирен').first);
    await settle(tester);
    expect(find.text('Смотреть · серия 1'), findsOneWidget);
    await tester.tap(find.byTooltip('Редактировать отметки'));
    await settle(tester);
    final tile = find.descendant(
      of: find.byType(Wrap),
      matching: find.text('1'),
    );
    await tester.tap(tile.first);
    await settle(tester);
    expect(find.text('Серия 1 отмечена'), findsOneWidget);
    expect(find.text('1 / 28'), findsOneWidget);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.tap(
      find.descendant(of: find.byType(Wrap), matching: find.text('4')).first,
    );
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await settle(tester);
    expect(find.text('Отмечено: 3 серии'), findsOneWidget);
    expect(find.text('4 / 28'), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('продолжить просмотр и таблица', (tester) async {
    final repository = LibraryRepository(database);
    await repository.add(_frieren, StatusAction.watching);
    await repository.toggleEpisode(_frieren.id, 1);
    await pumpApp(tester);

    expect(find.text('Продолжить просмотр'), findsOneWidget);
    expect(find.text('Смотреть · серия 2'), findsNWidgets(2));
    await tester.tap(
      find.text('Смотреть · серия 2').first,
      buttons: kSecondaryMouseButton,
    );
    await settle(tester);
    await tester.tap(find.text('Отметить серию 2'));
    await settle(tester);
    expect(find.text('Серия 2 отмечена'), findsOneWidget);
    expect(find.text('Смотреть · серия 3'), findsNWidgets(2));

    await tester.tap(find.byTooltip('Таблица'));
    await settle(tester);
    expect(find.text('Моя оценка'), findsOneWidget);
    expect(find.text('2 / 28'), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('подсказка', (tester) async {
    late WidgetRef widgetRef;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ToastHost(
              child: Consumer(
                builder: (context, ref, _) {
                  widgetRef = ref;
                  return const SizedBox.expand();
                },
              ),
            ),
          ),
        ),
      ),
    );

    var undone = false;
    widgetRef
        .read(toastProvider.notifier)
        .show('Готово', undo: () async => undone = true);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Готово'), findsOneWidget);
    expect(find.byIcon(LucideIcons.undo2), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Готово'), findsNothing);
    expect(undone, isFalse);
  });

  testWidgets('права гостей в настройках включаются и выключаются', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.byTooltip('Настройки').first);
    await settle(tester);
    final toggle = find.descendant(
      of: find.ancestor(
        of: find.text('Выбирать серию и озвучку'),
        matching: find.byType(SettingRow),
      ),
      matching: find.byType(Switch),
    );
    await tester.ensureVisible(toggle);
    await settle(tester);
    expect(tester.widget<Switch>(toggle).value, isFalse);
    await tester.tap(toggle);
    await settle(tester);
    expect(tester.widget<Switch>(toggle).value, isTrue);
    await tester.tap(toggle);
    await settle(tester);
    expect(tester.widget<Switch>(toggle).value, isFalse);

    await unmount(tester);
  });
}

Finder _tab(String label) =>
    find.descendant(of: find.byType(StatusTabs), matching: find.text(label));

Finder _statusButton(String label) =>
    find.descendant(of: find.byType(StatusButton), matching: find.text(label));

Finder _menuItem(String label) => find.descendant(
  of: find.byType(MenuItemButton),
  matching: find.text(label),
);
