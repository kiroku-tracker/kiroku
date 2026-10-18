import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/toast.dart';
import '../../core/widgets/status_menu.dart';
import '../../data/database/library_repository.dart';
import '../../data/providers.dart';

/// Пункт «⋯» с окном числа просмотров тайтла или всех просмотренных
/// частей франшизы.
Widget viewsMenuItem(
  BuildContext context,
  WidgetRef ref, {
  required Map<int, ({int views, int removable})> parts,
  bool franchise = false,
}) {
  return AppMenuItem(
    label: 'Просмотров: ${viewCount(parts)}…',
    icon: LucideIcons.refreshCw,
    color: AppColors.menuItemText,
    onPressed: () => _ask(context, ref, parts, franchise: franchise),
  );
}

/// Число просмотров тех из [items], что просмотрены хотя бы раз.
Map<int, ({int views, int removable})> viewParts(
  Iterable<LibraryItem> items,
  Map<int, ({int views, int removable})> all,
) => {for (final item in items) item.anime.id: ?all[item.anime.id]};

/// Сколько раз просмотрены все просмотренные части.
int viewCount(Map<int, ({int views, int removable})> parts) =>
    parts.isEmpty ? 0 : parts.values.map((part) => part.views).reduce(_min);

int _min(int a, int b) => a < b ? a : b;
int _max(int a, int b) => a > b ? a : b;

/// Окно с числом просмотров; меньше просмотров с датами не поставить,
/// их убирают в истории просмотров.
Future<void> _ask(
  BuildContext context,
  WidgetRef ref,
  Map<int, ({int views, int removable})> parts, {
  required bool franchise,
}) async {
  final library = ref.read(libraryRepositoryProvider);
  final toast = ref.read(toastProvider.notifier);
  final count = viewCount(parts);
  final minimum = parts.values
      .map((part) => part.views - part.removable)
      .reduce(_max);
  final controller = TextEditingController(text: '$count')
    ..selection = TextSelection(baseOffset: 0, extentOffset: '$count'.length);
  void submit(BuildContext context) =>
      Navigator.of(context).pop(int.tryParse(controller.text.trim()));
  void step(int value) => controller.value = TextEditingValue(
    text: '$value',
    selection: TextSelection.collapsed(offset: '$value'.length),
  );

  final target = await showDialog<int>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(franchise ? 'Просмотры франшизы' : 'Просмотры'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              franchise
                  ? 'Сколько раз просмотрены все уже просмотренные части'
                  : 'Сколько раз тайтл просмотрен целиком',
              style: const TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 14),
            ValueListenableBuilder(
              valueListenable: controller,
              builder: (context, value, _) {
                final current = int.tryParse(value.text.trim()) ?? 0;
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _StepButton(
                        icon: LucideIcons.minus,
                        tooltip: 'Меньше',
                        onPressed: current > minimum
                            ? () => step(current - 1)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: controller,
                          autofocus: true,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                          decoration: const InputDecoration(hintText: '1'),
                          onSubmitted: (_) => submit(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _StepButton(
                        icon: LucideIcons.plus,
                        tooltip: 'Больше',
                        onPressed: current < 999
                            ? () => step(_max(current + 1, minimum))
                            : null,
                      ),
                    ],
                  ),
                );
              },
            ),
            if (minimum > 1) ...[
              const SizedBox(height: 8),
              Text(
                'Не меньше $minimum: просмотры с датами убираются в истории '
                'просмотров',
                style: const TextStyle(color: AppColors.muted, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () => submit(context),
          child: const Text('Сохранить'),
        ),
      ],
    ),
  );
  controller.dispose();
  if (target == null) return;
  final wanted = _max(target, minimum);
  final changes = <LibraryChange>[];
  for (final MapEntry(key: id, value: part) in parts.entries) {
    final diff = wanted - part.views;
    for (var i = 0; i < diff; i++) {
      changes.add(await library.addView(id));
    }
    for (var i = 0; i < _min(-diff, part.removable); i++) {
      changes.add(await library.removeView(id));
    }
  }
  if (changes.isEmpty) return;
  toast.show(
    'Просмотров: $wanted',
    undo: () async {
      for (final change in changes.reversed) {
        await change.undo();
      }
    },
  );
}

/// Кнопка «−» или «+» рядом с полем числа.
class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: 46,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: Size.zero,
            padding: EdgeInsets.zero,
          ),
          onPressed: onPressed,
          child: Icon(icon, size: 18),
        ),
      ),
    );
  }
}
