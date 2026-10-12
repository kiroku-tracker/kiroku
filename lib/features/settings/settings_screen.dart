import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../core/toast.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/panel.dart';
import '../../core/widgets/select_button.dart';
import '../../data/database/settings_repository.dart';
import '../../data/providers.dart';
import '../../system/autostart.dart';
import '../../system/updates.dart';
import '../autotrack/auto_marker.dart';
import '../import/shikimori_import.dart';
import '../notifications/release_watcher.dart';
import '../updates/update_dialog.dart';
import 'data_transfer.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool? _autostart;
  bool _checking = false;
  bool _checkingUpdates = false;

  @override
  void initState() {
    super.initState();
    if (Platform.isWindows &&
        !Platform.environment.containsKey('FLUTTER_TEST')) {
      try {
        _autostart = Autostart.isEnabled();
      } catch (_) {
        _autostart = null;
      }
    }
  }

  void _setAutostart(bool value) {
    try {
      Autostart.setEnabled(value);
      setState(() => _autostart = value);
    } catch (error) {
      ref
          .read(toastProvider.notifier)
          .show('Не удалось изменить автозапуск: $error');
    }
  }

  Future<void> _checkNow() async {
    setState(() => _checking = true);
    final events = await ref.read(releaseWatcherProvider).check();
    if (!mounted) return;
    setState(() => _checking = false);
    ref
        .read(toastProvider.notifier)
        .show(
          events.isEmpty
              ? 'Новых серий нет'
              : 'Новое: ${events.length}. Подробности в уведомлениях',
        );
  }

  Future<void> _checkUpdatesNow() async {
    setState(() => _checkingUpdates = true);
    final toast = ref.read(toastProvider.notifier);
    try {
      final releases = await ref.read(updatesProvider.notifier).check();
      if (!mounted) return;
      if (releases.isEmpty) {
        toast.show('Установлена последняя версия');
      } else {
        await showUpdateDialog(context, releases);
      }
    } on Object catch (error) {
      toast.show('Не удалось проверить обновления: $error');
    } finally {
      if (mounted) setState(() => _checkingUpdates = false);
    }
  }

  /// Включает или выключает проверку обновлений.
  Future<void> _setCheckUpdates(bool value) async {
    if (!value) {
      final confirmed = await confirmAction(
        context,
        title: 'Не проверять обновления?',
        message:
            'Kiroku не сообщит о новых версиях, в том числе с '
            'исправлениями ошибок. Проверить можно будет только вручную, '
            'кнопкой «Проверить сейчас».',
        confirmLabel: 'Не проверять',
      );
      if (!confirmed) return;
    }
    await ref
        .read(appPrefsProvider.notifier)
        .change((prefs) => prefs.copyWith(checkUpdates: value));
    await ref.read(updatesProvider.notifier).checkIfEnabled();
  }

  @override
  Widget build(BuildContext context) {
    final version = ref.watch(appVersionProvider).value;
    final prefs = ref.watch(appPrefsProvider).value ?? const AppPrefs();
    void change(AppPrefs Function(AppPrefs) edit) =>
        ref.read(appPrefsProvider.notifier).change(edit);

    return SingleChildScrollView(
      padding: pagePadding(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Настройки',
            trailing: version == null
                ? null
                : Text(
                    'Версия $version',
                    style: TextStyle(
                      color: AppColors.muted.withValues(alpha: 0.6),
                      fontSize: 13,
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          Panel(
            title: 'Уведомления',
            trailing: OutlinedButton.icon(
              onPressed: _checking ? null : _checkNow,
              icon: _checking
                  ? const SizedBox.square(
                      dimension: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(LucideIcons.refreshCw),
              label: const Text('Проверить сейчас'),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SettingRow(
                  title: 'Новые серии',
                  text: 'Для «Смотрю» и «Хочу посмотреть». Проверка раз в час.',
                  value: prefs.notifyEpisodes,
                  onChanged: (value) =>
                      change((prefs) => prefs.copyWith(notifyEpisodes: value)),
                ),
                _ChoiceRow(
                  title: 'Когда сообщать о серии',
                  text:
                      'Для тайтлов, у которых озвучка не известна. Озвучка '
                      'запоминается при просмотре или выбирается кнопкой с '
                      'колокольчиком на странице тайтла.',
                  enabled: prefs.notifyEpisodes,
                  control: SelectButton<EpisodeAlert>(
                    icon: LucideIcons.bellRing,
                    tooltip: 'Когда сообщать о серии',
                    value: prefs.episodeAlert,
                    options: EpisodeAlert.values,
                    labelOf: (alert) => alert.label,
                    onChanged: (alert) =>
                        change((prefs) => prefs.copyWith(episodeAlert: alert)),
                  ),
                ),
                _SettingRow(
                  title: 'Новые части франшиз',
                  text: 'Анонс или выход нового сезона.',
                  value: prefs.notifyFranchises,
                  onChanged: (value) => change(
                    (prefs) => prefs.copyWith(notifyFranchises: value),
                  ),
                ),
                const _Note(
                  'Уведомления одного тайтла выключаются кнопкой с '
                  'колокольчиком на его странице.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Panel(
            title: 'Автоотметка серий',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SettingRow(
                  title: 'Отмечать серии самостоятельно',
                  text:
                      'Досмотренная серия на YummyAnime отмечается сама. '
                      'Нужна активная вкладка в Chrome, Edge, Яндекс, Opera '
                      'или Vivaldi.',
                  value: prefs.autoMark,
                  onChanged: (value) =>
                      change((prefs) => prefs.copyWith(autoMark: value)),
                ),
                _SettingRow(
                  title: 'Добавлять тайтл в начале просмотра',
                  text:
                      'Если его нет в библиотеке: сразу в «Смотрю». Иначе '
                      'Kiroku спросит, когда серия досмотрена.',
                  value: prefs.autoAdd,
                  enabled: prefs.autoMark,
                  onChanged: (value) =>
                      change((prefs) => prefs.copyWith(autoAdd: value)),
                ),
                _ChoiceRow(
                  title: 'Порог просмотра',
                  text:
                      'Когда серия считается досмотренной. Титры обычно '
                      'занимают 5–10%.',
                  enabled: prefs.autoMark,
                  control: SelectButton<int>(
                    icon: LucideIcons.gauge,
                    tooltip: 'Порог просмотра',
                    value: prefs.autoMarkThreshold,
                    options: const [70, 75, 80, 85, 90, 95],
                    labelOf: (value) => '$value%',
                    onChanged: (value) => change(
                      (prefs) => prefs.copyWith(autoMarkThreshold: value),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Opacity(
                  opacity: prefs.autoMark ? 1 : 0.45,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _NowPlayingLine(threshold: prefs.autoMarkThreshold),
                      const _Note(
                        'Если серия не распознана, Kiroku спросит в '
                        'уведомлении.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Panel(
            title: 'Библиотека',
            child: _SettingRow(
              title: 'Блок «Продолжить просмотр»',
              text: 'Тайтлы с непросмотренными сериями над вкладками.',
              value: prefs.showContinue,
              onChanged: (value) =>
                  change((prefs) => prefs.copyWith(showContinue: value)),
            ),
          ),
          const SizedBox(height: 18),
          Panel(
            title: 'Просмотр',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ChoiceRow(
                  title: 'Сайт для просмотра',
                  text: 'Его открывает «Смотреть». Своя ссылка тайтла важнее.',
                  control: SelectButton<String>(
                    icon: LucideIcons.globe,
                    tooltip: 'Сайт для просмотра',
                    value: 'YummyAnime',
                    options: const ['YummyAnime'],
                    labelOf: (site) => site,
                    onChanged: (_) {},
                  ),
                ),
                _ChoiceRow(
                  title: 'Дизайн YummyAnime',
                  text: prefs.yummyHost == null
                      ? 'Пока новый. Выберется сам при первом просмотре.'
                      : 'Тайтлы открываются на '
                            '${prefs.effectiveYummyHost.domain}.',
                  control: SelectButton<YummyHost>(
                    icon: LucideIcons.layoutTemplate,
                    tooltip: 'Дизайн YummyAnime',
                    value: prefs.effectiveYummyHost,
                    options: YummyHost.values,
                    labelOf: (host) => host.label,
                    onChanged: (host) =>
                        change((prefs) => prefs.copyWith(yummyHost: host)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Panel(
            title: 'Данные',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ChoiceRow(
                  title: 'Импорт из Shikimori',
                  text:
                      'Статусы, прогресс, оценки и заметки. По нику, без '
                      'входа в аккаунт.',
                  control: OutlinedButton.icon(
                    onPressed: () => showShikimoriImportDialog(context),
                    icon: const Icon(LucideIcons.download),
                    label: const Text('Импортировать…'),
                  ),
                ),
                _ChoiceRow(
                  title: 'Резервные копии',
                  text:
                      'Раз в день при запуске. Можно вернуть данные на '
                      'дату копии.',
                  control: OutlinedButton.icon(
                    onPressed: () => showBackupsDialog(context),
                    icon: const Icon(LucideIcons.archiveRestore),
                    label: const Text('Копии…'),
                  ),
                ),
                _ChoiceRow(
                  title: 'Перенос данных',
                  text:
                      'Библиотека, история и настройки одним файлом. '
                      'Загрузка заменяет текущие данные.',
                  control: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => exportData(ref),
                        icon: const Icon(LucideIcons.fileDown),
                        label: const Text('Сохранить…'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () => importData(context, ref),
                        icon: const Icon(LucideIcons.fileUp),
                        label: const Text('Загрузить…'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Panel(
            title: 'Запуск и трей',
            child: Column(
              children: [
                if (_autostart != null)
                  _SettingRow(
                    title: 'Запускать вместе с Windows',
                    text: 'Сразу в трей, без окна.',
                    value: _autostart!,
                    onChanged: _setAutostart,
                  ),
                _SettingRow(
                  title: 'Сворачивать в трей при закрытии',
                  text: 'Выход: правый клик по значку в трее.',
                  value: prefs.closeToTray,
                  onChanged: (value) =>
                      change((prefs) => prefs.copyWith(closeToTray: value)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Panel(
            title: 'Обновления',
            trailing: OutlinedButton.icon(
              onPressed: _checkingUpdates ? null : _checkUpdatesNow,
              icon: _checkingUpdates
                  ? const SizedBox.square(
                      dimension: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(LucideIcons.refreshCw),
              label: const Text('Проверить сейчас'),
            ),
            child: _SettingRow(
              title: 'Проверять обновления',
              text: 'О новой версии сообщит синяя кнопка в боковом меню.',
              value: prefs.checkUpdates,
              onChanged: _setCheckUpdates,
            ),
          ),
        ],
      ),
    );
  }
}

/// Пояснение под строками панели.
class _Note extends StatelessWidget {
  const _Note(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 0),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.muted, fontSize: 13),
      ),
    );
  }
}

/// Строка настройки с переключателем.
class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.title,
    required this.text,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final String title;
  final String text;
  final bool value;
  final ValueChanged<bool> onChanged;

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return IgnorePointer(child: Opacity(opacity: 0.45, child: _row()));
    }
    return _row();
  }

  Widget _row() {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(10),
      hoverColor: AppColors.cardHover,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    text,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

/// Что сейчас играет.
class _NowPlayingLine extends ConsumerWidget {
  const _NowPlayingLine({required this.threshold});

  final int threshold;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(nowPlayingProvider);
    final String text;
    if (now == null) {
      text = 'Сейчас на YummyAnime ничего не играет.';
    } else {
      final percent = (now.ratio * 100).floor();
      text = [
        'Сейчас: «${now.title}»',
        now.episode == null ? 'серия не определена' : 'серия ${now.episode}',
        '$percent%${now.playing ? '' : ', пауза'}',
        percent >= threshold ? 'досмотрена' : 'отметится на $threshold%',
      ].join(' · ');
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.panelBorder),
      ),
      child: Row(
        children: [
          Icon(
            now == null ? LucideIcons.monitorPause : LucideIcons.monitorPlay,
            size: 16,
            color: now == null ? AppColors.muted : AppColors.accentText,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: now == null ? AppColors.muted : AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Строка настройки с выбором.
class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    required this.title,
    required this.text,
    required this.control,
    this.enabled = true,
  });

  final String title;
  final String text;
  final Widget control;

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  text,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          control,
        ],
      ),
    );
    if (enabled) return row;
    return IgnorePointer(child: Opacity(opacity: 0.45, child: row));
  }
}
