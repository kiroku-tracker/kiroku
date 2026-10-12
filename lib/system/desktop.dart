import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';

import '../app_section.dart';
import '../data/database/app_database.dart';
import '../data/database/library_repository.dart';
import '../data/database/settings_repository.dart';
import '../data/database/status_action.dart';
import '../data/database/watch_status.dart';
import '../data/providers.dart';
import '../features/autotrack/auto_marker.dart';
import '../features/notifications/release_watcher.dart';
import '../features/title/title_screen.dart';
import 'backups.dart';
import 'notifications.dart';
import 'updates.dart';

/// Показывает главное окно.
Future<void> showMainWindow() async {
  if (await windowManager.isMinimized()) await windowManager.restore();
  await windowManager.show();
  await windowManager.focus();
}

/// Трей, окно и уведомления.
class DesktopController with TrayListener, WindowListener {
  DesktopController(this._ref);

  final Ref _ref;
  StreamSubscription<String>? _taps;
  ProviderSubscription<AsyncValue<AppPrefs>>? _prefs;
  ProviderSubscription<AsyncValue<List<LibraryItem>>>? _library;
  ProviderSubscription<NowPlaying?>? _playing;

  String? _menuSignature;
  bool _quitting = false;

  Timer? _backupTimer;

  Future<void> start() async {
    await trayManager.setIcon('assets/tray_icon.ico');
    await trayManager.setToolTip('Kiroku');
    await _updateMenu();
    _library = _ref.listen(libraryItemsProvider, (_, _) => _updateMenu());
    _playing = _ref.listen(nowPlayingProvider, (_, _) => _updateMenu());
    trayManager.addListener(this);
    windowManager.addListener(this);
    await windowManager.setPreventClose(true);

    final notifications = _ref.read(notificationServiceProvider);
    _taps = notifications.taps.listen(_onCommand);
    final launch = notifications.takeLaunchTap();
    if (launch != null) unawaited(_onCommand(launch));

    _ref.read(releaseWatcherProvider).start();
    _ref.read(updatesProvider.notifier).start();
    unawaited(_backupIfDue());
    _backupTimer = Timer.periodic(
      const Duration(hours: 1),
      (_) => _backupIfDue(),
    );
    final marker = _ref.read(autoMarkerProvider);
    await marker.apply(await _ref.read(appPrefsProvider.future));
    _prefs = _ref.listen(appPrefsProvider, (_, next) {
      final prefs = next.value;
      if (prefs != null) marker.apply(prefs);
    });
  }

  void dispose() {
    _taps?.cancel();
    _backupTimer?.cancel();
    _prefs?.close();
    _library?.close();
    _playing?.close();
    trayManager.removeListener(this);
    windowManager.removeListener(this);
  }

  Future<void> _backupIfDue() async {
    try {
      final backups = await _ref.read(backupsProvider.future);
      await backups.autoIfDue(_ref.read(databaseProvider));
    } on Object {
      // Ошибка пропускается.
    }
  }

  /// Выход из программы.
  Future<void> quit() async {
    _quitting = true;
    await trayManager.destroy();
    await windowManager.setPreventClose(false);
    await windowManager.destroy();
  }

  /// Меню в трее.
  Future<void> _updateMenu() async {
    final now = _ref.read(nowPlayingProvider);
    final items = _ref.read(libraryItemsProvider).value ?? const [];
    final next = [
      for (final item in items)
        if (item.status == WatchStatus.watching &&
            item.anime.release.availableEpisodes > 0 &&
            item.progress.nextEpisode <= item.anime.release.availableEpisodes)
          item,
    ]..sort((a, b) => b.entry.updatedAt.compareTo(a.entry.updatedAt));

    final playing = now?.animeId != null && now?.episode != null
        ? MenuItem(
            key: 'playing',
            label: 'Отметить «${_short(now!.title)}», серия ${now.episode}',
          )
        : null;
    final nextItems = [
      for (final item in next.take(10))
        MenuItem(
          key: 'mark:${item.anime.id}:${item.progress.nextEpisode}',
          label:
              '${_short(item.anime.title)}, серия ${item.progress.nextEpisode}',
        ),
    ];
    final signature = [
      playing?.label,
      for (final item in nextItems) '${item.key}${item.label}',
    ].join('|');
    if (signature == _menuSignature) return;
    _menuSignature = signature;

    await trayManager.setContextMenu(
      Menu(
        items: [
          ?playing,
          if (nextItems.isNotEmpty)
            MenuItem.submenu(
              label: 'Отметить следующую серию',
              submenu: Menu(items: nextItems),
            ),
          if (playing != null || nextItems.isNotEmpty) MenuItem.separator(),
          MenuItem(key: 'open', label: 'Открыть Kiroku'),
          MenuItem(key: 'check', label: 'Проверить новые серии'),
          MenuItem.separator(),
          MenuItem(key: 'quit', label: 'Выход'),
        ],
      ),
    );
  }

  /// Короткое название для меню.
  static String _short(String title) =>
      title.length <= 40 ? title : '${title.substring(0, 39)}…';

  @override
  void onTrayIconMouseDown() => showMainWindow();

  @override
  void onTrayIconRightMouseDown() => trayManager.popUpContextMenu();

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    final key = menuItem.key ?? '';
    switch (key) {
      case 'open':
        showMainWindow();
      case 'check':
        _checkNow();
      case 'quit':
        quit();
      case 'playing':
        _ref.read(autoMarkerProvider).markNowPlaying();
      case _ when key.startsWith('mark:'):
        _ref.read(autoMarkerProvider).handleCommand(key);
    }
  }

  @override
  Future<void> onWindowClose() async {
    if (_quitting) return;
    final prefs = await _ref.read(appPrefsProvider.future);
    if (!prefs.closeToTray) {
      await quit();
      return;
    }
    await windowManager.hide();
    if (!prefs.trayHintShown) {
      await _ref
          .read(appPrefsProvider.notifier)
          .change((prefs) => prefs.copyWith(trayHintShown: true));
      await _ref
          .read(notificationServiceProvider)
          .show(
            title: 'Kiroku работает в трее',
            body: 'Проверка серий продолжается. Выход: правый клик по значку.',
          );
    }
  }

  Future<void> _checkNow() async {
    final events = await _ref.read(releaseWatcherProvider).check();
    if (events.isEmpty) {
      await _ref
          .read(notificationServiceProvider)
          .show(title: 'Новых серий нет', body: 'Всё актуально.');
    }
  }

  /// Обрабатывает нажатие на уведомление.
  Future<void> _onCommand(String command) async {
    if (await _ref.read(autoMarkerProvider).handleCommand(command)) {
      if (command.startsWith('track:')) await showMainWindow();
      return;
    }
    if (command == NotificationCommand.openLibrary) {
      await showMainWindow();
      _openSection(AppSection.library);
      return;
    }
    final titleId = NotificationCommand.animeIdOf(command, 'title');
    if (titleId != null) {
      await showMainWindow();
      _openSection(AppSection.library);
      sectionNavigatorKeys[AppSection.library]?.currentState?.push(
        titleRoute(animeId: titleId, backLabel: 'Назад в библиотеку'),
      );
      return;
    }
    final watchId = NotificationCommand.animeIdOf(command, 'watch');
    if (watchId != null) {
      await _watch(watchId);
      return;
    }
    final planId = NotificationCommand.animeIdOf(command, 'plan');
    if (planId != null) {
      final anime = (await _ref.read(libraryRepositoryProvider).animesByIds([
        planId,
      ]))[planId];
      if (anime == null) return;
      await _ref
          .read(libraryRepositoryProvider)
          .add(anime.toInfo(), StatusAction.planned);
      await _ref
          .read(notificationServiceProvider)
          .show(
            title: 'Добавлено в «Хочу посмотреть»',
            body: '«${anime.title}»',
            command: NotificationCommand.openTitle(planId),
          );
    }
  }

  /// Открывает тайтл для просмотра.
  Future<void> _watch(int animeId) async {
    final anime = (await _ref.read(libraryRepositoryProvider).animesByIds([
      animeId,
    ]))[animeId];
    if (anime == null) return;
    final links = await _ref
        .read(watchLinksRepositoryProvider)
        .watchLinks(animeId)
        .first;
    final uri = links.isNotEmpty
        ? Uri.parse(links.first.url)
        : (await _ref
                  .read(watchSourceProvider)
                  .resolve(shikimoriId: animeId, title: anime.title))
              .uri;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /// Открывает раздел с начала.
  void _openSection(AppSection section) {
    _ref.read(appSectionProvider.notifier).open(section);
    sectionNavigatorKeys[section]?.currentState?.popUntil(
      (route) => route.isFirst,
    );
  }
}

final desktopControllerProvider = Provider<DesktopController>((ref) {
  final controller = DesktopController(ref);
  ref.onDispose(controller.dispose);
  return controller;
});
