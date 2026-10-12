import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/panel.dart';
import '../../data/database/app_database.dart';
import '../../data/providers.dart';
import 'franchise_screen.dart';
import 'watch_order_list.dart';

/// Блок франшизы на странице тайтла.
class TitleFranchisePanel extends ConsumerWidget {
  const TitleFranchisePanel({
    super.key,
    required this.franchiseKey,
    required this.animeId,
  });

  final String franchiseKey;
  final int animeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(franchiseLoadProvider(franchiseKey));
    final library = ref.watch(libraryItemsProvider).value ?? const [];
    final order = ref.watch(watchOrderProvider(franchiseKey)).value;
    final row = ref.watch(franchisesProvider).value?[franchiseKey];
    final parts = franchiseParts(franchiseKey, order, library);
    final total = parts.main.length + parts.extra.length;
    if (total < 2) return const SizedBox.shrink();

    final name =
        row?.name ?? row?.autoName ?? parts.main.firstOrNull?.anime.title;
    final currentExtra = parts.extra
        .where((part) => part.anime.id == animeId)
        .toList();

    return Panel(
      title: name == null ? 'Франшиза' : 'Франшиза: $name',
      trailing: TextButton.icon(
        onPressed: () => openFranchise(
          context,
          key: franchiseKey,
          backLabel: 'Назад к тайтлу',
        ),
        icon: const Icon(LucideIcons.listOrdered, size: 16),
        label: Text(
          parts.extra.isEmpty
              ? 'Открыть франшизу'
              : 'Открыть франшизу · ещё ${parts.extra.length} доп.',
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WatchOrderList(
            parts: parts.main,
            currentAnimeId: animeId,
            backLabel: 'Назад к тайтлу',
          ),
          if (currentExtra.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(8, 14, 8, 6),
              child: Text(
                'Дополнительная часть франшизы',
                style: TextStyle(color: AppColors.muted, fontSize: 13),
              ),
            ),
            WatchOrderList(
              parts: currentExtra,
              numbered: false,
              currentAnimeId: animeId,
              backLabel: 'Назад к тайтлу',
            ),
          ],
        ],
      ),
    );
  }
}
