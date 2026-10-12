import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/labels.dart';
import '../../core/theme/app_colors.dart';
import '../../core/toast.dart';
import '../../data/database/watch_status.dart';
import '../../data/providers.dart';
import '../../data/shikimori/shikimori_client.dart';
import '../../data/shikimori/user_rate.dart';
import '../notifications/release_watcher.dart';

/// Окно импорта из Shikimori.
Future<void> showShikimoriImportDialog(BuildContext context) =>
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _ImportDialog(),
    );

enum _Step { input, loading, preview, importing }

class _ImportDialog extends ConsumerStatefulWidget {
  const _ImportDialog();

  @override
  ConsumerState<_ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends ConsumerState<_ImportDialog> {
  final _field = TextEditingController();
  var _step = _Step.input;
  String? _error;
  int _loaded = 0;
  ShikimoriUser? _user;
  List<UserRate> _rates = const [];
  bool _replace = false;

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  Future<void> _find() async {
    final input = _field.text.trim();
    if (input.isEmpty) return;
    setState(() {
      _step = _Step.loading;
      _error = null;
      _loaded = 0;
    });
    final shikimori = ref.read(shikimoriClientProvider);
    try {
      final user = await shikimori.findUser(input);
      if (user == null) {
        _fail('Пользователь «${ShikimoriClient.nicknameOf(input)}» не найден.');
        return;
      }
      if (mounted) setState(() => _user = user);
      final rates = await shikimori.userRates(
        user.id,
        onProgress: (loaded) {
          if (mounted) setState(() => _loaded = loaded);
        },
      );
      if (rates.isEmpty) {
        _fail(
          'Список «${user.nickname}» пуст или скрыт настройками '
          'приватности Shikimori.',
        );
        return;
      }
      if (mounted) {
        setState(() {
          _rates = rates;
          _step = _Step.preview;
        });
      }
    } catch (error) {
      _fail('Shikimori не ответил: $error');
    }
  }

  void _fail(String message) {
    if (!mounted) return;
    setState(() {
      _error = message;
      _step = _Step.input;
    });
  }

  Future<void> _import() async {
    setState(() => _step = _Step.importing);
    final toast = ref.read(toastProvider.notifier);
    try {
      final result = await ref
          .read(libraryRepositoryProvider)
          .importRates(_rates, replace: _replace);
      if (!mounted) return;
      Navigator.of(context).pop();
      toast.show(
        'Импорт из Shikimori: '
        '${[if (result.added > 0) 'добавлено ${result.added}', if (result.replaced > 0) 'заменено ${result.replaced}', if (result.skipped > 0) 'уже были ${result.skipped}'].join(', ')}',
        undo: result.undo,
      );
      unawaited(ref.read(releaseWatcherProvider).check());
    } catch (error) {
      _fail('Не удалось импортировать: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = _step == _Step.loading || _step == _Step.importing;
    return AlertDialog(
      title: const Text('Импорт из Shikimori'),
      content: SizedBox(
        width: 480,
        child: switch (_step) {
          _Step.input || _Step.loading => _buildInput(),
          _Step.preview || _Step.importing => _buildPreview(),
        },
      ),
      actions: [
        TextButton(
          onPressed: busy ? null : () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        if (_step == _Step.input || _step == _Step.loading)
          FilledButton.icon(
            onPressed: busy ? null : _find,
            icon: const Icon(LucideIcons.search),
            label: const Text('Найти список'),
          )
        else
          FilledButton.icon(
            onPressed: busy || _count() == 0 ? null : _import,
            icon: busy
                ? const SizedBox.square(
                    dimension: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(LucideIcons.download),
            label: Text(
              _count() == 0 ? 'Импортировать' : 'Импортировать ${_count()}',
            ),
          ),
      ],
    );
  }

  /// Сколько тайтлов изменится.
  int _count() {
    final owned = ref.read(libraryStatusesProvider).value ?? const {};
    return _replace
        ? _rates.length
        : _rates.where((rate) => !owned.containsKey(rate.anime.id)).length;
  }

  Widget _buildInput() {
    final loading = _step == _Step.loading;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Достаточно ника или ссылки на профиль. Список должен быть '
          'открытым.',
          style: TextStyle(color: AppColors.muted, height: 1.45),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _field,
          autofocus: true,
          enabled: !loading,
          onSubmitted: (_) => _find(),
          decoration: const InputDecoration(
            hintText: 'Ник или ссылка на профиль Shikimori',
            prefixIcon: Icon(LucideIcons.user, size: 18),
          ),
        ),
        if (loading) ...[
          const SizedBox(height: 14),
          Row(
            children: [
              const SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 10),
              Text(
                _user == null
                    ? 'Поиск пользователя…'
                    : 'Загрузка списка «${_user!.nickname}»: $_loaded',
                style: const TextStyle(color: AppColors.muted),
              ),
            ],
          ),
        ],
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: AppColors.dangerText)),
        ],
      ],
    );
  }

  Widget _buildPreview() {
    final owned = ref.watch(libraryStatusesProvider).value ?? const {};
    final byStatus = <WatchStatus, int>{};
    var already = 0;
    for (final rate in _rates) {
      byStatus.update(rate.watchStatus, (n) => n + 1, ifAbsent: () => 1);
      if (owned.containsKey(rate.anime.id)) already++;
    }
    final rewatched = _rates.where((rate) => rate.rewatches > 0).length;
    final scored = _rates.where((rate) => rate.score > 0).length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Список «${_user!.nickname}»: ${_rates.length} '
          '${plural(_rates.length, 'тайтл', 'тайтла', 'тайтлов')}',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        const SizedBox(height: 10),
        for (final status in WatchStatus.values)
          if (byStatus[status] case final count?)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Expanded(child: Text(status.label)),
                  Text(
                    '$count',
                    style: const TextStyle(color: AppColors.muted),
                  ),
                ],
              ),
            ),
        const SizedBox(height: 10),
        Text(
          [
            if (scored > 0) 'с оценкой: $scored',
            if (rewatched > 0) 'пересмотрено: $rewatched',
          ].join(' · '),
          style: const TextStyle(color: AppColors.muted),
        ),
        if (already > 0) ...[
          const SizedBox(height: 14),
          CheckboxListTile(
            value: _replace,
            onChanged: _step == _Step.importing
                ? null
                : (value) => setState(() => _replace = value ?? false),
            title: Text(
              'Заменить данными Shikimori $already '
              '${plural(already, 'тайтл', 'тайтла', 'тайтлов')}, '
              'которые уже есть в Kiroku',
            ),
            subtitle: const Text(
              'Без галочки они останутся как есть. У заменённых удалятся '
              'прежние просмотры.',
            ),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ],
        const SizedBox(height: 8),
        const Text(
          'Серии отметятся без дат: Shikimori их не хранит.',
          style: TextStyle(color: AppColors.muted, fontSize: 13, height: 1.4),
        ),
      ],
    );
  }
}
