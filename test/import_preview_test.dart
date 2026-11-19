import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kiroku/core/theme/app_theme.dart';
import 'package:kiroku/core/widgets/poster.dart';
import 'package:kiroku/data/database/app_database.dart';
import 'package:kiroku/data/database/watch_status.dart';
import 'package:kiroku/data/import/import_plan.dart';
import 'package:kiroku/data/providers.dart';
import 'package:kiroku/data/shikimori/anime_info.dart';
import 'package:kiroku/features/import/import_controller.dart';
import 'package:kiroku/features/import/import_preview.dart';

AnimeInfo _info(int id) => AnimeInfo(
  id: id,
  name: 'Anime $id',
  russian: 'Аниме $id',
  episodes: 12,
  episodesAired: 12,
  releaseStatus: 'released',
);

ImportItem _item(int id) => ImportItem(
  sourceTitle: 'Аниме $id',
  anime: _info(id),
  status: WatchStatus.watching,
  viewings: [
    ImportViewing(
      completed: false,
      episodes: [for (var n = 1; n <= 5; n++) ImportEpisode(n)],
    ),
  ],
);

Future<ProviderContainer> _show(
  WidgetTester tester,
  List<ImportItem> items, {
  Size size = const Size(900, 900),
}) async {
  final database = AppDatabase(NativeDatabase.memory());
  addTearDown(database.close);
  final container = ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(database),
      libraryStatusesProvider.overrideWith(
        (ref) => Stream.value({10: WatchStatus.completed}),
      ),
    ],
  );
  addTearDown(container.dispose);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.dark(),
        home: const Scaffold(
          body: SingleChildScrollView(child: ImportPreview()),
        ),
      ),
    ),
  );
  await container
      .read(importControllerProvider.notifier)
      .start(
        ImportPlan(sourceName: 'AniLibria', userName: 'Вася', items: items),
      );
  await tester.pump();
  return container;
}

Finder _plate(String name) => find.byKey(ValueKey('plate-$name'));

void main() {
  final items = [
    _item(1),
    _item(2),
    _item(3),
    _item(10),
    const ImportItem(sourceTitle: 'Неизвестный релиз'),
  ];

  testWidgets('плитки показывают числа групп', (tester) async {
    await _show(tester, items);
    expect(
      find.descendant(of: _plate('add'), matching: find.text('3')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: _plate('existing'), matching: find.text('1')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: _plate('notFound'), matching: find.text('1')),
      findsOneWidget,
    );
  });

  testWidgets('по умолчанию видны карточки «Добавятся»', (tester) async {
    await _show(tester, items);
    expect(find.text('Аниме 1'), findsOneWidget);
    expect(find.text('Аниме 10'), findsNothing);
    expect(find.text('Смотрю'), findsNWidgets(3));
    expect(find.text('5 из 12'), findsNWidgets(3));
  });

  testWidgets('нажатие на плитку «Уже есть» показывает эти карточки', (
    tester,
  ) async {
    await _show(tester, items);
    await tester.tap(_plate('existing'));
    await tester.pump();
    expect(find.text('Аниме 10'), findsOneWidget);
    expect(find.text('В Kiroku: Просмотрено'), findsOneWidget);
    expect(find.text('В AniLibria: Смотрю'), findsOneWidget);
    expect(find.text('Аниме 1'), findsNothing);
  });

  testWidgets('снятая галочка у карточки меняет число для переноса', (
    tester,
  ) async {
    final container = await _show(tester, items);
    expect(container.read(importControllerProvider)!.toTransfer, 3);
    await tester.tap(find.byType(ImportTick).first);
    await tester.pump();
    expect(container.read(importControllerProvider)!.toTransfer, 2);
    expect(
      find.descendant(of: _plate('add'), matching: find.text('2')),
      findsOneWidget,
    );
  });

  testWidgets('«Не найдены»: заглушка и название из источника', (tester) async {
    await _show(tester, items);
    await tester.tap(_plate('notFound'));
    await tester.pump();
    expect(find.text('Неизвестный релиз'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('600 тайтлов: строятся только видимые карточки', (tester) async {
    await _show(tester, [for (var i = 100; i < 700; i++) _item(i)]);
    expect(tester.takeException(), isNull);
    final built = find.byType(Poster).evaluate().length;
    expect(built, greaterThan(0));
    expect(built, lessThan(60));
  });

  testWidgets('в невысоком окне предпросмотр не вылезает за экран', (
    tester,
  ) async {
    await _show(tester, [
      for (var i = 100; i < 140; i++) _item(i),
    ], size: const Size(900, 650));
    expect(tester.takeException(), isNull);
    final grid = tester.getSize(find.byType(GridView));
    expect(grid.height, lessThanOrEqualTo(650 - 300));
    expect(grid.height, greaterThan(100));
  });

  testWidgets('несколько карточек: сетка не тянется на пустое место', (
    tester,
  ) async {
    await _show(tester, [_item(1), _item(2)]);
    expect(tester.getSize(find.byType(GridView)).height, lessThan(300));
  });

  testWidgets('без «Не найдены» такой плитки нет', (tester) async {
    await _show(tester, [_item(1), _item(2)]);
    expect(_plate('notFound'), findsNothing);
    expect(_plate('add'), findsOneWidget);
  });

  testWidgets('галочка замены есть, только если есть «Уже есть»', (
    tester,
  ) async {
    final container = await _show(tester, items);
    expect(
      find.text(
        'Заменить данными AniLibria 1 тайтл, который уже есть в Kiroku',
      ),
      findsOneWidget,
    );
    await tester.tap(find.textContaining('Заменить данными AniLibria'));
    await tester.pump();
    expect(container.read(importControllerProvider)!.replace, isTrue);
    expect(container.read(importControllerProvider)!.toTransfer, 4);
  });

  testWidgets('меню карточки меняет статус и сердечко', (tester) async {
    final container = await _show(tester, items);
    await tester.tap(find.text('Аниме 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Просмотрено'));
    await tester.pumpAndSettle();
    var state = container.read(importControllerProvider)!;
    expect(state.items[0].status, WatchStatus.completed);
    expect(state.items[0].episodesMarked, 12);

    await tester.tap(find.text('Аниме 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('В избранное'));
    await tester.pumpAndSettle();
    state = container.read(importControllerProvider)!;
    expect(state.items[0].favorite, isTrue);
  });
}
