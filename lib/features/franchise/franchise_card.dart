import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/labels.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/fresh_badge.dart';
import '../../core/widgets/poster_card.dart';
import '../../data/database/app_database.dart';
import '../../data/database/franchise_rules.dart';
import '../../data/database/watch_status.dart';
import '../../data/providers.dart';
import '../library/library_actions.dart';
import '../library/library_filter.dart';
import '../watch/watch_actions.dart';
import 'franchise_screen.dart';

class FranchiseCard extends ConsumerWidget {
  const FranchiseCard({
    super.key,
    required this.unit,
    required this.tab,
    required this.backLabel,
  });

  final FranchiseUnit unit;

  final WatchStatus? tab;
  final String backLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = unit.items.length;
    final tab = this.tab;
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

    return PosterCard(
      posterUrl: unit.cover.anime.posterUrl,
      posterBadge: FranchiseBadge(parts: total),
      posterBadgeEnd: fresh > 0 ? FreshBadge(count: fresh) : null,
      title: unit.name,
      subtitle: tab == null
          ? partsLabel(total)
          : '${tab.label}: ${unit.countOf(tab)} из $total',
      meta: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: 'Просмотрено ${unit.completedCount} из $total'),
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
      extra: ProgressBar(value: unit.completedCount / total),
      onTap: () => openFranchise(context, key: unit.key, backLabel: backLabel),
      action: next == null
          ? OutlinedButton.icon(
              onPressed: () =>
                  openFranchise(context, key: unit.key, backLabel: backLabel),
              icon: const Icon(LucideIcons.listOrdered),
              label: const Text('Порядок просмотра'),
            )
          : Row(
              children: [
                Tooltip(
                  message: 'Смотреть',
                  child: FilledButton(
                    onPressed: () => watchTitle(ref, next.anime),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.square(40),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Icon(LucideIcons.play, size: 17),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Tooltip(
                    message: next.anime.title,
                    child: OutlinedButton.icon(
                      onPressed: () => markNextEpisode(
                        ref,
                        animeId: next.anime.id,
                        title: next.anime.title,
                      ),
                      icon: const Icon(LucideIcons.circleCheck),
                      label: Text(
                        'Серия ${next.progress.nextEpisode} · '
                        'часть ${unit.items.indexOf(next) + 1}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
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
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 3, 8, 3),
      decoration: BoxDecoration(
        color: const Color(0xE6131217),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF46424F)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.layers, size: 12, color: AppColors.text),
          const SizedBox(width: 5),
          Text(
            'Франшиза · $parts',
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
