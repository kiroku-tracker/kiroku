import 'dart:ffi';
import 'dart:io';

abstract final class Restart {
  static const _argument = '--restart=';

  /// Запускает новую копию программы.
  static Future<void> launchNew() async {
    await Process.start(Platform.resolvedExecutable, [
      '$_argument$pid',
    ], mode: ProcessStartMode.detached);
  }

  /// Ждёт закрытия прежней копии.
  static void waitForPrevious(List<String> args) {
    final previous = args
        .where((arg) => arg.startsWith(_argument))
        .map((arg) => int.tryParse(arg.substring(_argument.length)))
        .firstOrNull;
    if (previous == null || !Platform.isWindows) return;
    final kernel = DynamicLibrary.open('kernel32.dll');
    final openProcess = kernel
        .lookupFunction<
          IntPtr Function(Uint32, Int32, Uint32),
          int Function(int, int, int)
        >('OpenProcess');
    final waitForSingleObject = kernel
        .lookupFunction<
          Uint32 Function(IntPtr, Uint32),
          int Function(int, int)
        >('WaitForSingleObject');
    final closeHandle = kernel
        .lookupFunction<Int32 Function(IntPtr), int Function(int)>(
          'CloseHandle',
        );
    const synchronize = 0x00100000;
    final handle = openProcess(synchronize, 0, previous);
    if (handle == 0) return;
    waitForSingleObject(handle, 15000);
    closeHandle(handle);
  }
}
