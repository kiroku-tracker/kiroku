import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../data/database/franchise_rules.dart';
import '../../data/providers.dart';
import '../../data/watch/dubbing_rules.dart';
import 'release_events.dart';

/// Строка о сериях на YummyAnime.
String? siteLine(
  WidgetRef ref,
  Anime anime,
  LibraryEntry? entry, {
  bool short = false,
}) {
  final info = ref.watch(siteEpisodesProvider(anime.id)).value;
  if (info == null || !info.checked) return null;
  final franchises = ref.watch(franchisesProvider).value ?? const {};
  final dubbing = entry == null
      ? null
      : effectiveDubbing(entry, franchises[franchiseKeyOf(entry, anime)]);
  final progress = siteProgress(info, dubbing: dubbing?.name);
  final site = short ? 'YummyAnime' : 'На YummyAnime';
  if (progress.episodes == 0) {
    return dubbing == null
        ? '$site: серий пока нет'
        : '$site: в озвучке ${dubbing.name} серий пока нет';
  }
  return [
    short
        ? '$site: до ${progress.episodes}-й'
        : '$site: до ${progress.episodes}-й серии',
    ?progress.dubbing,
  ].join(' · ');
}
