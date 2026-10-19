import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app_section.dart';
import '../../core/labels.dart';
import '../../core/theme/app_colors.dart';
import '../../core/toast.dart';
import '../../core/widgets/poster.dart';
import '../../data/database/app_database.dart';
import '../../data/database/settings_repository.dart';
import '../../data/database/watch_status.dart';
import '../../data/providers.dart';
import '../../system/autostart.dart';
import '../import/shikimori_import.dart';
import 'welcome_state.dart';

/// Окно «Знакомство с Kiroku»; [onlyNew] показывает только шаги, которые
/// появились после прошлого знакомства.
Future<void> showWelcome(BuildContext context, {bool onlyNew = false}) =>
    showDialog<void>(
      context: context,
      builder: (_) => WelcomeDialog(onlyNew: onlyNew),
    );

class WelcomeDialog extends ConsumerStatefulWidget {
  const WelcomeDialog({super.key, this.onlyNew = false});

  final bool onlyNew;

  @override
  ConsumerState<WelcomeDialog> createState() => _WelcomeDialogState();
}

class _WelcomeDialogState extends ConsumerState<WelcomeDialog> {
  late final List<WelcomeStep> _steps = widget.onlyNew
      ? newWelcomeSteps(ref.read(welcomeProvider).value?.seen ?? const {})
      : WelcomeStep.values;
  late int _index = _firstUnfinished();

  @override
  void initState() {
    super.initState();
    ref.read(welcomeProvider.notifier).markSeen(_steps);
  }

  /// Первый непройденный шаг: знакомство продолжается с него.
  int _firstUnfinished() {
    final progress = ref.read(welcomeProvider).value;
    if (progress == null || widget.onlyNew) return 0;
    final owned = ref.read(libraryItemsProvider).value?.length ?? 0;
    final index = _steps.indexWhere(
      (step) => !welcomeStepDone(step, progress, owned: owned),
    );
    return index < 0 ? 0 : index;
  }

  WelcomeStep get _step => _steps[_index];

  Future<void> _next() async {
    await ref.read(welcomeProvider.notifier).markDone(_step);
    if (!mounted) return;
    if (_index == _steps.length - 1) {
      Navigator.of(context).pop();
    } else {
      setState(() => _index++);
    }
  }

  /// Закрывает окно и открывает раздел; вернуться можно по значку в меню.
  Future<void> _open(AppSection section) async {
    final container = ProviderScope.containerOf(context, listen: false);
    final welcome = ref.read(welcomeProvider.notifier);
    final toast = ref.read(toastProvider.notifier);
    final owned = ref.read(libraryItemsProvider).value?.length ?? 0;
    Navigator.of(context).pop();
    ref.read(appSectionProvider.notifier).open(section);
    await welcome.markDone(_step);
    final progress = await container.read(welcomeProvider.future);
    if (welcomeUnfinished(progress, owned: owned)) {
      toast.show('Знакомство продолжится по значку в меню слева');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_steps.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
      return const SizedBox.shrink();
    }
    final progress = ref.watch(welcomeProvider).value;
    final owned = ref.watch(libraryItemsProvider).value?.length ?? 0;
    bool done(WelcomeStep step) =>
        progress != null && welcomeStepDone(step, progress, owned: owned);
    final last = _index == _steps.length - 1;

    return Dialog(
      insetPadding: const EdgeInsets.all(32),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 880, maxHeight: 600),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 280,
              child: _StepList(
                onlyNew: widget.onlyNew,
                steps: _steps,
                current: _index,
                done: done,
                onSelect: (index) => setState(() => _index = index),
              ),
            ),
            const VerticalDivider(
              width: 1,
              thickness: 1,
              color: AppColors.panelBorder,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 8, 0),
                      child: IconButton(
                        tooltip: 'Закрыть',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(LucideIcons.x, size: 18),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(32, 0, 32, 16),
                      child: switch (_step) {
                        WelcomeStep.intro => const _IntroStep(),
                        WelcomeStep.library => _LibraryStep(
                          owned: owned,
                          onSearch: () {
                            _open(AppSection.search);
                            ref.read(searchFocusProvider.notifier).request();
                          },
                        ),
                        WelcomeStep.posters => const _PostersStep(),
                        WelcomeStep.watch => const _WatchStep(),
                        WelcomeStep.episodes => const _EpisodesStep(),
                        WelcomeStep.discover => _DiscoverStep(
                          onOpen: () => _open(AppSection.discover),
                        ),
                        WelcomeStep.party => _PartyStep(
                          onOpen: () => _open(AppSection.party),
                        ),
                        WelcomeStep.discord => const _DiscordStep(),
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                    child: Row(
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Позже'),
                        ),
                        const Spacer(),
                        if (_index > 0) ...[
                          OutlinedButton(
                            onPressed: () => setState(() => _index--),
                            child: const Text('Назад'),
                          ),
                          const SizedBox(width: 8),
                        ],
                        FilledButton(
                          onPressed: _next,
                          child: Text(last ? 'Готово' : 'Дальше'),
                        ),
                      ],
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

/// Список шагов слева.
class _StepList extends StatelessWidget {
  const _StepList({
    required this.onlyNew,
    required this.steps,
    required this.current,
    required this.done,
    required this.onSelect,
  });

  final bool onlyNew;
  final List<WelcomeStep> steps;
  final int current;
  final bool Function(WelcomeStep step) done;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final finished = steps.where(done).length;
    return ColoredBox(
      color: AppColors.panel,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                onlyNew ? 'Новое в Kiroku' : 'Знакомство с Kiroku',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                onlyNew
                    ? 'Появилось после прошлого знакомства'
                    : 'Пара минут, и Kiroku готов',
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (final (index, step) in steps.indexed)
                      _StepRow(
                        step: step,
                        active: index == current,
                        done: done(step),
                        onTap: () => onSelect(index),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Пройдено $finished из ${steps.length}',
                style: const TextStyle(color: AppColors.muted, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.step,
    required this.active,
    required this.done,
    required this.onTap,
  });

  final WelcomeStep step;
  final bool active;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: active ? AppColors.navActive : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(9),
          hoverColor: AppColors.menuItemHover,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
            child: Row(
              children: [
                Icon(
                  done ? LucideIcons.circleCheck : step.icon,
                  size: 18,
                  color: done
                      ? AppColors.successText
                      : active
                      ? Colors.white
                      : AppColors.navIdle,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    step.title,
                    style: TextStyle(
                      color: active ? Colors.white : AppColors.textSecondary,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                if (step.optional)
                  const Text(
                    'по желанию',
                    style: TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Заголовок и пояснение шага.
class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 15,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 22),
      ],
    );
  }
}

class _IntroStep extends StatelessWidget {
  const _IntroStep();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepHeader(
          title: 'Привет! Это Kiroku',
          text:
              'Аниме много, а память одна. Что уже смотрел, на какой серии '
              'остановился, вышел ли новый сезон: Kiroku помнит это за тебя',
        ),
        const _Choices(
          children: [
            _Feature(
              icon: LucideIcons.library,
              title: 'Помнит всё',
              text: 'Просмотренное, начатое и отложенное, с оценками',
            ),
            _Feature(
              icon: LucideIcons.checkCheck,
              title: 'Сам отмечает серии',
              text: 'Досмотрел серию, и она уже отмечена',
            ),
            _Feature(
              icon: LucideIcons.bell,
              title: 'Напоминает о новом',
              text: 'Новая серия, сезон или анонс не пройдут мимо',
            ),
            _Feature(
              icon: LucideIcons.compass,
              title: 'Подсказывает, что дальше',
              text: 'Продолжения франшиз и похожие тайтлы',
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Как пользоваться',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        for (final (index, text) in const [
          'Найди тайтл в поиске или перенеси свой список с Shikimori',
          'Жми «Смотреть»: серия откроется сразу в нужной озвучке',
          'Дальше Kiroku сам ведёт прогресс и сообщает о новых сериях',
        ].indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.navActive,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: AppColors.accentText,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(text)),
              ],
            ),
          ),
      ],
    );
  }
}

/// Плитка «что умеет Kiroku».
class _Feature extends StatelessWidget {
  const _Feature({required this.icon, required this.title, required this.text});

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.panelBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.accentText),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LibraryStep extends StatelessWidget {
  const _LibraryStep({required this.owned, required this.onSearch});

  final int owned;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepHeader(
          title: 'Перенести свои аниме',
          text:
              'В библиотеке Kiroku всё просмотренное, начатое и отложенное '
              'на потом. Список с Shikimori переносится по нику, без входа',
        ),
        if (owned > 0) ...[
          Row(
            children: [
              const Icon(
                LucideIcons.circleCheck,
                size: 18,
                color: AppColors.successText,
              ),
              const SizedBox(width: 8),
              Text(
                'В библиотеке уже $owned '
                '${plural(owned, 'тайтл', 'тайтла', 'тайтлов')}',
              ),
            ],
          ),
          const SizedBox(height: 18),
        ],
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            FilledButton.icon(
              onPressed: () => showShikimoriImportDialog(context),
              icon: const Icon(LucideIcons.download),
              label: const Text('Перенести с Shikimori'),
            ),
            OutlinedButton.icon(
              onPressed: onSearch,
              icon: const Icon(LucideIcons.search),
              label: const Text('Найти в поиске'),
            ),
          ],
        ),
      ],
    );
  }
}

class _PostersStep extends ConsumerWidget {
  const _PostersStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final originals =
        ref.watch(appPrefsProvider).value?.posterOriginals ?? false;
    void choose(bool value) => ref
        .read(appPrefsProvider.notifier)
        .change((prefs) => prefs.copyWith(posterOriginals: value));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepHeader(
          title: 'Чёткие постеры',
          text:
              'Постеры бывают обычные и в полном размере. Разница заметна '
              'на крупных карточках и большом мониторе',
        ),
        _Choices(
          children: [
            _ChoiceCard(
              title: 'Обычные',
              text: 'Загружаются быстрее',
              selected: !originals,
              onTap: () => choose(false),
            ),
            _ChoiceCard(
              title: 'В полном размере',
              text: 'Чётче, но первая загрузка дольше',
              selected: originals,
              onTap: () => choose(true),
            ),
          ],
        ),
      ],
    );
  }
}

class _WatchStep extends ConsumerWidget {
  const _WatchStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inApp = ref.watch(appPrefsProvider).value?.watchInApp ?? true;
    void choose(bool value) => ref
        .read(appPrefsProvider.notifier)
        .change((prefs) => prefs.copyWith(watchInApp: value));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepHeader(
          title: 'Где смотреть серии',
          text:
              'Kiroku открывает серии с YummyAnime в своём окне и сам '
              'отмечает досмотренные',
        ),
        _Choices(
          children: [
            _ChoiceCard(
              title: 'В Kiroku (рекомендуется)',
              text: 'Серия отмечается сама, перевод запоминается',
              selected: inApp,
              onTap: () => choose(true),
            ),
            _ChoiceCard(
              title: 'В браузере',
              text: 'Отметка работает в Chrome, Edge, Яндекс, Opera и Vivaldi',
              selected: !inApp,
              onTap: () => choose(false),
            ),
          ],
        ),
      ],
    );
  }
}

class _EpisodesStep extends ConsumerStatefulWidget {
  const _EpisodesStep();

  @override
  ConsumerState<_EpisodesStep> createState() => _EpisodesStepState();
}

class _EpisodesStepState extends ConsumerState<_EpisodesStep> {
  bool? _autostart;

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

  @override
  Widget build(BuildContext context) {
    final mode =
        ref.watch(appPrefsProvider).value?.alertPlanned ??
        EpisodeAlertMode.episodes;
    final planned = ref
        .watch(libraryItemsProvider)
        .value
        ?.where((item) => item.status == WatchStatus.planned)
        .firstOrNull;
    final example = planned?.anime.title ?? 'Название аниме';
    void choose(EpisodeAlertMode value) => ref
        .read(appPrefsProvider.notifier)
        .change((prefs) => prefs.copyWith(alertPlanned: value));
    final preview = switch (mode) {
      EpisodeAlertMode.off => null,
      EpisodeAlertMode.premiere => (
        title: 'Премьера: вышла 1-я серия',
        body: '«$example»',
      ),
      EpisodeAlertMode.episodes => (
        title: 'Вышла 8-я серия',
        body: '«$example»',
      ),
      EpisodeAlertMode.finished => (
        title: 'Вышли все серии',
        body: '«$example» · 12 серий',
      ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepHeader(
          title: 'Не пропустить новые серии',
          text:
              'Kiroku сам проверяет выход серий. По тайтлам из «Смотрю» '
              'приходит уведомление о каждой серии',
        ),
        const Text(
          'Для «Хочу посмотреть»',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        _Choices(
          children: [
            _ChoiceCard(
              title: 'О премьере',
              text: 'Одно уведомление, когда выйдет 1-я серия',
              selected: mode == EpisodeAlertMode.premiere,
              onTap: () => choose(EpisodeAlertMode.premiere),
            ),
            _ChoiceCard(
              title: 'О каждой серии',
              text: 'Как для «Смотрю»',
              selected: mode == EpisodeAlertMode.episodes,
              onTap: () => choose(EpisodeAlertMode.episodes),
            ),
            _ChoiceCard(
              title: 'Когда выйдут все серии',
              text: 'Чтобы смотреть подряд',
              selected: mode == EpisodeAlertMode.finished,
              onTap: () => choose(EpisodeAlertMode.finished),
            ),
            _ChoiceCard(
              title: 'Не уведомлять',
              text: 'Отдельный тайтл включается колокольчиком',
              selected: mode == EpisodeAlertMode.off,
              onTap: () => choose(EpisodeAlertMode.off),
            ),
          ],
        ),
        if (preview != null) ...[
          const SizedBox(height: 16),
          _NoticePreview(title: preview.title, body: preview.body),
        ],
        if (_autostart case final autostart?) ...[
          const SizedBox(height: 18),
          Row(
            children: [
              Switch(value: autostart, onChanged: _setAutostart),
              const SizedBox(width: 10),
              const Text('Запускать вместе с Windows'),
              const SizedBox(width: 6),
              const _Help(
                'Серии проверяются, пока Kiroku запущен. С автозапуском он '
                'сразу работает в трее',
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _DiscoverStep extends StatelessWidget {
  const _DiscoverStep({required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepHeader(
          title: 'Найти, что посмотреть',
          text:
              'Раздел «Что посмотреть» подбирает продолжения начатых франшиз '
              'и аниме, похожие на понравившиеся',
        ),
        for (final (icon, text) in const [
          (LucideIcons.arrowRight, 'Вправо: в «Хочу посмотреть»'),
          (LucideIcons.arrowLeft, 'Влево: не интересно'),
          (LucideIcons.arrowUp, 'Вверх: уже смотрел'),
          (LucideIcons.arrowDown, 'Вниз: пропустить'),
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.navActive,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: AppColors.accentText),
                ),
                const SizedBox(width: 12),
                Text(text),
              ],
            ),
          ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onOpen,
          icon: const Icon(LucideIcons.compass),
          label: const Text('Открыть «Что посмотреть»'),
        ),
      ],
    );
  }
}

class _PartyStep extends StatelessWidget {
  const _PartyStep({required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepHeader(
          title: 'Смотреть вместе',
          text:
              'В совместном просмотре пауза и перемотка срабатывают у всех '
              'сразу. Друзья заходят в комнату по коду',
        ),
        const Row(
          children: [
            Icon(LucideIcons.network, size: 18, color: AppColors.navIdle),
            SizedBox(width: 10),
            Text('Нужна общая сеть'),
            SizedBox(width: 6),
            _Help(
              'Программа, в которой сидят все участники: Radmin VPN, '
              'Hamachi, ZeroTier или Tailscale',
            ),
          ],
        ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: onOpen,
          icon: const Icon(LucideIcons.users),
          label: const Text('Открыть совместный просмотр'),
        ),
      ],
    );
  }
}

class _DiscordStep extends ConsumerWidget {
  const _DiscordStep();

  /// Пример для пустой библиотеки.
  static const _frieren = (
    title: 'Провожающая в последний путь Фрирен',
    poster:
        'https://shikimori.io/uploads/poster/animes/52991/'
        'main_2x-83b82e9ff64f1b0821239f88ab8651ab.webp',
    episodes: 28,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shown = ref.watch(appPrefsProvider).value?.discord ?? false;
    final items = ref.watch(libraryItemsProvider).value ?? const [];
    final anime =
        (items
                    .where((item) => item.status == WatchStatus.watching)
                    .firstOrNull ??
                items.firstOrNull)
            ?.anime;
    void choose(bool value) => ref
        .read(appPrefsProvider.notifier)
        .change((prefs) => prefs.copyWith(discord: value));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepHeader(
          title: 'Статус в Discord',
          text:
              'Kiroku может показывать друзьям в Discord, что ты сейчас '
              'смотришь',
        ),
        _Choices(
          children: [
            _ChoiceCard(
              title: 'Показывать',
              text: 'Название и серия, пока идёт видео',
              selected: shown,
              onTap: () => choose(true),
            ),
            _ChoiceCard(
              title: 'Не показывать',
              text: 'Друзья не увидят, что ты смотришь',
              selected: !shown,
              onTap: () => choose(false),
            ),
          ],
        ),
        if (shown) ...[
          const SizedBox(height: 16),
          _DiscordPreview(
            title: anime?.title ?? _frieren.title,
            poster: anime == null ? _frieren.poster : anime.posterUrl,
            total: anime?.episodes ?? _frieren.episodes,
          ),
          const SizedBox(height: 14),
          const Text(
            'Отдельный тайтл, франшизу или группу можно скрыть в меню «…» '
            'на их странице',
            style: TextStyle(color: AppColors.muted, fontSize: 13),
          ),
        ],
      ],
    );
  }
}

/// Пример статуса в Discord.
class _DiscordPreview extends StatelessWidget {
  const _DiscordPreview({
    required this.title,
    required this.poster,
    required this.total,
  });

  final String title;
  final String? poster;
  final int total;

  @override
  Widget build(BuildContext context) {
    final episode = total > 0 && total < 8 ? total : 8;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.panelBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Смотрит Kiroku',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                'пример',
                style: TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              SizedBox(
                width: 44,
                child: Poster(
                  url: poster,
                  borderRadius: BorderRadius.circular(6),
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
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      total > 0 ? 'Серия $episode из $total' : 'Серия $episode',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Варианты по два в ряд, одной высоты в ряду.
class _Choices extends StatelessWidget {
  const _Choices({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < children.length; i += 2) ...[
          if (i > 0) const SizedBox(height: 10),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: children[i]),
                const SizedBox(width: 10),
                Expanded(
                  child: i + 1 < children.length
                      ? children[i + 1]
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Вариант выбора карточкой.
class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.title,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12);
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? const Color(0xFF2B2642) : AppColors.panel,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: selected ? AppColors.accent : AppColors.panelBorder,
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          hoverColor: AppColors.menuItemHover,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 80),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          text,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 13,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    selected ? LucideIcons.circleDot : LucideIcons.circle,
                    size: 18,
                    color: selected ? AppColors.accentText : AppColors.muted,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Пример уведомления.
class _NoticePreview extends StatelessWidget {
  const _NoticePreview({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.panelBorder),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.bell, size: 18, color: AppColors.navIdle),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted, fontSize: 13),
                ),
              ],
            ),
          ),
          const Text(
            'пример',
            style: TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// Знак «?» с объяснением при наведении.
class _Help extends StatelessWidget {
  const _Help(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: text,
      waitDuration: const Duration(milliseconds: 200),
      constraints: const BoxConstraints(maxWidth: 320),
      child: const MouseRegion(
        cursor: SystemMouseCursors.help,
        child: Icon(LucideIcons.circleHelp, size: 16, color: AppColors.muted),
      ),
    );
  }
}
