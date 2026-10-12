import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:windows_single_instance/windows_single_instance.dart';

import 'app.dart';
import 'system/autostart.dart';
import 'system/backups.dart';
import 'system/desktop.dart';
import 'system/notifications.dart';
import 'system/restart.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  Restart.waitForPrevious(args);
  await WindowsSingleInstance.ensureSingleInstance(
    args,
    'kiroku-desktop',
    bringWindowToFront: false,
    onSecondWindow: (_) => showMainWindow(),
  );
  await windowManager.ensureInitialized();

  try {
    Backups.restoredAtStart = await (await Backups.standard()).applyPending();
  } on Object {
    Backups.restoredAtStart = false;
  }
  try {
    Autostart.repairPath();
  } on Object {
    // Ошибка пропускается.
  }

  final startHidden = args.contains(Autostart.trayArgument);
  await windowManager.waitUntilReadyToShow(
    const WindowOptions(
      title: 'Kiroku',
      size: Size(1280, 820),
      minimumSize: Size(960, 640),
      center: true,
    ),
    () async {
      if (startHidden) return;
      await windowManager.show();
      await windowManager.focus();
    },
  );

  final notifications = NotificationService();
  await notifications.init();

  runApp(
    ProviderScope(
      overrides: [notificationServiceProvider.overrideWithValue(notifications)],
      child: const KirokuApp(desktop: true),
    ),
  );
}
