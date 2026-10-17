import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app_section.dart';
import '../../core/theme/app_colors.dart';
import 'party_controller.dart';

/// Комната в плеере: сколько человек и кого ждут; ведёт в раздел.
class PartyChip extends ConsumerWidget {
  const PartyChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final party = ref.watch(partyProvider);
    if (!party.active) return const SizedBox.shrink();
    final waiting = party.waiting;
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: TextButton.icon(
        onPressed: () =>
            ref.read(appSectionProvider.notifier).open(AppSection.party),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentText,
          padding: const EdgeInsets.symmetric(horizontal: 10),
        ),
        icon: const Icon(LucideIcons.users, size: 17),
        label: Text(
          party.reconnecting
              ? 'Переподключение…'
              : waiting == null
              ? 'Вместе · ${party.people.length}'
              : 'Ждём: $waiting',
        ),
      ),
    );
  }
}
