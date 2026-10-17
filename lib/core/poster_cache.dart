import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Постеры на диске: каждый скачивается один раз.
abstract final class PosterCache {
  /// Папка постеров.
  static Future<Directory> Function() directory = _defaultDirectory;

  /// Скачивание постера.
  static Future<Uint8List> Function(String url) fetch = _download;

  /// Сколько места могут занимать постеры.
  static const limit = 500 * 1024 * 1024;

  static final _loading = <String, Future<Uint8List>>{};
  static Future<Directory?>? _folder;

  /// Забывает папку, чтобы взять новую из [directory].
  static void reset() => _folder = null;

  static Future<Directory> _defaultDirectory() async {
    final support = await getApplicationSupportDirectory();
    return Directory('${support.path}${Platform.pathSeparator}posters');
  }

  static Future<Uint8List> _download(String url) async {
    final response = await http.get(
      Uri.parse(url),
      headers: {'User-Agent': 'Kiroku'},
    );
    if (response.statusCode != 200) {
      throw HttpException('Код ${response.statusCode}', uri: Uri.parse(url));
    }
    return response.bodyBytes;
  }

  /// Картинка постера: с диска, а если её там нет, из сети с сохранением.
  static Future<Uint8List> bytes(String url) =>
      _loading[url] ??= _load(url).whenComplete(() {
        _loading.remove(url);
      });

  static Future<Uint8List> _load(String url) async {
    final folder = await _ensureFolder();
    final file = folder == null ? null : File(_path(folder, url));
    if (file != null && await file.exists()) {
      unawaited(
        file.setLastModified(DateTime.now()).then((_) {}, onError: (_) {}),
      );
      return file.readAsBytes();
    }
    final data = await fetch(url);
    if (file != null) {
      try {
        final part = File('${file.path}.part');
        await part.writeAsBytes(data, flush: true);
        await part.rename(file.path);
      } on Object {
        // Не сохранился: в следующий раз скачается снова.
      }
    }
    return data;
  }

  static Future<Directory?> _ensureFolder() => _folder ??= () async {
    try {
      final folder = await directory();
      await folder.create(recursive: true);
      return folder;
    } on Object {
      return null;
    }
  }();

  /// Имя файла: хеш адреса и расширение картинки.
  static String _path(Directory folder, String url) {
    final name = sha1.convert(utf8.encode(url)).toString();
    final extension = RegExp(
      r'\.(webp|jpe?g|png)$',
      caseSensitive: false,
    ).firstMatch(Uri.parse(url).path)?.group(0);
    return '${folder.path}${Platform.pathSeparator}$name${extension ?? ''}';
  }

  /// Удаляет давно не показанные постеры, если папка больше [limit].
  static Future<void> trim({int limit = limit}) async {
    final folder = await _ensureFolder();
    if (folder == null) return;
    final files = <({File file, int size, DateTime used})>[];
    await for (final entity in folder.list()) {
      if (entity is! File) continue;
      final stat = await entity.stat();
      files.add((file: entity, size: stat.size, used: stat.modified));
    }
    var total = files.fold(0, (sum, file) => sum + file.size);
    if (total <= limit) return;
    files.sort((a, b) => a.used.compareTo(b.used));
    for (final file in files) {
      if (total <= limit * 0.8) break;
      try {
        await file.file.delete();
        total -= file.size;
      } on Object {
        // Файл занят: останется до следующего раза.
      }
    }
  }
}

/// Постер из [PosterCache].
@immutable
class PosterImage extends ImageProvider<PosterImage> {
  const PosterImage(this.url);

  final String url;

  @override
  Future<PosterImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(
    PosterImage key,
    ImageDecoderCallback decode,
  ) => MultiFrameImageStreamCompleter(
    codec: _codec(key.url, decode),
    scale: 1,
    debugLabel: key.url,
  );

  static Future<ui.Codec> _codec(
    String url,
    ImageDecoderCallback decode,
  ) async {
    final data = await PosterCache.bytes(url);
    return decode(await ui.ImmutableBuffer.fromUint8List(data));
  }

  @override
  bool operator ==(Object other) => other is PosterImage && other.url == url;

  @override
  int get hashCode => url.hashCode;
}
