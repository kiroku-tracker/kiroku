import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiroku/app.dart';
import 'package:kiroku/app_section.dart';
import 'package:kiroku/data/database/app_database.dart';
import 'package:kiroku/data/providers.dart';
import 'package:kiroku/features/library/library_screen.dart';
import 'package:kiroku/features/search/search_screen.dart';
import 'package:kiroku/system/desktop.dart';

bool _animates(WidgetTester tester, Type screen) => TickerMode.valuesOf(
  tester.element(find.byType(screen, skipOffstage: false)),
).enabled;

void main() {
  testWidgets(
    'анимации идут только в открытом разделе и стоят, пока окно скрыто',
    (tester) async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(database)],
      );
      addTearDown(container.dispose);
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const KirokuApp(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(_animates(tester, LibraryScreen), isTrue);
      expect(_animates(tester, SearchScreen), isFalse);

      container.read(appSectionProvider.notifier).open(AppSection.search);
      await tester.pump();
      expect(_animates(tester, SearchScreen), isTrue);
      expect(_animates(tester, LibraryScreen), isFalse);

      container.read(windowShownProvider.notifier).set(false);
      await tester.pump();
      expect(_animates(tester, SearchScreen), isFalse);

      container.read(windowShownProvider.notifier).set(true);
      await tester.pump();
      expect(_animates(tester, SearchScreen), isTrue);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    },
  );
}
