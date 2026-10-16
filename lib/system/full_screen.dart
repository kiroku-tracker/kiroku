import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

/// Окно на весь монитор без рамки и заголовка.
abstract final class FullScreen {
  static const _styleIndex = -16;
  static const _overlappedWindow = 0x00CF0000;
  static const _monitorNearest = 2;
  static const _noSize = 0x0001;
  static const _noMove = 0x0002;
  static const _noZOrder = 0x0004;
  static const _frameChanged = 0x0020;
  static const _noOwnerZOrder = 0x0200;

  static int? _style;
  static final _placement = calloc<Uint32>(11);

  static final _user = DynamicLibrary.open('user32.dll');
  static final _getWindowLong = _user
      .lookupFunction<IntPtr Function(IntPtr, Int32), int Function(int, int)>(
        'GetWindowLongPtrW',
      );
  static final _setWindowLong = _user
      .lookupFunction<
        IntPtr Function(IntPtr, Int32, IntPtr),
        int Function(int, int, int)
      >('SetWindowLongPtrW');
  static final _getPlacement = _user
      .lookupFunction<
        Int32 Function(IntPtr, Pointer<Uint32>),
        int Function(int, Pointer<Uint32>)
      >('GetWindowPlacement');
  static final _setPlacement = _user
      .lookupFunction<
        Int32 Function(IntPtr, Pointer<Uint32>),
        int Function(int, Pointer<Uint32>)
      >('SetWindowPlacement');
  static final _monitorFromWindow = _user
      .lookupFunction<IntPtr Function(IntPtr, Uint32), int Function(int, int)>(
        'MonitorFromWindow',
      );
  static final _getMonitorInfo = _user
      .lookupFunction<
        Int32 Function(IntPtr, Pointer<Int32>),
        int Function(int, Pointer<Int32>)
      >('GetMonitorInfoW');
  static final _setWindowPos = _user
      .lookupFunction<
        Int32 Function(IntPtr, IntPtr, Int32, Int32, Int32, Int32, Uint32),
        int Function(int, int, int, int, int, int, int)
      >('SetWindowPos');

  static bool get isOn => _style != null;

  /// Разворачивает окно на весь монитор или возвращает прежний вид.
  static void set(int window, bool on) {
    if (!Platform.isWindows || on == isOn) return;
    if (on) {
      final style = _getWindowLong(window, _styleIndex);
      _placement[0] = 44;
      _getPlacement(window, _placement);
      final monitor = calloc<Int32>(10);
      monitor[0] = 40;
      _getMonitorInfo(_monitorFromWindow(window, _monitorNearest), monitor);
      _setWindowLong(window, _styleIndex, style & ~_overlappedWindow);
      _setWindowPos(
        window,
        0,
        monitor[1],
        monitor[2],
        monitor[3] - monitor[1],
        monitor[4] - monitor[2],
        _noOwnerZOrder | _frameChanged,
      );
      calloc.free(monitor);
      _style = style;
    } else {
      _setWindowLong(window, _styleIndex, _style!);
      _style = null;
      _setPlacement(window, _placement);
      _setWindowPos(
        window,
        0,
        0,
        0,
        0,
        0,
        _noMove | _noSize | _noZOrder | _noOwnerZOrder | _frameChanged,
      );
    }
  }
}
