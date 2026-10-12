import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';

import '../../core/labels.dart';
import '../../core/theme/app_colors.dart';
import '../../core/toast.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../data/providers.dart';
import '../../system/backups.dart';
import '../../system/desktop.dart';
import '../../system/restart.dart';

const _typeGroup = XTypeGroup(
  label: 'Данные Kiroku',
  extensions: [Backups.extension],
);

String _two(int value) => value.toString().padLeft(2, '0');

/// Сохраняет данные в файл.
Future<void> exportData(WidgetRef ref) async {
  final now = DateTime.now();
  final location = await getSaveLocation(
    acceptedTypeGroups: const [_typeGroup],
    suggestedName:
        'Kiroku ${now.year}-${_two(now.month)}-${_two(now.day)}'
        '.${Backups.extension}',
    confirmButtonText: 'Сохранить',
  );
  if (location == null) return;
  var path = location.path;
  if (p.extension(path).toLowerCase() != '.${Backups.extension}') {
    path = '$path.${Backups.extension}';
  }
  final toast = ref.read(toastProvider.notifier);
  try {
    await Backups.exportTo(ref.read(databaseProvider), path);
    toast.show('Данные сохранены в «${p.basename(path)}»');
  } on Object catch (error) {
    toast.show('Не удалось сохранить: $error');
  }
}

/// Загружает данные из файла.
Future<void> importData(BuildContext context, WidgetRef ref) async {
  final file = await openFile(
    acceptedTypeGroups: const [
      _typeGroup,
      XTypeGroup(label: 'Резервные копии', extensions: ['sqlite']),
    ],
    confirmButtonText: 'Открыть',
  );
  if (file == null || !context.mounted) return;
  await _restore(
    context,
    ref,
    path: file.path,
    title: 'Загрузить данные из файла?',
    source: '«${p.basename(file.path)}»',
  );
}

/// Восстанавливает данные из файла.
Future<void> _restore(
  BuildContext context,
  WidgetRef ref, {
  required String path,
  required String title,
  required String source,
}) async {
  final toast = ref.read(toastProvider.notifier);
  final int titles;
  try {
    titles = Backups.inspect(path);
  } on BackupException catch (error) {
    toast.show(error.message);
    return;
  }
  if (!context.mounted) return;
  final confirmed = await confirmAction(
    context,
    title: title,
    message:
        'Библиотека, история и настройки заменятся данными из $source '
        '($titles ${plural(titles, 'тайтл', 'тайтла', 'тайтлов')}). '
        'Текущие данные сохранятся в резервной копии. Kiroku '
        'перезапустится.',
    confirmLabel: 'Заменить и перезапустить',
  );
  if (!confirmed) return;
  try {
    final backups = await ref.read(backupsProvider.future);
    await backups.prepareRestore(ref.read(databaseProvider), path);
    await Restart.launchNew();
    await ref.read(desktopControllerProvider).quit();
  } on Object catch (error) {
    toast.show('Не удалось восстановить: $error');
  }
}

/// Окно резервных копий.
Future<void> showBackupsDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (_) => const _BackupsDialog(),
  );
}

class _BackupsDialog extends ConsumerStatefulWidget {
  const _BackupsDialog();

  @override
  ConsumerState<_BackupsDialog> createState() => _BackupsDialogState();
}

class _BackupsDialogState extends ConsumerState<_BackupsDialog> {
  List<BackupFile>? _copies;
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final backups = await ref.read(backupsProvider.future);
    final copies = await backups.list();
    if (mounted) setState(() => _copies = copies);
  }

  Future<void> _create() async {
    setState(() => _creating = true);
    try {
      final backups = await ref.read(backupsProvider.future);
      await backups.create(ref.read(databaseProvider), BackupKind.manual);
    } on Object catch (error) {
      ref.read(toastProvider.notifier).show('Не удалось создать копию: $error');
    }
    if (!mounted) return;
    setState(() => _creating = false);
    await _load();
  }

  Future<void> _openFolder() async {
    final backups = await ref.read(backupsProvider.future);
    await backups.folder.create(recursive: true);
    await launchUrl(Uri.file(backups.folder.path));
  }

  @override
  Widget build(BuildContext context) {
    final copies = _copies;
    return Dialog(
      child: SizedBox(
        width: 560,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Резервные копии',
                style: Theme.of(context).dialogTheme.titleTextStyle,
              ),
              const SizedBox(height: 4),
              const Text(
                'Раз в день при запуске. Хранятся последние '
                '${Backups.keep} каждого вида.',
                style: TextStyle(color: AppColors.muted, fontSize: 13),
              ),
              const SizedBox(height: 14),
              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 380),
                  child: copies == null
                      ? const SizedBox(
                          height: 80,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : copies.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'Копий пока нет.',
                            style: TextStyle(color: AppColors.muted),
                          ),
                        )
                      : ListView(
                          shrinkWrap: true,
                          children: [
                            for (final copy in copies)
                              _BackupRow(
                                copy: copy,
                                onRestore: () => _restore(
                                  context,
                                  ref,
                                  path: copy.file.path,
                                  title: 'Восстановить копию?',
                                  source:
                                      'копии от ${_dateTime(copy.createdAt)}',
                                ),
                              ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: _openFolder,
                    icon: const Icon(LucideIcons.folderOpen, size: 16),
                    label: const Text('Открыть папку'),
                  ),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: _creating ? null : _create,
                    icon: const Icon(LucideIcons.databaseBackup),
                    label: const Text('Создать копию'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Готово'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _dateTime(DateTime time) =>
    '${_two(time.day)}.${_two(time.month)}.${time.year} '
    '${_two(time.hour)}:${_two(time.minute)}';

class _BackupRow extends StatelessWidget {
  const _BackupRow({required this.copy, required this.onRestore});

  final BackupFile copy;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final titles = copy.titles;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.panelBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _dateTime(copy.createdAt),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  [
                    copy.kind.label,
                    titles == null
                        ? 'не читается'
                        : '$titles ${plural(titles, 'тайтл', 'тайтла', 'тайтлов')}',
                  ].join(' · '),
                  style: const TextStyle(color: AppColors.muted, fontSize: 13),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: titles == null ? null : onRestore,
            icon: const Icon(LucideIcons.archiveRestore),
            label: const Text('Восстановить'),
          ),
        ],
      ),
    );
  }
}
