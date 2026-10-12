import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/labels.dart';
import '../../core/widgets/poster_card.dart';
import '../../core/widgets/release_badge.dart';
import '../../data/database/watch_status.dart';
import '../../data/providers.dart';
import '../../data/shikimori/anime_info.dart';
import '../library/add_to_library_button.dart';
import '../library/entry_status_button.dart';
import '../title/title_screen.dart';

/// Карточка результата поиска.
class SearchResultCard extends ConsumerWidget {
  const SearchResultCard({
    super.key,
    required this.anime,
    required this.status,
  });

  static final bodyHeight = PosterCard.bodyHeight();

  final AnimeInfo anime;

  final WatchStatus? status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final release = anime.release;
    final episodes = release.isAnnounced
        ? 'анонс'
        : release.isOngoing
        ? (release.episodes > 0
              ? '${release.aired} из ${release.episodes} эп.'
              : '${release.aired} эп.')
        : release.availableEpisodes > 0
        ? '${release.availableEpisodes} эп.'
        : null;
    final metaText = [
      kindLabel(anime.kind),
      if (anime.year != null) '${anime.year}',
      ?episodes,
    ].join(' · ');

    return PosterCard(
      posterUrl: anime.posterUrl,
      posterBadge: ReleaseBadge(release: release),
      title: anime.title,
      subtitle: anime.russian.isNotEmpty ? anime.name : '',
      meta: Row(
        children: [
          Flexible(
            child: Text(metaText, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          if (anime.score != null && anime.score! > 0) ...[
            const Text(' · '),
            const Icon(LucideIcons.star, size: 12, color: Color(0xFFFFD79C)),
            const SizedBox(width: 3),
            Text(anime.score!.toStringAsFixed(1)),
          ],
        ],
      ),
      onTap: () async {
        await ref.read(libraryRepositoryProvider).saveAnime(anime);
        if (context.mounted) {
          openTitle(context, animeId: anime.id, backLabel: 'Назад к поиску');
        }
      },
      action: status == null
          ? AddToLibraryButton(anime: anime)
          : EntryStatusButton(
              animeId: anime.id,
              title: anime.title,
              status: status!,
              release: release,
            ),
    );
  }
}
