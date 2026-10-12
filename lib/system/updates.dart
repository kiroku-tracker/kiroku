import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;

import '../data/providers.dart';

class AppVersion implements Comparable<AppVersion> {
  const AppVersion(this.major, this.minor, this.patch);

  final int major;
  final int minor;
  final int patch;

  /// Номер версии из строки.
  static AppVersion? parse(String text) {
    final match = RegExp(r'^v?(\d+)\.(\d+)\.(\d+)').firstMatch(text.trim());
    if (match == null) return null;
    return AppVersion(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    );
  }

  @override
  int compareTo(AppVersion other) => major != other.major
      ? major.compareTo(other.major)
      : minor != other.minor
      ? minor.compareTo(other.minor)
      : patch.compareTo(other.patch);

  bool operator >(AppVersion other) => compareTo(other) > 0;

  @override
  bool operator ==(Object other) =>
      other is AppVersion && compareTo(other) == 0;

  @override
  int get hashCode => Object.hash(major, minor, patch);

  @override
  String toString() => '$major.$minor.$patch';
}

/// Строка описания версии.
typedef ReleaseNote = ({String text, bool bullet});

/// Версия на GitHub.
class AppRelease {
  const AppRelease({
    required this.version,
    required this.notes,
    required this.setupUrl,
    this.sha256,
  });

  final AppVersion version;
  final List<ReleaseNote> notes;
  final Uri setupUrl;

  final String? sha256;
}

class UpdateException implements Exception {
  const UpdateException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Список изменений из текста релиза.
List<ReleaseNote> parseReleaseNotes(String body) => [
  for (final raw in const LineSplitter().convert(body))
    if (raw.trim() case final line
        when line.isNotEmpty && !line.startsWith('#'))
      if (RegExp(r'^[*\-•]\s+').firstMatch(line) case final marker?)
        (text: line.substring(marker.end).trim(), bullet: true)
      else
        (text: line, bullet: false),
];

/// Версии из ответа GitHub.
List<AppRelease> parseReleases(List<dynamic> json, String repository) {
  final prefix = 'https://github.com/$repository/releases/download/'
      .toLowerCase();
  final result = <AppRelease>[];
  for (final item in json) {
    if (item is! Map) continue;
    if (item['draft'] == true || item['prerelease'] == true) continue;
    final version = AppVersion.parse('${item['tag_name']}');
    if (version == null) continue;
    final assets = (item['assets'] as List?) ?? const [];
    final setup = assets.whereType<Map>().where((asset) {
      final name = '${asset['name']}'.toLowerCase();
      final url = '${asset['browser_download_url']}';
      return name.endsWith('.exe') &&
          name.contains('setup') &&
          url.toLowerCase().startsWith(prefix);
    }).firstOrNull;
    if (setup == null) continue;
    final digest = '${setup['digest'] ?? ''}';
    result.add(
      AppRelease(
        version: version,
        notes: parseReleaseNotes('${item['body'] ?? ''}'),
        setupUrl: Uri.parse('${setup['browser_download_url']}'),
        sha256: digest.startsWith('sha256:') ? digest.substring(7) : null,
      ),
    );
  }
  return result..sort((a, b) => b.version.compareTo(a.version));
}

/// Версии на GitHub и загрузка установщика.
class UpdateClient {
  UpdateClient({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  static const repository = 'kiroku-tracker/kiroku';
  static final _releasesUrl = Uri.parse(
    'https://api.github.com/repos/$repository/releases?per_page=30',
  );
  static const _headers = {
    'User-Agent': 'Kiroku',
    'Accept': 'application/vnd.github+json',
  };

  final http.Client _http;

  Future<List<AppRelease>> releases() async {
    final response = await _http
        .get(_releasesUrl, headers: _headers)
        .timeout(const Duration(seconds: 15));
    if (response.statusCode == 404) return const [];
    if (response.statusCode != 200) {
      throw UpdateException('GitHub ответил ошибкой ${response.statusCode}');
    }
    final json = jsonDecode(utf8.decode(response.bodyBytes));
    return json is List ? parseReleases(json, repository) : const [];
  }

  Future<File> download(
    AppRelease release, {
    void Function(double progress)? onProgress,
  }) async {
    final request = http.Request('GET', release.setupUrl)
      ..headers['User-Agent'] = 'Kiroku';
    final response = await _http
        .send(request)
        .timeout(const Duration(seconds: 30));
    if (response.statusCode != 200) {
      throw UpdateException('GitHub ответил ошибкой ${response.statusCode}');
    }
    final folder = Directory(p.join(Directory.systemTemp.path, 'Kiroku'));
    await folder.create(recursive: true);
    final file = File(
      p.join(folder.path, 'Kiroku-Setup-${release.version}.exe'),
    );
    final sink = file.openWrite();
    final total = response.contentLength ?? 0;
    var received = 0;
    try {
      await for (final chunk in response.stream.timeout(
        const Duration(seconds: 30),
      )) {
        sink.add(chunk);
        received += chunk.length;
        if (total > 0) onProgress?.call(received / total);
      }
    } finally {
      await sink.close();
    }
    if (release.sha256 case final expected?) {
      final actual = await sha256.bind(file.openRead()).first;
      if ('$actual' != expected.toLowerCase()) {
        await file.delete();
        throw const UpdateException('Файл скачался с ошибкой');
      }
    }
    return file;
  }
}

final appVersionProvider = FutureProvider<AppVersion?>((ref) async {
  try {
    return AppVersion.parse((await PackageInfo.fromPlatform()).version);
  } on Object {
    return null;
  }
});

final updateClientProvider = Provider<UpdateClient>((ref) => UpdateClient());

class UpdatesNotifier extends Notifier<List<AppRelease>> {
  static const interval = Duration(hours: 6);

  Timer? _timer;

  @override
  List<AppRelease> build() {
    ref.onDispose(() => _timer?.cancel());
    return const [];
  }

  /// Запускает проверку обновлений.
  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => checkIfEnabled());
    unawaited(checkIfEnabled());
  }

  Future<void> checkIfEnabled() async {
    final prefs = await ref.read(appPrefsProvider.future);
    if (!prefs.checkUpdates) {
      state = const [];
      return;
    }
    try {
      await check();
    } on Object {
      // Ошибка пропускается.
    }
  }

  Future<List<AppRelease>> check() async {
    final current = await ref.read(appVersionProvider.future);
    if (current == null) return const [];
    final releases = await ref.read(updateClientProvider).releases();
    final newer = [
      for (final release in releases)
        if (release.version > current) release,
    ];
    final prefs = await ref.read(appPrefsProvider.future);
    state = prefs.checkUpdates ? newer : const [];
    return newer;
  }

  /// Скачивает и запускает установщик.
  Future<void> install(
    AppRelease release, {
    void Function(double progress)? onProgress,
  }) async {
    final file = await ref
        .read(updateClientProvider)
        .download(release, onProgress: onProgress);
    await Process.start(file.path, const [
      '/SILENT',
      '/SUPPRESSMSGBOXES',
      '/NORESTART',
    ], mode: ProcessStartMode.detached);
  }
}

final updatesProvider = NotifierProvider<UpdatesNotifier, List<AppRelease>>(
  UpdatesNotifier.new,
);
