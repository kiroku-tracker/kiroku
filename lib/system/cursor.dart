import 'dart:ffi';
import 'dart:io';

/// Курсор Windows над окном Kiroku.
abstract final class SystemCursor {
  static const _setCursorMessage = 0x0020;
  static const _client = 1;
  static const _mouseMove = 0x0200;

  static final _user = DynamicLibrary.open('user32.dll');
  static final _setCursor = _user
      .lookupFunction<IntPtr Function(IntPtr), int Function(int)>('SetCursor');
  static final _sendMessage = _user
      .lookupFunction<
        IntPtr Function(IntPtr, Uint32, IntPtr, IntPtr),
        int Function(int, int, int, int)
      >('SendMessageW');

  /// Прячет курсор до следующего движения мыши.
  static void hide() {
    if (Platform.isWindows) _setCursor(0);
  }

  /// Возвращает курсор окна, не дожидаясь движения мыши.
  static void restore(int window) {
    if (!Platform.isWindows) return;
    _sendMessage(window, _setCursorMessage, window, _client | _mouseMove << 16);
  }
}
