import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kiroku/core/toast.dart';
import 'package:kiroku/data/shikimori/user_rate.dart';

import 'import_dialog_helpers.dart';

void main() {
  final rates = [
    UserRate(anime: infoFor(1), status: 'watching', episodes: 3),
    UserRate(anime: infoFor(2), status: 'planned'),
  ];

  testWidgets('Shikimori: ник, предпросмотр, перенос', (tester) async {
    final container = await openImport(
      tester,
      shikimori: FakeShikimori(user: vasya, rates: rates),
    );
    await findList(tester, 'vasya');
    expect(find.text('Список «Вася»: 2 тайтла'), findsOneWidget);
    expect(find.text('Перенести 2'), findsOneWidget);

    await tester.tap(find.text('Перенести 2'));
    await tester.pumpAndSettle();
    expect((await libraryEntries(container)).length, 2);
    expect(find.text('Импорт из Shikimori'), findsNothing);
    container.read(toastProvider.notifier).hide();
  });

  testWidgets('снятая галочка убирает тайтл из переноса', (tester) async {
    final container = await openImport(
      tester,
      shikimori: FakeShikimori(user: vasya, rates: rates),
    );
    await findList(tester, 'vasya');
    await tester.tap(find.byType(Checkbox).first);
    await tester.pump();
    expect(find.text('Перенести 1'), findsOneWidget);
    await tester.tap(find.text('Перенести 1'));
    await tester.pumpAndSettle();
    expect((await libraryEntries(container)).length, 1);
    container.read(toastProvider.notifier).hide();
  });

  testWidgets('окно достаточно широкое для карточек', (tester) async {
    await openImport(tester, shikimori: FakeShikimori(user: vasya));
    expect(tester.getSize(find.byType(TextField)).width, greaterThan(780));
  });

  testWidgets('«Отмена» до переноса ничего не пишет', (tester) async {
    final container = await openImport(
      tester,
      shikimori: FakeShikimori(user: vasya, rates: rates),
    );
    await findList(tester, 'vasya');
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();
    expect(await libraryEntries(container), isEmpty);
  });

  testWidgets('«Отменить» в подсказке возвращает базу', (tester) async {
    final container = await openImport(
      tester,
      shikimori: FakeShikimori(user: vasya, rates: rates),
    );
    await findList(tester, 'vasya');
    await tester.tap(find.text('Перенести 2'));
    await tester.pumpAndSettle();
    expect(container.read(toastProvider)?.undo, isNotNull);
    await tester.runAsync(() => container.read(toastProvider.notifier).undo());
    expect(await libraryEntries(container), isEmpty);
  });

  testWidgets('пользователь не найден', (tester) async {
    await openImport(tester, shikimori: FakeShikimori());
    await findList(tester, 'vasya');
    expect(find.text('Пользователь «vasya» не найден.'), findsOneWidget);
  });

  testWidgets('пустой или скрытый список', (tester) async {
    await openImport(tester, shikimori: FakeShikimori(user: vasya));
    await findList(tester, 'vasya');
    expect(find.textContaining('Список «Вася» пуст'), findsOneWidget);
  });
}
