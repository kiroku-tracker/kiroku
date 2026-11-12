import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kiroku/core/toast.dart';
import 'package:kiroku/data/database/app_database.dart';
import 'package:kiroku/data/database/status_action.dart';
import 'package:kiroku/data/providers.dart';
import 'package:kiroku/data/shikimori/anime_info.dart';
import 'package:kiroku/features/autotrack/auto_marker.dart';
import 'package:kiroku/features/autotrack/recognition.dart';
import 'package:kiroku/system/notifications.dart';

/// Уведомления Windows для проверки.
class _Notifications extends NotificationService {
  final shown = <({String title, String body, bool silent})>[];

  @override
  Future<void> show({
    required String title,
    required String body,
    String? command,
    List<NotificationButton> buttons = const [],
    bool silent = false,
  }) async => shown.add((title: title, body: body, silent: silent));
}

const _anime = AnimeInfo(
  id: 38671,
  name: 'Enen no Shouboutai',
  russian: 'Пламенная бригада пожарных',
  episodes: 24,
  episodesAired: 24,
  releaseStatus: 'released',
);

const _page =
    'https://old.yummyani.me/catalog/item/plamennaya-brigada-pozharnyh';
const _title =
    'Пламенная бригада пожарных — смотреть аниме онлайн бесплатно на '
    'YummyAnime | Ями Аниме';

String _player(int episode) =>
    'https://ru.yummyani.me/iframeCVH.html?dubbing_code=AnilibriaTV&'
    'anime_id=38671&episode=$episode&dubbing=%D0%9E';

/// Серия досмотрена до 90%.
Map<String, Object> _watched(String app, int episode) => {
  'app': app,
  'title': _title,
  'status': 4,
  'position': 1296.0,
  'duration': 1440.0,
  'documents': [
    {'name': _title, 'url': _page},
    {'name': '', 'url': _player(episode)},
  ],
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('kiroku/media');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  late AppDatabase database;
  late _Notifications notifications;
  late ProviderContainer container;
  late AutoMarker marker;

  setUp(() async {
    messenger.setMockMethodCallHandler(channel, (_) async => null);
    database = AppDatabase(NativeDatabase.memory());
    notifications = _Notifications();
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(database),
        notificationServiceProvider.overrideWithValue(notifications),
      ],
    );
    container.listen(libraryItemsProvider, (_, _) {});
    await container
        .read(libraryRepositoryProvider)
        .add(_anime, StatusAction.watching);
    marker = container.read(autoMarkerProvider);
    await marker.start();
  });

  tearDown(() async {
    await marker.stop();
    container.dispose();
    messenger.setMockMethodCallHandler(channel, null);
    await database.close();
  });

  /// Сообщение от Windows о том, что сейчас играет.
  Future<void> snapshot(List<Map<String, Object>> sessions) async {
    await messenger.handlePlatformMessage(
      channel.name,
      const StandardMethodCodec().encodeMethodCall(
        MethodCall('update', sessions),
      ),
      (_) {},
    );
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }

  Future<List<int>> marked() async {
    final history = await container
        .read(libraryRepositoryProvider)
        .watchHistory(_anime.id)
        .first;
    return [for (final cycle in history) ...cycle.events.keys];
  }

  test('в плеере Kiroku уведомление не показывается', () async {
    marker.reportEmbedded(MediaSession.fromMap(_watched('kiroku', 3)));
    await snapshot([]);

    expect(await marked(), [3]);
    expect(notifications.shown, isEmpty);
    expect(container.read(toastProvider), isNull);
  });

  test('при просмотре в браузере уведомление без звука', () async {
    await snapshot([_watched('vivaldi.exe', 4)]);

    expect(await marked(), [4]);
    expect(notifications.shown, hasLength(1));
    expect(notifications.shown.single.title, 'Отмечена 4-я серия');
    expect(notifications.shown.single.silent, isTrue);
  });
}
