import '../../data/yummy/yummy_client.dart';

/// Что выбрано на сайте: озвучка, плеер, серия.
typedef SiteChoice = ({String? dubbing, String? player, int? episode});

/// Озвучки, плееры и серии тайтла на сайте.
class SiteCatalog {
  SiteCatalog(List<YummyVideo> videos) {
    for (final video in videos) {
      if (video.siteDubbing.isEmpty || video.sitePlayer.isEmpty) continue;
      _episodes
          .putIfAbsent(video.siteDubbing, () => {})
          .putIfAbsent(video.sitePlayer, () => <int>{})
          .add(video.episode);
    }
  }

  final _episodes = <String, Map<String, Set<int>>>{};

  bool get isEmpty => _episodes.isEmpty;

  List<String> get dubbings => _episodes.keys.toList();

  /// Сколько разных серий в озвучке.
  int episodeCount(String dubbing) => {
    for (final episodes in (_episodes[dubbing] ?? const {}).values) ...episodes,
  }.length;

  List<String> players(String dubbing) =>
      (_episodes[dubbing] ?? const {}).keys.toList();

  List<int> episodes(String dubbing, String player) =>
      ((_episodes[dubbing] ?? const {})[player] ?? const <int>{}).toList()
        ..sort();

  /// Выбор после смены озвучки: плеер и серия остаются, если они есть.
  SiteChoice withDubbing(SiteChoice current, String dubbing) {
    final players = this.players(dubbing);
    final player = players.contains(current.player)
        ? current.player
        : players.firstOrNull;
    return (
      dubbing: dubbing,
      player: player,
      episode: _keep(current.episode, dubbing, player),
    );
  }

  /// Выбор после смены плеера: серия остаётся, если она есть.
  SiteChoice withPlayer(SiteChoice current, String player) {
    final dubbing = current.dubbing;
    return (
      dubbing: dubbing,
      player: player,
      episode: dubbing == null
          ? current.episode
          : _keep(current.episode, dubbing, player),
    );
  }

  int? _keep(int? episode, String dubbing, String? player) {
    if (player == null) return episode;
    final episodes = this.episodes(dubbing, player);
    if (episodes.isEmpty) return null;
    if (episode != null && episodes.contains(episode)) return episode;
    return episodes.first;
  }
}

/// «Озвучка AniDUB» → «AniDUB».
String shortDubbing(String label) =>
    label.startsWith('Озвучка ') ? label.substring(8) : label;

/// «Плеер Kodik» → «Kodik».
String shortPlayer(String label) =>
    label.startsWith('Плеер ') ? label.substring(6) : label;
