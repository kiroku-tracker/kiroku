import 'dart:io';

import 'package:win32_registry/win32_registry.dart';

/// Автозапуск с Windows.
abstract final class Autostart {
  static const _runKey = r'Software\Microsoft\Windows\CurrentVersion\Run';
  static const _name = 'Kiroku';

  static const trayArgument = '--tray';

  static String get _command =>
      '"${Platform.resolvedExecutable}" $trayArgument';

  static bool isEnabled() {
    final key = CURRENT_USER.open(_runKey);
    try {
      return key.getString(_name) == _command;
    } finally {
      key.close();
    }
  }

  /// Обновляет путь автозапуска.
  static void repairPath() {
    final key = CURRENT_USER.create(_runKey);
    try {
      final value = key.getString(_name);
      if (value == null || value == _command) return;
      final path = RegExp(r'^"([^"]+)"').firstMatch(value)?.group(1);
      if (path != null && !File(path).existsSync()) {
        key.setValue(_name, RegistryValue.string(_command));
      }
    } finally {
      key.close();
    }
  }

  static void setEnabled(bool enabled) {
    final key = CURRENT_USER.create(_runKey);
    try {
      if (enabled) {
        key.setValue(_name, RegistryValue.string(_command));
      } else if (key.getString(_name) != null) {
        key.removeValue(_name);
      }
    } finally {
      key.close();
    }
  }
}
