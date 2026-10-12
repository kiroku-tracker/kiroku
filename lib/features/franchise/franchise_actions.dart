import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/labels.dart';
import '../../core/theme/app_colors.dart';
import '../../core/toast.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../core/widgets/poster.dart';
import '../../core/widgets/text_prompt.dart';
import '../../data/database/app_database.dart';
import '../../data/database/franchise_rules.dart';
import '../../data/database/library_repository.dart';
import '../../data/database/queue_repository.dart';
import '../../data/database/watch_status.dart';
import '../../data/providers.dart';
import 'watch_order_list.dart';

Future<void> renameFranchise(
  BuildContext context,
  WidgetRef ref, {
  required String key,
  required String current,
}) async {
  final name = await askText(
    context,
    title: 'Название франшизы',
    confirmLabel: 'Сохранить',
    initial: current,
  );
  if (name == null || name == current) return;
  final undo = await ref.read(franchiseRepositoryProvider).rename(key, name);
  ref.read(toastProvider.notifier).show('Франшиза: «$name»', undo: undo);
}

Future<void> resetFranchiseName(WidgetRef ref, {required String key}) async {
  final undo = await ref.read(franchiseRepositoryProvider).rename(key, null);
  ref
      .read(toastProvider.notifier)
      .show('Название франшизы как у Shikimori', undo: undo);
}

/// Выбор обложки франшизы.
Future<void> chooseFranchiseCover(
  BuildContext context,
  WidgetRef ref, {
  required String key,
  required List<Anime> parts,
  required int? current,
}) async {
  final chosen = await showDialog<int>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Обложка франшизы'),
      content: SizedBox(
        width: 560,
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final anime in parts)
              _CoverOption(
                anime: anime,
                selected: anime.id == current,
                onTap: () => Navigator.of(context).pop(anime.id),
              ),
          ],
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
      ],
    ),
  );
  if (chosen == null || chosen == current) return;
  final undo = await ref
      .read(franchiseRepositoryProvider)
      .setCover(key, chosen);
  ref
      .read(toastProvider.notifier)
      .show('Обложка франшизы изменена', undo: undo);
}

class _CoverOption extends StatelessWidget {
  const _CoverOption({
    required this.anime,
    required this.selected,
    required this.onTap,
  });

  final Anime anime;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: anime.title,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 100,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppColors.focus : Colors.transparent,
              width: 2,
            ),
          ),
          child: Poster(
            url: anime.posterUrl,
            borderRadius: BorderRadius.circular(7),
          ),
        ),
      ),
    );
  }
}

/// Выносит тайтл из франшизы.
Future<void> removeFromFranchise(WidgetRef ref, LibraryItem item) async {
  final undo = await ref
      .read(franchiseRepositoryProvider)
      .setOverride(item.anime.id, '');
  ref
      .read(toastProvider.notifier)
      .show('«${item.anime.title}» вынесен из франшизы', undo: undo);
}

/// Возвращает тайтл во франшизу Shikimori.
Future<void> resetFranchise(WidgetRef ref, LibraryItem item) async {
  final undo = await ref
      .read(franchiseRepositoryProvider)
      .setOverride(item.anime.id, null);
  ref
      .read(toastProvider.notifier)
      .show('«${item.anime.title}» снова во франшизе Shikimori', undo: undo);
}

/// Переносит тайтл в другую франшизу.
Future<void> moveToFranchise(
  BuildContext context,
  WidgetRef ref,
  LibraryItem item,
) async {
  final library = ref.read(libraryItemsProvider).value ?? const [];
  final rows = ref.read(franchisesProvider).value ?? const {};
  final currentKey = franchiseKeyOf(item.entry, item.anime);
  final options = [
    for (final unit in groupLibrary(library, rows).whereType<FranchiseUnit>())
      if (unit.key != currentKey) unit,
  ]..sort((a, b) => a.name.compareTo(b.name));

  const newFranchise = '';
  final chosen = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Перенести «${item.anime.title}»'),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final unit in options)
              _ChoiceRow(
                posterUrl: unit.cover.anime.posterUrl,
                title: unit.name,
                subtitle: 'Частей в библиотеке: ${unit.items.length}',
                onTap: () => Navigator.of(context).pop(unit.key),
              ),
            if (options.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 14),
                child: Text(
                  'Других франшиз в библиотеке нет. Можно создать новую.',
                  style: TextStyle(color: AppColors.muted, height: 1.45),
                ),
              )
            else
              const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(newFranchise),
              icon: const Icon(LucideIcons.plus),
              label: const Text('Новая франшиза…'),
            ),
          ],
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
      ],
    ),
  );
  if (chosen == null || !context.mounted) return;

  final repository = ref.read(franchiseRepositoryProvider);
  var key = chosen;
  var name = options.where((unit) => unit.key == chosen).firstOrNull?.name;
  if (chosen == newFranchise) {
    name = await askText(
      context,
      title: 'Новая франшиза',
      confirmLabel: 'Создать',
      initial: item.anime.title,
    );
    if (name == null) return;
    key = await repository.createCustom(name);
  }
  final undo = await repository.setOverride(item.anime.id, key);
  ref
      .read(toastProvider.notifier)
      .show('«${item.anime.title}» перенесён во франшизу «$name»', undo: undo);
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    required this.posterUrl,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String? posterUrl;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      hoverColor: AppColors.menuItemHover,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: Poster(
                url: posterUrl,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Пункты меню франшизы тайтла.
List<({String label, IconData icon, VoidCallback onPressed})>
franchiseMenuActions(BuildContext context, WidgetRef ref, LibraryItem item) {
  final key = franchiseKeyOf(item.entry, item.anime);
  final shikimoriKey = item.anime.franchise;
  return [
    if (key != null)
      (
        label: 'Вынести из франшизы',
        icon: LucideIcons.unlink,
        onPressed: () => removeFromFranchise(ref, item),
      ),
    (
      label: 'Перенести во франшизу…',
      icon: LucideIcons.arrowRightLeft,
      onPressed: () => moveToFranchise(context, ref, item),
    ),
    if (item.entry.franchiseOverride != null &&
        shikimoriKey != null &&
        shikimoriKey.isNotEmpty)
      (
        label: 'Вернуть во франшизу Shikimori',
        icon: LucideIcons.rotateCcw,
        onPressed: () => resetFranchise(ref, item),
      ),
  ];
}

/// План очереди «Смотреть по порядку».
List<QueuePlanItem> queuePlan(List<FranchisePart> main) {
  final watchable = [
    for (final part in main)
      if (part.anime.release.availableEpisodes > 0) part,
  ];
  final rewatch = isRewatch(watchable);
  return [
    for (final part in watchable)
      QueuePlanItem(
        anime: part.anime.toInfo(),
        inLibrary: part.item != null,
        mode: rewatch ? 'restart' : 'continue',
        done: !rewatch && part.item?.status == WatchStatus.completed,
      ),
  ];
}

/// Все части просмотрены.
bool isRewatch(List<FranchisePart> parts) =>
    parts.isNotEmpty &&
    parts.every((part) => part.item?.status == WatchStatus.completed);

Future<void> startQueue(
  WidgetRef ref, {
  required String key,
  required List<QueuePlanItem> plan,
}) async {
  final toast = ref.read(toastProvider.notifier);
  try {
    final undo = await ref.read(queueRepositoryProvider).start(key, plan);
    final first = plan.where((part) => !part.done).firstOrNull;
    toast.show(
      first == null
          ? 'Все части уже досмотрены'
          : 'Очередь из ${plan.length} '
                '${plural(plan.length, 'части', 'частей', 'частей')} · '
                'сейчас «${first.anime.title}»',
      undo: undo,
    );
  } catch (error) {
    toast.show('Не удалось начать очередь: $error');
  }
}

Future<void> stopQueue(WidgetRef ref, {required String key}) async {
  final undo = await ref.read(queueRepositoryProvider).stop(key);
  ref
      .read(toastProvider.notifier)
      .show('Очередь остановлена, просмотры сохранены', undo: undo);
}

/// Убирает франшизу из библиотеки.
Future<void> removeFranchise(
  BuildContext context,
  WidgetRef ref, {
  required String name,
  required List<Anime> parts,
}) async {
  final confirmed = await confirmAction(
    context,
    title: 'Убрать франшизу',
    message:
        'Из библиотеки уберутся все части «$name»: '
        '${parts.length} ${plural(parts.length, 'тайтл', 'тайтла', 'тайтлов')}. '
        'История просмотров сохранится.',
    confirmLabel: 'Убрать',
  );
  if (!confirmed) return;
  final toast = ref.read(toastProvider.notifier);
  try {
    final change = await ref.read(libraryRepositoryProvider).removeMany([
      for (final anime in parts) anime.id,
    ]);
    toast.show('Франшиза «$name» убрана из библиотеки', undo: change.undo);
  } catch (error) {
    toast.show('Не удалось убрать франшизу: $error');
  }
}
