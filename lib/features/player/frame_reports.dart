import '../autotrack/recognition.dart';

/// Видео внутри страницы или фрейма.
class FrameVideo {
  const FrameVideo({
    required this.time,
    required this.duration,
    required this.paused,
    required this.muted,
  });

  factory FrameVideo.fromMap(Map<Object?, Object?> map) => FrameVideo(
    time: (map['time'] as num?)?.toDouble() ?? 0,
    duration: (map['duration'] as num?)?.toDouble() ?? -1,
    paused: map['paused'] != false,
    muted: map['muted'] == true,
  );

  final double time;
  final double duration;
  final bool paused;
  final bool muted;
}

/// Сообщение скрипта из страницы или фрейма.
class FrameReport {
  const FrameReport({
    required this.url,
    required this.title,
    required this.top,
    required this.videos,
    required this.at,
  });

  static FrameReport? fromMessage(Object? message, DateTime at) {
    if (message is! Map || message['kiroku'] != 1) return null;
    return FrameReport(
      url: '${message['url'] ?? ''}',
      title: '${message['title'] ?? ''}',
      top: message['top'] == true,
      videos: [
        for (final video in (message['videos'] as List?) ?? const [])
          if (video is Map) FrameVideo.fromMap(video),
      ],
      at: at,
    );
  }

  final String url;
  final String title;
  final bool top;
  final List<FrameVideo> videos;
  final DateTime at;
}

const _playerHosts = ['alloha', 'kodik', 'iframeCVH'];

/// Сессия просмотра из сообщений страницы и фреймов.
MediaSession? embeddedSession(
  Iterable<FrameReport> reports, {
  required DateTime now,
}) {
  final fresh = [
    for (final report in reports)
      if (now.difference(report.at) < const Duration(seconds: 6)) report,
  ];
  final page = fresh.where((report) => report.top).firstOrNull;
  if (page == null) return null;

  ({FrameReport frame, FrameVideo video})? best;
  int score(FrameReport frame, FrameVideo video) =>
      (video.paused ? 0 : 4) +
      (_playerHosts.any(frame.url.contains) ? 2 : 0) +
      (video.muted ? 0 : 1);
  for (final frame in fresh) {
    if (frame.top) continue;
    for (final video in frame.videos) {
      if (video.duration < 5 * 60) continue;
      if (best == null || score(frame, video) > score(best.frame, best.video)) {
        best = (frame: frame, video: video);
      }
    }
  }
  if (best == null) return null;
  return MediaSession(
    app: 'kiroku',
    title: page.title,
    status: best.video.paused ? 5 : 4,
    position: best.video.time,
    duration: best.video.duration,
    documents: [
      (name: page.title, url: page.url),
      (name: best.frame.title, url: best.frame.url),
    ],
  );
}
