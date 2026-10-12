import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/status_menu.dart';
import '../../data/database/status_action.dart';
import '../../data/database/watch_status.dart';
import '../../data/providers.dart';
import '../../data/shikimori/release_facts.dart';
import 'library_actions.dart';
import 'library_filter.dart';

/// Статус тайтла в библиотеке.
class EntryStatusButton extends ConsumerWidget {
  const EntryStatusButton({
    super.key,
    required this.animeId,
    required this.title,
    required this.status,
    required this.release,
    this.compact = false,
    this.allowRemove = true,
  });

  final int animeId;
  final String title;
  final WatchStatus status;
  final ReleaseFacts release;
  final bool compact;

  final bool allowRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final caughtUp = ref.watch(
      libraryItemsProvider.select((items) {
        final item = items.value
            ?.where((item) => item.anime.id == animeId)
            .firstOrNull;
        return item != null && isCaughtUp(item);
      }),
    );
    return StatusMenu(
      actions: StatusAction.availableFor(release),
      current: status,
      caughtUp: caughtUp,
      onSelected: (action) {
        if (action == StatusAction.forStatus(status) && !caughtUp) return;
        if (caughtUp &&
            (action == StatusAction.caughtUp ||
                action == StatusAction.watching)) {
          return;
        }
        changeStatus(ref, animeId: animeId, title: title, action: action);
      },
      onRemove: allowRemove
          ? () => removeFromLibrary(ref, animeId: animeId, title: title)
          : null,
      builder: (context, controller, _) => StatusButton(
        status: status,
        compact: compact,
        caughtUp: caughtUp,
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
      ),
    );
  }
}
