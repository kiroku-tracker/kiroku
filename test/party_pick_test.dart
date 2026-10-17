import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kiroku/core/widgets/popup_panel.dart';
import 'package:kiroku/data/database/app_database.dart';
import 'package:kiroku/data/database/library_repository.dart';
import 'package:kiroku/data/database/status_action.dart';
import 'package:kiroku/data/providers.dart';
import 'package:kiroku/data/shikimori/anime_info.dart';
import 'package:kiroku/features/party/party_pick_panel.dart';

void main() {
  testWidgets('поиск тайтла для комнаты', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    const info = AnimeInfo(
      id: 7,
      name: 'Show',
      russian: 'Тайтл',
      kind: 'tv',
      episodes: 12,
      episodesAired: 12,
      releaseStatus: 'released',
    );
    await tester.runAsync(
      () => LibraryRepository(database).add(info, StatusAction.watching),
    );
    Anime? picked;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showPopupPanel(
                  context,
                  builder: (_) =>
                      PartyPickPanel(onPick: (anime) => picked = anime),
                ),
                child: const Text('Выбрать'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Выбрать'));
    for (var i = 0; i < 6; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump();
    }

    expect(find.text('Смотрю'), findsOneWidget);
    expect(find.text('Серия 1'), findsOneWidget);
    await tester.tap(find.text('Тайтл'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(picked?.id, 7);
    expect(find.byType(PartyPickPanel), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  });
}
