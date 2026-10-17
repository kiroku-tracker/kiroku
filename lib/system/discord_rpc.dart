import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import '../data/database/library_repository.dart';

/// Подключение к Discord через локальный канал discord-ipc.
class DiscordRpc {
  DiscordRpc(this.clientId);

  final String clientId;

  int _handle = _invalid;

  static const _invalid = -1;

  bool get connected => _handle != _invalid;

  static final _kernel = DynamicLibrary.open('kernel32.dll');
  static final _createFile = _kernel
      .lookupFunction<
        IntPtr Function(
          Pointer<Utf16>,
          Uint32,
          Uint32,
          Pointer<Void>,
          Uint32,
          Uint32,
          IntPtr,
        ),
        int Function(Pointer<Utf16>, int, int, Pointer<Void>, int, int, int)
      >('CreateFileW');
  static final _writeFile = _kernel
      .lookupFunction<
        Int32 Function(IntPtr, Pointer<Uint8>, Uint32, Pointer<Uint32>, IntPtr),
        int Function(int, Pointer<Uint8>, int, Pointer<Uint32>, int)
      >('WriteFile');
  static final _readFile = _kernel
      .lookupFunction<
        Int32 Function(IntPtr, Pointer<Uint8>, Uint32, Pointer<Uint32>, IntPtr),
        int Function(int, Pointer<Uint8>, int, Pointer<Uint32>, int)
      >('ReadFile');
  static final _peekNamedPipe = _kernel
      .lookupFunction<
        Int32 Function(
          IntPtr,
          Pointer<Void>,
          Uint32,
          Pointer<Uint32>,
          Pointer<Uint32>,
          Pointer<Uint32>,
        ),
        int Function(
          int,
          Pointer<Void>,
          int,
          Pointer<Uint32>,
          Pointer<Uint32>,
          Pointer<Uint32>,
        )
      >('PeekNamedPipe');
  static final _closeHandle = _kernel
      .lookupFunction<Int32 Function(IntPtr), int Function(int)>('CloseHandle');

  /// Имя пользователя Discord из ответа на подключение.
  String? userName;

  /// Подключается к запущенному Discord. false — Discord не запущен.
  Future<bool> connect() async {
    if (connected) return true;
    if (!Platform.isWindows || clientId.isEmpty) return false;
    for (var i = 0; i < 10; i++) {
      final path = '\\\\.\\pipe\\discord-ipc-$i'.toNativeUtf16();
      final handle = _createFile(
        path,
        0x80000000 | 0x40000000,
        0,
        nullptr,
        3,
        0,
        0,
      );
      calloc.free(path);
      if (handle == _invalid || handle == 0) continue;
      _handle = handle;
      try {
        _send(0, {'v': 1, 'client_id': clientId});
        final ready = await _waitFor('READY');
        if (ready) return true;
      } on Object {
        // Канал закрылся.
      }
      close();
    }
    return false;
  }

  /// Показывает статус; null — убирает.
  Future<void> setActivity(Map<String, Object?>? activity) async {
    if (!connected) return;
    try {
      _read();
      _send(1, {
        'cmd': 'SET_ACTIVITY',
        'args': {'pid': pid, 'activity': activity},
        'nonce': newId(),
      });
    } on Object {
      close();
    }
  }

  void close() {
    if (!connected) return;
    _closeHandle(_handle);
    _handle = _invalid;
  }

  void _send(int op, Map<String, Object?> payload) {
    final body = utf8.encode(jsonEncode(payload));
    final frame = BytesBuilder()
      ..add(
        Uint8List(8)
          ..buffer.asByteData().setUint32(0, op, Endian.little)
          ..buffer.asByteData().setUint32(4, body.length, Endian.little),
      )
      ..add(body);
    final bytes = frame.toBytes();
    final buffer = calloc<Uint8>(bytes.length);
    final written = calloc<Uint32>();
    try {
      buffer.asTypedList(bytes.length).setAll(0, bytes);
      final ok = _writeFile(_handle, buffer, bytes.length, written, 0);
      if (ok == 0 || written.value != bytes.length) {
        throw const FileSystemException('Discord закрыл канал');
      }
    } finally {
      calloc.free(buffer);
      calloc.free(written);
    }
  }

  /// Читает пришедшие ответы, не дожидаясь новых.
  List<Map<String, Object?>> _read() {
    final available = calloc<Uint32>();
    try {
      if (_peekNamedPipe(_handle, nullptr, 0, nullptr, available, nullptr) ==
          0) {
        throw const FileSystemException('Discord закрыл канал');
      }
      final size = available.value;
      if (size == 0) return const [];
      final buffer = calloc<Uint8>(size);
      final read = calloc<Uint32>();
      try {
        if (_readFile(_handle, buffer, size, read, 0) == 0) {
          throw const FileSystemException('Discord закрыл канал');
        }
        return _frames(Uint8List.fromList(buffer.asTypedList(read.value)));
      } finally {
        calloc.free(buffer);
        calloc.free(read);
      }
    } finally {
      calloc.free(available);
    }
  }

  List<Map<String, Object?>> _frames(Uint8List bytes) {
    final result = <Map<String, Object?>>[];
    var offset = 0;
    final data = ByteData.sublistView(bytes);
    while (offset + 8 <= bytes.length) {
      final length = data.getUint32(offset + 4, Endian.little);
      if (offset + 8 + length > bytes.length) break;
      final json = jsonDecode(
        utf8.decode(bytes.sublist(offset + 8, offset + 8 + length)),
      );
      if (json is Map<String, Object?>) result.add(json);
      offset += 8 + length;
    }
    return result;
  }

  Future<bool> _waitFor(String event) async {
    for (var i = 0; i < 40; i++) {
      for (final frame in _read()) {
        if (frame['evt'] == event) {
          final data = frame['data'];
          final user = data is Map ? data['user'] : null;
          if (user is Map) {
            final name = user['global_name'] ?? user['username'];
            if (name is String && name.trim().isNotEmpty) {
              userName = name.trim();
            }
          }
          return true;
        }
        if (frame['evt'] == 'ERROR' || frame.containsKey('code')) return false;
      }
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    return false;
  }
}
