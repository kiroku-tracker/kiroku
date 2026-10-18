import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_menu_anchor.dart';
import '../../core/widgets/status_menu.dart';
import '../../data/database/app_database.dart';
import '../../data/providers.dart';
import '../discord/discord_menu.dart';
import '../groups/group_actions.dart';
import '../groups/group_model.dart';
import '../notifications/notice_center.dart';

/// Заголовок библиотеки с выбором группы.
class LibraryHeader extends ConsumerWidget {
  const LibraryHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupId = ref.watch(libraryGroupProvider);
    final groups = ref.watch(userGroupsProvider).value;
    final current = groups?.where((group) => group.id == groupId).firstOrNull;
    if (groupId != null && groups != null && current == null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => ref.read(libraryGroupProvider.notifier).select(null),
      );
    }
    return Row(
      children: [
        Text('Библиотека', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(width: 16),
        _GroupSelect(current: current, groups: groups ?? const []),
        if (current != null) ...[
          const SizedBox(width: 4),
          _GroupMenu(group: current),
        ],
        const Spacer(),
        const NoticesButton(),
      ],
    );
  }
}

/// Выбор группы: вся библиотека или одна группа; там же новая группа.
class _GroupSelect extends ConsumerWidget {
  const _GroupSelect({required this.current, required this.groups});

  final UserGroup? current;
  final List<UserGroup> groups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = this.current;
    void select(String? id) =>
        ref.read(libraryGroupProvider.notifier).select(id);
    Future<void> create() async {
      final id = await createGroup(context, ref);
      if (id != null) select(id);
    }

    return AppMenuAnchor(
      style: AppTheme.menuStyle,
      alignmentOffset: const Offset(0, 8),
      menuChildren: [
        AppMenuItem(
          label: 'Все аниме',
          icon: LucideIcons.library,
          color: current == null ? Colors.white : AppColors.menuItemText,
          checked: current == null,
          onPressed: () => select(null),
        ),
        for (final group in groups)
          AppMenuItem(
            label: group.name,
            icon: LucideIcons.folder,
            color: current?.id == group.id
                ? Colors.white
                : AppColors.menuItemText,
            checked: current?.id == group.id,
            onPressed: () => select(group.id),
          ),
        const Divider(height: 9, thickness: 1, color: Color(0xFF35323C)),
        AppMenuItem(
          label: 'Новая группа…',
          icon: LucideIcons.folderPlus,
          color: AppColors.menuItemText,
          onPressed: create,
        ),
      ],
      builder: (context, controller, _) => Tooltip(
        message: 'Группа',
        child: OutlinedButton(
          onPressed: () =>
              controller.isOpen ? controller.close() : controller.open(),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                current == null ? LucideIcons.library : LucideIcons.folder,
                size: 16,
                color: AppColors.navIdle,
              ),
              const SizedBox(width: 8),
              Text(current?.name ?? 'Все аниме'),
              const SizedBox(width: 6),
              const Icon(
                LucideIcons.chevronDown,
                size: 15,
                color: AppColors.navIdle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// «⋯» выбранной группы: переименовать и удалить.
class _GroupMenu extends ConsumerWidget {
  const _GroupMenu({required this.group});

  final UserGroup group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref
        .watch(groupViewsProvider)
        .value
        ?.where((view) => view.group.id == group.id)
        .firstOrNull;
    return AppMenuAnchor(
      style: AppTheme.menuStyle,
      alignmentOffset: const Offset(0, 6),
      menuChildren: [
        AppMenuItem(
          label: 'Переименовать…',
          icon: LucideIcons.pencil,
          color: AppColors.menuItemText,
          onPressed: () =>
              renameGroup(context, ref, id: group.id, current: group.name),
        ),
        if (view != null) ?discordGroupItem(context, ref, view),
        AppMenuItem(
          label: 'Удалить группу',
          icon: LucideIcons.trash2,
          color: AppColors.dangerText,
          onPressed: () {
            ref.read(libraryGroupProvider.notifier).select(null);
            deleteGroup(ref, id: group.id, name: group.name);
          },
        ),
      ],
      builder: (context, controller, _) => IconButton(
        tooltip: 'Действия с группой',
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
        icon: const Icon(LucideIcons.ellipsis, size: 20),
      ),
    );
  }
}
