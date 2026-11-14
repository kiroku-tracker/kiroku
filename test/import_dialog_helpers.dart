import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kiroku/core/theme/app_theme.dart';
import 'package:kiroku/data/anilibria/anilibria_client.dart';
import 'package:kiroku/data/database/app_database.dart';
import 'package:kiroku/data/providers.dart';
import 'package:kiroku/data/shikimori/anime_info.dart';
import 'package:kiroku/data/shikimori/shikimori_client.dart';
import 'package:kiroku/data/shikimori/user_rate.dart';
import 'package:kiroku/features/import/import_dialog.dart';
import 'package:kiroku/features/notifications/release_events.dart';
import 'package:kiroku/features/notifications/release_watcher.dart';

/// Shikimori с готовым списком пользователя и тайтлами по номерам.
class FakeShikimori extends ShikimoriClient {
  FakeShikimori({this.user, this.rates = const []});

  final ShikimoriUser? user;
  final List<UserRate> rates;

  @override
  Future<ShikimoriUser?> findUser(String input) async => user;

  @override
  Future<List<UserRate>> userRates(
    int userId, {
    void Function(int loaded)? onProgress,
  }) async {
    onProgress?.call(rates.length);
    return rates;
  }

  @override
  Future<List<AnimeInfo>> getAnimes(
    List<int> ids, {
    bool withRelations = false,
    bool withDetails = false,
  }) async => [for (final id in ids) infoFor(id)];
}

/// Проверка новых серий, которая ничего не делает.
class QuietWatcher extends ReleaseWatcher {
  QuietWatcher(super.ref);

  @override
  Future<List<ReleaseEvent>> check() async => const [];
}

AnimeInfo infoFor(int id) => AnimeInfo(
  id: id,
  name: 'Anime $id',
  russian: 'Аниме $id',
  episodes: 12,
  episodesAired: 12,
  releaseStatus: 'released',
);

const vasya = ShikimoriUser(id: 1, nickname: 'Вася');

/// Открывает окно импорта на базе в памяти.
Future<ProviderContainer> openImport(
  WidgetTester tester, {
  required ShikimoriClient shikimori,
  AniLibriaClient? aniLibria,
  ImportSource source = ImportSource.shikimori,
  Size size = const Size(1100, 1000),
}) async {
  final database = AppDatabase(NativeDatabase.memory());
  addTearDown(database.close);
  final container = ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(database),
      shikimoriClientProvider.overrideWithValue(shikimori),
      if (aniLibria != null)
        aniLibriaClientProvider.overrideWithValue(aniLibria),
      releaseWatcherProvider.overrideWith(QuietWatcher.new),
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
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showImportDialog(context, source),
              child: const Text('открыть'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('открыть'));
  if (source == ImportSource.shikimori) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
  }
  return container;
}

/// Вводит ник и ждёт предпросмотр или ошибку.
Future<void> findList(WidgetTester tester, String nick) async {
  await tester.enterText(find.byType(TextField), nick);
  await tester.tap(find.text('Найти список'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));
  await tester.pumpAndSettle();
}

Future<List<LibraryEntry>> libraryEntries(ProviderContainer container) =>
    container
        .read(databaseProvider)
        .select(container.read(databaseProvider).libraryEntries)
        .get();
