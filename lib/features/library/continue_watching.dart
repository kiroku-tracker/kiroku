import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/labels.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/interactive_card.dart';
import '../../core/widgets/poster.dart';
import '../../data/database/app_database.dart';
import '../../data/database/library_repository.dart';
import '../title/title_screen.dart';
import '../watch/watch_actions.dart';
import 'library_actions.dart';
import 'library_filter.dart';

/// Блок «Продолжить просмотр».
class ContinueWatching extends StatelessWidget {
  const ContinueWatching({super.key, required this.items});

  final List<LibraryItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Продолжить просмотр',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 128,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) => _ContinueCard(item: items[index]),
          ),
        ),
      ],
    );
  }
}

class _ContinueCard extends ConsumerWidget {
  const _ContinueCard({required this.item});

  final LibraryItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final anime = item.anime;
    final next = item.progress.nextEpisode;
    final left = unwatchedAired(item);
    final release = anime.release;
    final status = release.isOngoing
        ? (left == 1 ? 'Вышла новая серия' : 'Вышло новых: $left')
        : 'Осталось ${episodesLabel(left)}';

    return SizedBox(
      width: 340,
      child: InteractiveCard(
        onTap: () => openTitle(
          context,
          animeId: anime.id,
          backLabel: 'Назад в библиотеку',
        ),
        semanticLabel: 'Открыть: ${anime.title}',
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              SizedBox(
                width: 72,
                child: Poster(
                  url: anime.posterUrl,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      anime.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _progressText(anime, item.progress.watched),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      status,
                      maxLines: 1,
                      style: TextStyle(
                        color: release.isOngoing
                            ? const Color(0xFFCBBFFF)
                            : AppColors.muted,
                        fontSize: 12,
                        fontWeight: release.isOngoing
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        SizedBox.square(
                          dimension: 32,
                          child: Tooltip(
                            message: 'Смотреть',
                            child: FilledButton(
                              onPressed: () => watchTitle(ref, anime),
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.square(32),
                                padding: EdgeInsets.zero,
                              ),
                              child: const Icon(LucideIcons.play, size: 15),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        SizedBox(
                          height: 32,
                          child: OutlinedButton.icon(
                            onPressed: () => markNextEpisode(
                              ref,
                              animeId: anime.id,
                              title: anime.title,
                            ),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 32),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                            ),
                            icon: const Icon(LucideIcons.circleCheck, size: 15),
                            label: Text('Серия $next'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _progressText(Anime anime, int watched) {
    final release = anime.release;
    return release.isOngoing
        ? 'Просмотрено $watched из ${release.availableEpisodes} вышедших'
        : 'Просмотрено $watched из ${release.availableEpisodes}';
  }
}
