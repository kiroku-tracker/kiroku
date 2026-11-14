import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/labels.dart';
import '../../core/theme/app_colors.dart';
import '../../core/toast.dart';
import '../../data/anilibria/anilibria_client.dart';
import '../../data/anilibria/anilibria_plan.dart';
import '../../data/database/library_repository.dart' show newId;
import '../../data/import/import_plan.dart';
import '../../data/import/shikimori_plan.dart';
import '../../data/providers.dart';
import '../../data/shikimori/shikimori_client.dart';
import '../notifications/release_watcher.dart';
import 'import_controller.dart';
import 'import_preview.dart';

/// Откуда переносится список.
enum ImportSource {
  shikimori(
    'Shikimori',
    'По нику, без входа. Статусы, серии, оценки и заметки',
  ),
  aniLibria(
    'AniLibria',
    'По коду, без пароля. Коллекции, избранное и просмотренные серии',
  );

  const ImportSource(this.label, this.description);

  final String label;
  final String description;
}

/// Окно импорта: вход, загрузка списка, предпросмотр и перенос.
Future<void> showImportDialog(BuildContext context, ImportSource source) =>
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ImportDialog(source),
    );

const _linkDeviceUrl = 'https://anilibria.top/app/auth/otp/linkDevice';

enum _Step { input, code, loading, preview, importing }

class _ImportDialog extends ConsumerStatefulWidget {
  const _ImportDialog(this.source);

  final ImportSource source;

  @override
  ConsumerState<_ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends ConsumerState<_ImportDialog> {
  final _field = TextEditingController();
  late var _step = widget.source == ImportSource.aniLibria
      ? _Step.code
      : _Step.input;
  String? _error;
  String? _status;
  final _deviceId = newId();
  AniLibriaOtp? _otp;
  Timer? _timer;
  var _secondsLeft = 0;
  var _errors = 0;
  var _expired = false;
  var _polling = false;

  @override
  void initState() {
    super.initState();
    if (widget.source == ImportSource.aniLibria) _requestCode();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _field.dispose();
    super.dispose();
  }

  void _fail(String message) {
    if (!mounted) return;
    setState(() {
      _error = message;
      _step = _Step.input;
    });
  }

  Future<void> _find() async {
    final input = _field.text.trim();
    if (input.isEmpty) return;
    setState(() {
      _step = _Step.loading;
      _error = null;
      _status = 'Поиск пользователя…';
    });
    final shikimori = ref.read(shikimoriClientProvider);
    try {
      final user = await shikimori.findUser(input);
      if (user == null) {
        _fail('Пользователь «${ShikimoriClient.nicknameOf(input)}» не найден.');
        return;
      }
      if (mounted) {
        setState(() => _status = 'Загрузка списка «${user.nickname}»: 0');
      }
      final rates = await shikimori.userRates(
        user.id,
        onProgress: (loaded) {
          if (mounted) {
            setState(
              () => _status = 'Загрузка списка «${user.nickname}»: $loaded',
            );
          }
        },
      );
      if (rates.isEmpty) {
        _fail(
          'Список «${user.nickname}» пуст или скрыт настройками '
          'приватности Shikimori.',
        );
        return;
      }
      await _preview(
        ImportPlan(
          sourceName: widget.source.label,
          userName: user.nickname,
          items: shikimoriItems(rates),
        ),
      );
    } catch (error) {
      _fail('Shikimori не ответил: $error');
    }
  }

  Future<void> _requestCode() async {
    _timer?.cancel();
    setState(() {
      _step = _Step.code;
      _error = null;
      _otp = null;
      _expired = false;
    });
    try {
      final otp = await ref
          .read(aniLibriaClientProvider)
          .requestCode(_deviceId);
      if (!mounted) return;
      setState(() {
        _otp = otp;
        _secondsLeft = otp.lifetime.inSeconds;
        _errors = 0;
      });
      _timer = Timer.periodic(const Duration(seconds: 3), (_) => _poll());
    } on AniLibriaException catch (error) {
      _failCode(error.message);
    } catch (error) {
      _failCode('Не удалось получить код: $error');
    }
  }

  void _failCode(String message) {
    _timer?.cancel();
    if (!mounted) return;
    setState(() {
      _error = message;
      _step = _Step.code;
      _otp = null;
    });
  }

  void _expireIfLate() {
    if (_secondsLeft > 0 || !mounted) return;
    _timer?.cancel();
    setState(() => _expired = true);
  }

  Future<void> _poll() async {
    final otp = _otp;
    if (otp == null) return;
    _secondsLeft -= 3;
    if (_polling) {
      _expireIfLate();
      return;
    }
    _polling = true;
    try {
      final token = await ref
          .read(aniLibriaClientProvider)
          .login(otp.code, _deviceId);
      if (!mounted) return;
      _errors = 0;
      if (token != null) {
        _timer?.cancel();
        await _loadAniLibria(token);
        return;
      }
    } on AniLibriaException catch (error) {
      if (!mounted) return;
      if (++_errors >= 3) {
        _failCode(error.message);
        return;
      }
    } finally {
      _polling = false;
    }
    _expireIfLate();
  }

  Future<void> _loadAniLibria(String token) async {
    setState(() {
      _step = _Step.loading;
      _status = 'Загружаю коллекции…';
    });
    final api = ref.read(aniLibriaClientProvider);
    final shikimori = ref.read(shikimoriClientProvider);
    try {
      final collections = await api.collections(token);
      if (!mounted) return;
      setState(() => _status = 'Загружаю избранное…');
      final favorites = await api.favorites(token);
      if (!mounted) return;
      setState(() => _status = 'Загружаю историю просмотров…');
      final history = await api.history(token);
      if (!mounted) return;
      setState(() => _status = 'Ищу тайтлы на Shikimori…');
      final name = await api.profileName(token);
      final items = await aniLibriaItems(
        collections: collections,
        favorites: favorites,
        history: history,
        lookup: (ids) async => {
          for (final anime in await shikimori.getAnimes(ids)) anime.id: anime,
        },
      );
      if (!mounted) return;
      if (items.isEmpty) {
        _failCode(
          'В аккаунте AniLibria нет ни коллекций, ни избранного, ни '
          'истории просмотров.',
        );
        return;
      }
      await _preview(
        ImportPlan(
          sourceName: widget.source.label,
          userName: name,
          items: items,
        ),
      );
    } on AniLibriaException catch (error) {
      _failCode(
        error.unauthorized
            ? 'AniLibria не приняла вход. Получи новый код.'
            : error.message,
      );
    } catch (error) {
      _failCode('Не удалось загрузить список: $error');
    }
  }

  Future<void> _preview(ImportPlan plan) async {
    await ref.read(importControllerProvider.notifier).start(plan);
    if (mounted) setState(() => _step = _Step.preview);
  }

  Future<void> _import() async {
    final state = ref.read(importControllerProvider);
    if (state == null) return;
    setState(() => _step = _Step.importing);
    final toast = ref.read(toastProvider.notifier);
    try {
      final result = await ref
          .read(libraryRepositoryProvider)
          .importItems(state.selected, replace: true);
      if (!mounted) return;
      Navigator.of(context).pop();
      final done = [
        if (result.added > 0) 'добавлено ${result.added}',
        if (result.replaced > 0) 'заменено ${result.replaced}',
      ];
      toast.show(
        'Импорт из ${widget.source.label}: '
        '${done.isEmpty ? 'ничего не изменилось' : done.join(', ')}',
        undo: result.undo,
      );
      unawaited(ref.read(releaseWatcherProvider).check());
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = 'Не удалось импортировать: $error';
          _step = _Step.preview;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(importControllerProvider);
    final busy = _step == _Step.loading || _step == _Step.importing;
    final aniLibria = widget.source == ImportSource.aniLibria;
    final preview = _step == _Step.preview || _step == _Step.importing;
    final count = state?.toTransfer ?? 0;
    return AlertDialog(
      title: Text('Импорт из ${widget.source.label}'),
      content: SizedBox(
        width: 820,
        child: preview && state != null
            ? _buildPreview(state)
            : aniLibria
            ? (_step == _Step.loading ? _buildLoading() : _buildCode())
            : _buildInput(),
      ),
      actions: [
        TextButton(
          onPressed: _step == _Step.importing
              ? null
              : () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        if (!preview && !aniLibria)
          FilledButton.icon(
            onPressed: busy ? null : _find,
            icon: const Icon(LucideIcons.search),
            label: const Text('Найти список'),
          )
        else if (preview)
          FilledButton.icon(
            onPressed: busy || count == 0 ? null : _import,
            icon: _step == _Step.importing
                ? const SizedBox.square(
                    dimension: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(LucideIcons.download),
            label: Text(count == 0 ? 'Перенести' : 'Перенести $count'),
          ),
      ],
    );
  }

  Widget _buildLoading() => Row(
    children: [
      const SizedBox.square(
        dimension: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      const SizedBox(width: 10),
      Text(_status ?? '', style: const TextStyle(color: AppColors.muted)),
    ],
  );

  Widget _buildCode() {
    final otp = _otp;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Войди в аккаунт на anilibria.top и введи этот код на странице '
          'подключения устройства. Пароль в Kiroku вводить не нужно.',
          style: TextStyle(color: AppColors.muted, height: 1.45),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => launchUrl(
              Uri.parse(_linkDeviceUrl),
              mode: LaunchMode.externalApplication,
            ),
            icon: const Icon(LucideIcons.externalLink, size: 16),
            label: const Text('Открыть страницу'),
          ),
        ),
        const SizedBox(height: 18),
        if (otp != null)
          Center(
            child: SelectableText(
              otp.code,
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                letterSpacing: 6,
              ),
            ),
          ),
        const SizedBox(height: 18),
        if (otp != null && !_expired)
          const Row(
            children: [
              SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 10),
              Text(
                'Жду, пока ты введёшь код',
                style: TextStyle(color: AppColors.muted),
              ),
            ],
          ),
        if (_expired)
          const Text(
            'Код истёк',
            style: TextStyle(color: AppColors.dangerText),
          ),
        if (_error != null)
          Text(_error!, style: const TextStyle(color: AppColors.dangerText)),
        if (_expired || _error != null) ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _requestCode,
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: const Text('Новый код'),
            ),
          ),
        ],
      ],
    );
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
                _status ?? '',
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

  Widget _buildPreview(ImportState state) {
    final total = state.items.length;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Список «${state.plan.userName}»: $total '
          '${plural(total, 'тайтл', 'тайтла', 'тайтлов')}',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        const SizedBox(height: 12),
        const ImportPreview(),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: AppColors.dangerText)),
        ],
      ],
    );
  }
}
