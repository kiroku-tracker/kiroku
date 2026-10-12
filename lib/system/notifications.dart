import 'dart:async';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

class NotificationButton {
  const NotificationButton({required this.command, required this.label});

  final String command;
  final String label;
}

class NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();
  final _taps = StreamController<String>.broadcast();
  String? _launchTap;
  bool _ready = false;
  int _nextId = 1;

  Stream<String> get taps => _taps.stream;

  /// Нажатие, которым запущена программа.
  String? takeLaunchTap() {
    final tap = _launchTap;
    _launchTap = null;
    return tap;
  }

  Future<void> init() async {
    final icon = p.join(
      p.dirname(Platform.resolvedExecutable),
      'data',
      'flutter_assets',
      'assets',
      'notification_icon.png',
    );
    await _plugin.initialize(
      settings: InitializationSettings(
        windows: WindowsInitializationSettings(
          appName: 'Kiroku',
          appUserModelId: 'Kiroku.Desktop',
          guid: 'd2d1b85d-4461-4556-a754-2629540d4760',
          iconPath: File(icon).existsSync() ? icon : null,
        ),
      ),
      onDidReceiveNotificationResponse: (response) {
        final command = response.payload;
        if (command != null && command.isNotEmpty) _taps.add(command);
      },
    );
    final launch = await _plugin.getNotificationAppLaunchDetails();
    final response = launch?.notificationResponse;
    if (launch?.didNotificationLaunchApp == true) {
      _launchTap = response?.payload;
    }
    _ready = true;
  }

  Future<void> show({
    required String title,
    required String body,
    String? command,
    List<NotificationButton> buttons = const [],
  }) async {
    if (!_ready) return;
    await _plugin.show(
      id: _nextId++,
      title: title,
      body: body,
      payload: command,
      notificationDetails: NotificationDetails(
        windows: WindowsNotificationDetails(
          actions: [
            for (final button in buttons)
              WindowsAction(content: button.label, arguments: button.command),
          ],
        ),
      ),
    );
  }
}

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(),
);
