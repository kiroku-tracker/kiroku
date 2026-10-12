import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/toast.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../core/widgets/status_menu.dart';
import '../../data/database/app_database.dart';
import '../../data/database/discord_hidden.dart';
import '../../data/database/franchise_rules.dart';
import '../../data/providers.dart';
import '../../system/discord_presence.dart';
import '../groups/group_model.dart';

/// Пункт меню группы: скрыть или показывать в Discord.
Widget? discordGroupItem(BuildContext context, WidgetRef ref, GroupView view) {
  final hidden = _hidden(ref);
  if (hidden == null) return null;
  final isHidden = hidden.groups.contains(view.group.id);
  return _item(
    isHidden: isHidden,
    onPressed: () async {
      final confirmed = await confirmAction(
        context,
        title: isHidden
            ? 'Показывать группу в Discord?'
            : 'Скрыть группу в Discord?',
        message: isHidden
            ? 'Вместе с группой станут видны все франшизы и тайтлы в ней. '
                  'Скрытые в других группах останутся скрытыми.'
            : 'Вместе с группой скроются все франшизы и тайтлы в ней.',
        confirmLabel: isHidden ? 'Показывать' : 'Скрыть',
      );
      if (!confirmed) return;
      await ref
          .read(discordHiddenProvider.notifier)
          .setGroup(
            view.group.id,
            franchises: {
              for (final key in view.members)
                if (key.startsWith('f:')) key.substring(2),
              for (final item in view.items)
                ?franchiseKeyOf(item.entry, item.anime),
            },
            titles: [for (final item in view.items) item.anime.id],
            hidden: !isHidden,
          );
      _done(ref, hidden: !isHidden);
    },
  );
}

/// Пункт меню франшизы: скрыть или показывать в Discord.
Widget? discordFranchiseItem(
  BuildContext context,
  WidgetRef ref, {
  required String franchiseKey,
  required List<Anime> parts,
}) {
  final hidden = _hidden(ref);
  if (hidden == null) return null;
  final isHidden = hidden.franchises.contains(franchiseKey);
  return _item(
    isHidden: isHidden,
    onPressed: () async {
      final confirmed = await confirmAction(
        context,
        title: isHidden
            ? 'Показывать франшизу в Discord?'
            : 'Скрыть франшизу в Discord?',
        message: isHidden
            ? 'Вместе с франшизой станут видны все её тайтлы.'
            : 'Вместе с франшизой скроются все её тайтлы.',
        confirmLabel: isHidden ? 'Показывать' : 'Скрыть',
      );
      if (!confirmed) return;
      await ref
          .read(discordHiddenProvider.notifier)
          .setFranchise(
            franchiseKey,
            titles: [for (final anime in parts) anime.id],
            hidden: !isHidden,
          );
      _done(ref, hidden: !isHidden);
    },
  );
}

/// Пункт меню тайтла: скрыть или показывать в Discord.
Widget? discordTitleItem(
  WidgetRef ref, {
  required Anime anime,
  required LibraryEntry? entry,
}) {
  final hidden = _hidden(ref);
  if (hidden == null) return null;
  final members = ref.watch(groupMembersProvider).value ?? const {};
  final isHidden = anime.hiddenIn(hidden, entry: entry, members: members);
  return _item(
    isHidden: isHidden,
    onPressed: () async {
      final notifier = ref.read(discordHiddenProvider.notifier);
      await notifier.setTitle(anime.id, hidden: !isHidden);
      final now = await ref.read(discordHiddenProvider.future);
      if (isHidden && anime.hiddenIn(now, entry: entry, members: members)) {
        ref
            .read(toastProvider.notifier)
            .show('Тайтл скрыт вместе с франшизой или группой');
        return;
      }
      _done(ref, hidden: !isHidden);
    },
  );
}

DiscordHidden? _hidden(WidgetRef ref) {
  final enabled = ref.watch(appPrefsProvider).value?.discord ?? false;
  if (!enabled) return null;
  return ref.watch(discordHiddenProvider).value ?? const DiscordHidden();
}

Widget _item({required bool isHidden, required VoidCallback onPressed}) =>
    AppMenuItem(
      label: isHidden ? 'Показывать в Discord' : 'Скрыть в Discord',
      icon: isHidden ? LucideIcons.eye : LucideIcons.eyeOff,
      color: AppColors.menuItemText,
      onPressed: onPressed,
    );

void _done(WidgetRef ref, {required bool hidden}) => ref
    .read(toastProvider.notifier)
    .show(hidden ? 'Скрыто в Discord' : 'Видно в Discord');
