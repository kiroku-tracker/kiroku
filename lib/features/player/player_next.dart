import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/poster.dart';
import '../../data/database/app_database.dart';
import '../../data/database/franchise_rules.dart';
import '../../data/providers.dart';
import '../franchise/watch_order_list.dart';
import '../notifications/release_watcher.dart';
import '../watch/watch_actions.dart';
import 'player_session.dart';

/// Досмотрена последняя серия вышедшего сезона.
bool seasonFinished(Anime anime, int? episode) {
  final release = anime.release;
  return episode != null &&
      release.isReleased &&
      release.availableEpisodes > 0 &&
      episode >= release.availableEpisodes;
}

/// Следующая вышедшая часть основной линии франшизы.
FranchisePart? nextFranchisePart(List<FranchisePart> main, int animeId) {
  final index = main.indexWhere((part) => part.anime.id == animeId);
  if (index < 0) return null;
  for (final part in main.skip(index + 1)) {
    if (!part.anime.release.isAnnounced) return part;
  }
  return null;
}

/// Кнопка следующей части франшизы.
class PlayerNextCard extends ConsumerWidget {
  const PlayerNextCard({super.key, required this.session});

  final PlayerSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animeId = session.animeId;
    if (animeId == null) return const SizedBox.shrink();
    final anime = ref.watch(animeProvider(animeId)).value;
    if (anime == null || !seasonFinished(anime, session.site.episode)) {
      return const SizedBox.shrink();
    }
    final part = _nextPart(ref, anime);
    if (part == null) return const SizedBox.shrink();
    final kind = part.anime.kind;
    final season = kind == null || kind == 'tv' || kind == 'ona';
    return PlayerNextTile(
      title: season ? 'Следующий сезон' : 'Следующая часть',
      subtitle: part.anime.title,
      posterUrl: part.anime.posterUrl,
      onClose: session.hideNext,
      onPressed: () => watchOnSite(
        ref,
        part.anime,
        inApp: true,
        episode: part.item == null ? 1 : null,
      ),
    );
  }

  FranchisePart? _nextPart(WidgetRef ref, Anime anime) {
    final entry = ref.watch(libraryEntryProvider(anime.id)).value;
    final key = entry != null
        ? franchiseKeyOf(entry, anime)
        : (anime.franchise?.isEmpty ?? true)
        ? null
        : anime.franchise;
    if (key == null) return null;
    ref.watch(franchiseLoadProvider(key));
    final order = ref.watch(watchOrderProvider(key)).value;
    final library = ref.watch(libraryItemsProvider).value ?? const [];
    return nextFranchisePart(
      franchiseParts(key, order, library).main,
      anime.id,
    );
  }
}

/// Плитка следующего сезона или части.
class PlayerNextTile extends StatelessWidget {
  const PlayerNextTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.posterUrl,
    this.icon = LucideIcons.play,
    required this.onPressed,
    required this.onClose,
  });

  final String title;
  final String subtitle;
  final String? posterUrl;
  final IconData icon;
  final VoidCallback onPressed;
  final VoidCallback onClose;

  static const _radius = BorderRadius.all(Radius.circular(16));

  @override
  Widget build(BuildContext context) {
    final posterUrl = this.posterUrl;
    return Material(
      color: Colors.black.withValues(alpha: 0.72),
      borderRadius: _radius,
      child: InkWell(
        onTap: onPressed,
        borderRadius: _radius,
        hoverColor: Colors.white.withValues(alpha: 0.06),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (posterUrl != null)
                SizedBox(
                  width: 56,
                  child: Poster(
                    url: posterUrl,
                    borderRadius: BorderRadius.circular(8),
                  ),
                )
              else
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
              const SizedBox(width: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: onClose,
                tooltip: 'Скрыть кнопку',
                color: Colors.white60,
                iconSize: 18,
                icon: const Icon(LucideIcons.x),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
