import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/labels.dart';
import '../../core/widgets/card_marks.dart';
import '../../core/widgets/fresh_badge.dart';
import '../../core/widgets/poster_card.dart';
import '../../data/database/app_database.dart';
import '../../data/database/franchise_rules.dart';
import '../../data/database/watch_status.dart';
import '../../data/database/user_groups_repository.dart';
import '../../data/providers.dart';
import '../library/library_filter.dart';
import '../watch/watch_next_button.dart';
import '../groups/group_actions.dart';
import '../title/views_menu.dart';
import 'franchise_screen.dart';

class FranchiseCard extends ConsumerWidget {
  const FranchiseCard({
    super.key,
    required this.unit,
    required this.backLabel,
    this.group,
  });

  final FranchiseUnit unit;

  /// Открытая в библиотеке группа: в меню есть «Убрать из группы».
  final UserGroup? group;

  final String backLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = unit.items.length;
    final queue = ref.watch(activeQueuesProvider).value?[unit.key];
    final next = franchiseNextPart(unit, preferred: queue?.active?.animeId);
    final fresh = unit.items
        .where(
          (item) =>
              item.status == WatchStatus.watching &&
              item.anime.release.isOngoing,
        )
        .fold<int>(0, (sum, item) => sum + unwatchedAired(item));
    final average = unit.averageScore;
    final favorite =
        ref.watch(franchisesProvider).value?[unit.key]?.favorite ?? false;
    final views = viewCount(
      viewParts(unit.items, ref.watch(viewsProvider).value ?? const {}),
    );

    return PosterCard(
      posterUrl: unit.cover.anime.posterUrl,
      posterBadge: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          FranchiseBadge(parts: total),
          if (views > 1) ViewsBadge(count: views),
        ],
      ),
      posterBadgeEnd: fresh > 0 ? FreshBadge(count: fresh) : null,
      title: unit.name,
      subtitle: total > unit.releasedCount
          ? '${partsLabel(total)}, ещё не вышло: '
                '${total - unit.releasedCount}'
          : partsLabel(total),
      meta: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: unit.all == null
                  ? 'Просмотрено ${unit.completedCount} из '
                        '${unit.releasedCount}'
                  : unit.availableEpisodes == 0
                  ? 'Ещё не вышло'
                  : '${unit.watchedEpisodes} из ${unit.availableEpisodes} эп.',
            ),
            if (average != null) ...[
              const TextSpan(text: '  ·  '),
              const WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Icon(
                  LucideIcons.star,
                  size: 13,
                  color: Color(0xFFFFC857),
                ),
              ),
              TextSpan(text: ' ${formatAverage(average)}'),
            ],
          ],
        ),
      ),
      extra: ProgressBar(value: unit.progress),
      onTap: () => openFranchise(context, key: unit.key, backLabel: backLabel),
      menu: next == null && group == null
          ? null
          : () => [
              if (next != null)
                ...titleCardMenu(
                  ref,
                  next,
                  markSuffix:
                      ' · часть ${(unit.all ?? unit.items).indexOf(next) + 1}',
                ),
              if (group case final group?)
                removeFromGroupItem(
                  ref,
                  group: group,
                  title: unit.name,
                  addKey: franchiseMemberKey(unit.key),
                  keys: {
                    franchiseMemberKey(unit.key),
                    for (final item in unit.items) 'a:${item.anime.id}',
                  },
                ),
            ],
      favorite: favorite,
      onFavorite: () => ref
          .read(franchiseRepositoryProvider)
          .setFavorite(unit.key, !favorite),
      action: next == null
          ? CardFacts(years: _years(unit), genres: _genres(unit))
          : Tooltip(
              message: next.anime.title,
              child: WatchNextButton(
                anime: next.anime,
                status: next.status,
                next: next.progress.nextEpisode,
                watched: next.progress.watched,
                whenWatched: CardFacts(
                  years: _years(unit),
                  genres: _genres(unit),
                ),
              ),
            ),
    );
  }
}

/// Число частей словами.
String partsLabel(int count) =>
    '$count ${plural(count, 'часть', 'части', 'частей')}';

String formatAverage(double value) {
  final rounded = (value * 10).round() / 10;
  return rounded == rounded.roundToDouble()
      ? rounded.toInt().toString()
      : rounded.toString().replaceAll('.', ',');
}

/// Плашка франшизы на постере.
class FranchiseBadge extends StatelessWidget {
  const FranchiseBadge({super.key, required this.parts});

  final int parts;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: 'Частей во франшизе: $parts',
    child: PosterPill(icon: LucideIcons.layers, text: '$parts'),
  );
}

/// Годы выхода частей: «2016» или «2016–2023».
String? _years(FranchiseUnit unit) {
  final years = [for (final item in unit.items) ?item.anime.year]..sort();
  if (years.isEmpty) return null;
  return years.first == years.last
      ? '${years.first}'
      : '${years.first}–${years.last}';
}

/// Самые частые жанры частей.
List<String> _genres(FranchiseUnit unit) {
  final counts = <String, int>{};
  for (final item in unit.items) {
    for (final genre in item.anime.genreList) {
      counts[genre] = (counts[genre] ?? 0) + 1;
    }
  }
  return (counts.entries.toList()..sort((a, b) => b.value - a.value))
      .map((entry) => entry.key)
      .toList();
}
