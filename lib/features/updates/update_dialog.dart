import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../system/desktop.dart';
import '../../system/updates.dart';

Future<void> showUpdateDialog(BuildContext context, List<AppRelease> releases) {
  return showDialog<void>(
    context: context,
    builder: (_) => UpdateDialog(releases: releases),
  );
}

class UpdateDialog extends ConsumerStatefulWidget {
  const UpdateDialog({super.key, required this.releases});

  final List<AppRelease> releases;

  @override
  ConsumerState<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends ConsumerState<UpdateDialog> {
  int _page = 0;

  double? _progress;
  String? _error;

  Future<void> _install() async {
    setState(() {
      _progress = 0;
      _error = null;
    });
    try {
      await ref
          .read(updatesProvider.notifier)
          .install(
            widget.releases.first,
            onProgress: (value) {
              if (mounted) setState(() => _progress = value);
            },
          );
      await ref.read(desktopControllerProvider).quit();
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _progress = null;
        _error = 'Не удалось скачать обновление: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final releases = widget.releases;
    final release = releases[_page];
    final latest = releases.first;
    final progress = _progress;

    return Dialog(
      child: SizedBox(
        width: 500,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'v${release.version}',
                      style: Theme.of(context).dialogTheme.titleTextStyle,
                    ),
                  ),
                  if (releases.length > 1) ...[
                    IconButton(
                      tooltip: 'Новее',
                      onPressed: _page == 0
                          ? null
                          : () => setState(() => _page--),
                      icon: const Icon(LucideIcons.chevronLeft, size: 18),
                    ),
                    Text(
                      '${_page + 1} из ${releases.length}',
                      style: const TextStyle(color: AppColors.muted),
                    ),
                    IconButton(
                      tooltip: 'Старее',
                      onPressed: _page == releases.length - 1
                          ? null
                          : () => setState(() => _page++),
                      icon: const Icon(LucideIcons.chevronRight, size: 18),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 360),
                  child: SingleChildScrollView(
                    child: _Notes(notes: release.notes),
                  ),
                ),
              ),
              if (progress != null) ...[
                const SizedBox(height: 18),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress == 0 ? null : progress,
                    minHeight: 4,
                    color: AppColors.update,
                    backgroundColor: AppColors.track,
                  ),
                ),
              ],
              if (_error case final error?) ...[
                const SizedBox(height: 14),
                Text(
                  error,
                  style: const TextStyle(color: AppColors.dangerText),
                ),
              ],
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Позже'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    style: AppTheme.updateButton,
                    autofocus: true,
                    onPressed: progress == null ? _install : null,
                    icon: const Icon(LucideIcons.circleFadingArrowUp),
                    label: Text(
                      progress == null
                          ? 'Установить ${latest.version}'
                          : progress == 0
                          ? 'Загрузка'
                          : 'Загрузка ${(progress * 100).floor()}%',
                    ),
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

class _Notes extends StatelessWidget {
  const _Notes({required this.notes});

  final List<ReleaseNote> notes;

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return const Text(
        'Описания нет.',
        style: TextStyle(color: AppColors.muted),
      );
    }
    const style = TextStyle(color: AppColors.textSecondary, height: 1.45);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final note in notes)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: note.bullet
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(width: 18, child: Text('•', style: style)),
                      Expanded(child: Text(note.text, style: style)),
                    ],
                  )
                : Text(note.text, style: style),
          ),
      ],
    );
  }
}
