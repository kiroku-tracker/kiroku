import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/widgets/status_menu.dart';
import '../../data/database/status_action.dart';
import '../../data/shikimori/anime_info.dart';
import 'library_actions.dart';

/// Кнопка «Добавить» с выбором статуса.
class AddToLibraryButton extends ConsumerWidget {
  const AddToLibraryButton({
    super.key,
    required this.anime,
    this.label = 'Добавить',
    this.compact = false,
  });

  final AnimeInfo anime;
  final String label;

  final bool compact;

  static final _compactStyle = OutlinedButton.styleFrom(
    minimumSize: const Size(0, 32),
    padding: const EdgeInsets.symmetric(horizontal: 10),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = StatusAction.availableFor(anime.release);

    if (actions.length == 1) {
      final action = actions.single;
      void add() => addToLibrary(ref, anime, action);
      return compact
          ? OutlinedButton.icon(
              onPressed: add,
              style: _compactStyle,
              icon: const Icon(LucideIcons.clock3, size: 15),
              label: Text(action.label),
            )
          : FilledButton.icon(
              onPressed: add,
              icon: const Icon(LucideIcons.clock3),
              label: Text(action.label),
            );
    }

    return StatusMenu(
      actions: actions,
      onSelected: (action) => addToLibrary(ref, anime, action),
      builder: (context, controller, _) {
        void toggle() =>
            controller.isOpen ? controller.close() : controller.open();
        final content = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.plus, size: compact ? 15 : 17),
            SizedBox(width: compact ? 6 : 8),
            Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            SizedBox(width: compact ? 4 : 6),
            Icon(LucideIcons.chevronDown, size: compact ? 14 : 16),
          ],
        );
        return compact
            ? OutlinedButton(
                onPressed: toggle,
                style: _compactStyle,
                child: content,
              )
            : FilledButton(onPressed: toggle, child: content);
      },
    );
  }
}
