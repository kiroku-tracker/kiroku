import '../../core/labels.dart';
import '../../data/database/app_database.dart';
import '../../data/shikimori/anime_info.dart';
import '../../data/watch/site_episodes_repository.dart';

/// Изменение у тайтла для уведомления.
sealed class ReleaseEvent {
  const ReleaseEvent({required this.animeId, required this.title});

  final int animeId;
  final String title;
}

class NewEpisodes extends ReleaseEvent {
  const NewEpisodes({
    required super.animeId,
    required super.title,
    required this.from,
    required this.to,
    this.premiere = false,
    this.finished = false,
  });

  final int from;
  final int to;
  final bool premiere;
  final bool finished;
}

class SeasonFinished extends ReleaseEvent {
  const SeasonFinished({
    required super.animeId,
    required super.title,
    required this.episodes,
  });

  final int episodes;
}

/// Перенос даты следующей серии.
class EpisodeRescheduled extends ReleaseEvent {
  const EpisodeRescheduled({
    required super.animeId,
    required super.title,
    required this.episode,
    required this.at,
  });

  final int episode;
  final DateTime at;
}

/// Новые серии на YummyAnime.
class EpisodesOnSite extends ReleaseEvent {
  const EpisodesOnSite({
    required super.animeId,
    required super.title,
    required this.from,
    required this.to,
    this.dubbing,
  });

  final int from;
  final int to;
  final String? dubbing;
}

/// Новая часть франшизы.
class NewFranchisePart extends ReleaseEvent {
  const NewFranchisePart({
    required super.animeId,
    required super.title,
    required this.franchise,
    required this.releaseStatus,
    this.airedOn,
  });

  final String franchise;
  final String? releaseStatus;
  final String? airedOn;
}

/// Изменения тайтла после обновления.
List<ReleaseEvent> releaseEvents(Anime before, AnimeInfo after) {
  if (before.release.isReleased) return const [];
  final was = before.release.availableEpisodes;
  final now = after.release.availableEpisodes;
  final finished = after.release.isReleased;
  final title = after.title;

  if (now > was) {
    return [
      NewEpisodes(
        animeId: after.id,
        title: title,
        from: was + 1,
        to: now,
        premiere: was == 0,
        finished: finished,
      ),
    ];
  }
  if (finished) {
    return [SeasonFinished(animeId: after.id, title: title, episodes: now)];
  }
  final oldAt = before.nextEpisodeAt;
  final newAt = after.nextEpisodeAt;
  if (oldAt != null &&
      newAt != null &&
      newAt.difference(oldAt).abs() >= const Duration(days: 1)) {
    return [
      EpisodeRescheduled(
        animeId: after.id,
        title: title,
        episode: now + 1,
        at: newAt.toLocal(),
      ),
    ];
  }
  return const [];
}

({String title, String body}) notificationText(
  ReleaseEvent event,
) => switch (event) {
  NewEpisodes(:final from, :final to, :final premiere, :final finished) => (
    title: premiere
        ? 'Премьера: вышла $from-я серия'
        : from == to
        ? 'Вышла $from-я серия'
        : 'Вышли серии $from–$to',
    body: finished ? '«${event.title}» · сезон завершён' : '«${event.title}»',
  ),
  SeasonFinished(:final episodes) => (
    title: 'Сезон завершён',
    body: '«${event.title}»: вышли все ${episodesLabel(episodes)}',
  ),
  EpisodeRescheduled(:final episode, :final at) => (
    title: 'Серия $episode перенесена',
    body: '«${event.title}»: теперь ${formatDateTime(at)}',
  ),
  EpisodesOnSite(:final from, :final to, :final dubbing) => (
    title: from == to
        ? '$from-я серия на YummyAnime'
        : 'Серии $from–$to на YummyAnime',
    body: dubbing == null ? '«${event.title}»' : '«${event.title}» · $dubbing',
  ),
  NewFranchisePart(:final franchise, :final releaseStatus, :final airedOn) => (
    title: 'Новая часть: «${event.title}»',
    body: [
      'Франшиза «$franchise»',
      switch (releaseStatus) {
        'anons' => airedOn == null ? 'анонс' : 'анонс, $airedOn',
        'ongoing' => 'уже выходит',
        _ => null,
      },
    ].whereType<String>().join(' · '),
  ),
};

/// Общее уведомление о нескольких событиях.
({String title, String body}) summaryText(List<ReleaseEvent> events) {
  final titles = {for (final event in events) event.title}.toList();
  final shown = titles.take(3).map((title) => '«$title»').join(', ');
  final more = titles.length - 3;
  return (
    title:
        'Новое у ${titles.length} '
        '${plural(titles.length, 'тайтла', 'тайтлов', 'тайтлов')}',
    body: more > 0 ? '$shown и ещё $more' : shown,
  );
}

/// Серии на сайте.
({int episodes, String? dubbing}) siteProgress(
  SiteEpisodesInfo info, {
  String? dubbing,
}) {
  if (dubbing != null) {
    return (episodes: info.byDubbing[dubbing] ?? 0, dubbing: dubbing);
  }
  MapEntry<String, int>? best;
  for (final entry in info.sorted) {
    if (best == null || entry.value > best.value) best = entry;
  }
  return (episodes: best?.value ?? 0, dubbing: best?.key);
}

/// Новое на сайте.
List<ReleaseEvent> siteEvents({
  required int animeId,
  required String title,
  required SiteEpisodesInfo before,
  required SiteEpisodesInfo after,
  String? dubbing,
}) {
  if (!before.checked) return const [];
  final was = siteProgress(before, dubbing: dubbing).episodes;
  final now = siteProgress(after, dubbing: dubbing);
  if (now.episodes <= was) return const [];
  return [
    EpisodesOnSite(
      animeId: animeId,
      title: title,
      from: was + 1,
      to: now.episodes,
      dubbing: now.dubbing,
    ),
  ];
}
