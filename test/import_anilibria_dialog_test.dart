import 'package:flutter_test/flutter_test.dart';

import 'package:kiroku/core/toast.dart';
import 'package:kiroku/data/anilibria/anilibria_client.dart';
import 'package:kiroku/data/providers.dart';
import 'package:kiroku/features/import/import_dialog.dart';

import 'import_dialog_helpers.dart';

class _FakeAniLibria extends AniLibriaClient {
  _FakeAniLibria({
    this.pendingLogins = 0,
    this.codeLife = const Duration(minutes: 2),
    this.collectionsError,
    this.historyError,
    this.collectionItems = const [],
    this.favoriteItems = const [],
    this.views = const [],
  });

  final int pendingLogins;
  final Duration codeLife;
  final AniLibriaException? collectionsError;
  final AniLibriaException? historyError;
  final List<AniLibriaCollectionItem> collectionItems;
  final List<AniLibriaFavorite> favoriteItems;
  final List<AniLibriaView> views;

  var codes = 0;
  var logins = 0;

  @override
  Future<AniLibriaOtp> requestCode(String deviceId) async {
    codes++;
    return AniLibriaOtp(
      code: '05870$codes',
      expiresAt: DateTime.now().add(codeLife),
    );
  }

  @override
  Future<String?> login(String code, String deviceId) async {
    logins++;
    return logins > pendingLogins ? 'token' : null;
  }

  @override
  Future<String> profileName(String token) async => 'Вася';

  @override
  Future<List<AniLibriaCollectionItem>> collections(String token) async {
    if (collectionsError != null) throw collectionsError!;
    return collectionItems;
  }

  @override
  Future<List<AniLibriaFavorite>> favorites(String token) async =>
      favoriteItems;

  @override
  Future<List<AniLibriaView>> history(String token) async {
    if (historyError != null) throw historyError!;
    return views;
  }
}

AniLibriaCollectionItem _col(int release, int shiki, String type) =>
    AniLibriaCollectionItem(
      releaseId: release,
      shikimoriId: shiki,
      title: 'Релиз $release',
      episodesTotal: 12,
      collection: type,
    );

Future<void> _tick(WidgetTester tester, [int seconds = 3]) async {
  await tester.pump(Duration(seconds: seconds));
  await tester.pump(const Duration(milliseconds: 200));
}

Future<void> _open(
  WidgetTester tester,
  _FakeAniLibria api, {
  void Function(dynamic container)? onOpen,
}) async {
  final container = await openImport(
    tester,
    shikimori: FakeShikimori(),
    aniLibria: api,
    source: ImportSource.aniLibria,
  );
  onOpen?.call(container);
}

void main() {
  final collections = [_col(1, 1, 'WATCHING'), _col(2, 2, 'PLANNED')];
  const favorites = [
    AniLibriaFavorite(
      releaseId: 1,
      shikimoriId: 1,
      title: 'Релиз 1',
      episodesTotal: 12,
    ),
  ];
  final views = [
    AniLibriaView(
      releaseId: 1,
      shikimoriId: 1,
      title: 'Релиз 1',
      episodesTotal: 12,
      ordinal: 1,
      watched: true,
      updatedAt: DateTime.utc(2025, 2, 3),
    ),
  ];

  testWidgets('код, подтверждение, предпросмотр, перенос', (tester) async {
    final api = _FakeAniLibria(
      pendingLogins: 2,
      collectionItems: collections,
      favoriteItems: favorites,
      views: views,
    );
    final container = await openImport(
      tester,
      shikimori: FakeShikimori(),
      aniLibria: api,
      source: ImportSource.aniLibria,
    );
    expect(find.text('058701'), findsOneWidget);

    for (var i = 0; i < 3; i++) {
      await _tick(tester);
    }
    await tester.pumpAndSettle();
    expect(api.logins, 3);
    expect(find.text('Список «Вася»: 2 тайтла'), findsOneWidget);

    await tester.tap(find.text('Перенести 2'));
    await tester.pumpAndSettle();
    final entries = await libraryEntries(container);
    expect(entries.length, 2);
    expect(entries.firstWhere((e) => e.animeId == 1).favorite, isTrue);
    final database = container.read(databaseProvider);
    final events = await database.select(database.watchEvents).get();
    expect(events.single.watchedAt?.toUtc(), DateTime.utc(2025, 2, 3));
    container.read(toastProvider.notifier).hide();
  });

  testWidgets('код истёк: можно получить новый', (tester) async {
    final api = _FakeAniLibria(
      pendingLogins: 100,
      codeLife: const Duration(seconds: 7),
    );
    await _open(tester, api);
    for (var i = 0; i < 3; i++) {
      await _tick(tester);
    }
    expect(find.text('Код истёк'), findsOneWidget);
    await tester.tap(find.text('Новый код'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(api.codes, 2);
    expect(find.text('058702'), findsOneWidget);
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();
  });

  testWidgets('отказ в доступе не трогает базу', (tester) async {
    final api = _FakeAniLibria(
      collectionsError: const AniLibriaException(
        'Нет доступа',
        unauthorized: true,
      ),
    );
    final container = await openImport(
      tester,
      shikimori: FakeShikimori(),
      aniLibria: api,
      source: ImportSource.aniLibria,
    );
    await _tick(tester);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('AniLibria не приняла вход'), findsOneWidget);
    expect(find.text('Новый код'), findsOneWidget);
    expect(await libraryEntries(container), isEmpty);
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();
  });

  testWidgets('обрыв сети при загрузке ничего не пишет', (tester) async {
    final api = _FakeAniLibria(
      collectionItems: collections,
      historyError: const AniLibriaException('AniLibria не ответила: offline'),
    );
    final container = await openImport(
      tester,
      shikimori: FakeShikimori(),
      aniLibria: api,
      source: ImportSource.aniLibria,
    );
    await _tick(tester);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('AniLibria не ответила'), findsOneWidget);
    expect(await libraryEntries(container), isEmpty);
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();
  });

  testWidgets('закрытие окна останавливает опрос', (tester) async {
    final api = _FakeAniLibria(pendingLogins: 100);
    await _open(tester, api);
    await _tick(tester);
    final before = api.logins;
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 12));
    expect(api.logins, before);
  });

  testWidgets('пустой аккаунт', (tester) async {
    await _open(tester, _FakeAniLibria());
    await _tick(tester);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('нет ни коллекций'), findsOneWidget);
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();
  });
}
