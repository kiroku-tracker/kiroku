import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app_section.dart';
import '../../core/theme/app_colors.dart';
import '../../core/toast.dart';
import '../../core/widgets/text_prompt.dart';
import '../../core/widgets/status_menu.dart';
import '../../data/database/app_database.dart';
import '../../data/providers.dart';

/// Действия с группами.

/// Группа, которую показывает библиотека; null — вся библиотека.
class LibraryGroupNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? groupId) => state = groupId;
}

final libraryGroupProvider = NotifierProvider<LibraryGroupNotifier, String?>(
  LibraryGroupNotifier.new,
);

/// Пункт «Убрать из группы» для тайтла или франшизы.
Widget removeFromGroupItem(
  WidgetRef ref, {
  required UserGroup group,
  required String title,
  required String addKey,
  required Set<String> keys,
}) => AppMenuItem(
  label: 'Убрать из группы',
  icon: LucideIcons.folderMinus,
  color: AppColors.dangerText,
  onPressed: () => setGroupMembership(
    ref,
    groupId: group.id,
    groupName: group.name,
    title: title,
    addKey: addKey,
    keys: keys,
    member: false,
  ),
);

/// Открывает группу в библиотеке.
void openGroup(BuildContext context, String groupId) {
  final container = ProviderScope.containerOf(context);
  container.read(libraryGroupProvider.notifier).select(groupId);
  container.read(appSectionProvider.notifier).open(AppSection.library);
  sectionNavigatorKeys[AppSection.library]?.currentState?.popUntil(
    (route) => route.isFirst,
  );
}

Future<String?> createGroup(BuildContext context, WidgetRef ref) async {
  final name = await askText(
    context,
    title: 'Новая группа',
    confirmLabel: 'Создать',
    hint: 'Например, «Лучшее» или «Посмотреть с друзьями»',
  );
  if (name == null) return null;
  return ref.read(userGroupsRepositoryProvider).create(name);
}

Future<void> renameGroup(
  BuildContext context,
  WidgetRef ref, {
  required String id,
  required String current,
}) async {
  final name = await askText(
    context,
    title: 'Название группы',
    confirmLabel: 'Сохранить',
    initial: current,
  );
  if (name == null || name == current) return;
  await ref.read(userGroupsRepositoryProvider).rename(id, name);
}

Future<void> deleteGroup(
  WidgetRef ref, {
  required String id,
  required String name,
}) async {
  final undo = await ref.read(userGroupsRepositoryProvider).delete(id);
  ref
      .read(toastProvider.notifier)
      .show('Группа «$name» удалена, тайтлы остались в библиотеке', undo: undo);
}

/// Добавляет в группу или убирает из неё.
Future<void> setGroupMembership(
  WidgetRef ref, {
  required String groupId,
  required String groupName,
  required String title,
  required String addKey,
  required Set<String> keys,
  required bool member,
}) async {
  final repository = ref.read(userGroupsRepositoryProvider);
  final undos = <Future<void> Function()>[];
  if (member) {
    undos.add(await repository.setMember(groupId, addKey, member: true));
  } else {
    for (final key in keys) {
      undos.add(await repository.setMember(groupId, key, member: false));
    }
  }
  ref
      .read(toastProvider.notifier)
      .show(
        member
            ? '«$title» добавлено в группу «$groupName»'
            : '«$title» убрано из группы «$groupName»',
        undo: () async {
          for (final undo in undos.reversed) {
            await undo();
          }
        },
      );
}

/// Окно выбора групп.
Future<void> showGroupsDialog(
  BuildContext context, {
  required String title,

  required String addKey,

  required Set<String> keys,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) =>
        _GroupsDialog(title: title, addKey: addKey, keys: keys),
  );
}

class _GroupsDialog extends ConsumerWidget {
  const _GroupsDialog({
    required this.title,
    required this.addKey,
    required this.keys,
  });

  final String title;
  final String addKey;
  final Set<String> keys;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(userGroupsProvider).value ?? const [];
    final members = ref.watch(groupMembersProvider).value ?? const {};

    return AlertDialog(
      title: Text('Группы: $title'),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (groups.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 14),
                child: Text(
                  'Групп пока нет.',
                  style: TextStyle(color: AppColors.muted, height: 1.45),
                ),
              ),
            for (final group in groups)
              CheckboxListTile(
                value: (members[group.id] ?? const {}).any(keys.contains),
                onChanged: (checked) => setGroupMembership(
                  ref,
                  groupId: group.id,
                  groupName: group.name,
                  title: title,
                  addKey: addKey,
                  keys: keys,
                  member: checked ?? false,
                ),
                title: Text(group.name),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                dense: true,
              ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () async {
                final id = await createGroup(context, ref);
                if (id == null) return;
                final name = await ref
                    .read(userGroupsRepositoryProvider)
                    .watchGroups()
                    .first
                    .then(
                      (groups) =>
                          groups.firstWhere((group) => group.id == id).name,
                    );
                await setGroupMembership(
                  ref,
                  groupId: id,
                  groupName: name,
                  title: title,
                  addKey: addKey,
                  keys: keys,
                  member: true,
                );
              },
              icon: const Icon(LucideIcons.folderPlus),
              label: const Text('Новая группа…'),
            ),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Готово'),
        ),
      ],
    );
  }
}
