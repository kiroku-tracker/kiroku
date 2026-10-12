import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiroku/app.dart';
import 'package:kiroku/core/widgets/status_menu.dart';
import 'package:kiroku/data/database/app_database.dart';
import 'package:kiroku/data/database/library_repository.dart';
import 'package:kiroku/data/database/status_action.dart';
import 'package:kiroku/data/providers.dart';
import 'package:kiroku/data/shikimori/anime_info.dart';

const _ongoing = AnimeInfo(
  id: 59978,
  name: 'Sousou no Frieren 2',
  russian: 'Фрирен 2',
  kind: 'tv',
  episodes: 10,
  episodesAired: 7,
  releaseStatus: 'ongoing',
);

void main() {
  testWidgets('всё вышедшее просмотрено', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = LibraryRepository(database);
    await repository.add(_ongoing, StatusAction.watching);
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: const KirokuApp(),
      ),
    );
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    final button = find.descendant(
      of: find.byType(StatusButton),
      matching: find.text('Смотрю'),
    );
    await tester.tap(button.first);
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    final item = find.descendant(
      of: find.byType(MenuItemButton),
      matching: find.text('Всё вышедшее просмотрено'),
    );
    await tester.tap(item);
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    final events = await database.select(database.watchEvents).get();
    expect(events.length, 7);
    expect(
      find.descendant(
        of: find.byType(StatusButton),
        matching: find.textContaining('Всё вышедшее'),
      ),
      findsOneWidget,
    );
    expect(
      find.textContaining('всё вышедшее просмотрено · отмечено 7'),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  });
}
