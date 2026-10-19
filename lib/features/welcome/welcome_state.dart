import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/providers.dart';

/// Шаги знакомства с Kiroku по порядку; новым считается шаг, которого
/// ещё не было в прошлом знакомстве.
enum WelcomeStep {
  intro('Что такое Kiroku', LucideIcons.sparkles),
  library('Свои аниме', LucideIcons.library),
  posters('Постеры', LucideIcons.image),
  watch('Где смотреть', LucideIcons.circlePlay),
  episodes('Новые серии', LucideIcons.bell),
  discover('Что посмотреть', LucideIcons.compass),
  party('Смотреть вместе', LucideIcons.users, optional: true),
  discord('Discord', LucideIcons.gamepad2, optional: true);

  const WelcomeStep(this.title, this.icon, {this.optional = false});

  final String title;
  final IconData icon;

  /// Шаг можно пропустить без потерь.
  final bool optional;
}

/// Какие шаги знакомства уже открывались и какие пройдены.
typedef WelcomeProgress = ({Set<WelcomeStep> seen, Set<WelcomeStep> done});

/// Шаги, которые появились после прошлого знакомства; до первого
/// знакомства список пуст.
List<WelcomeStep> newWelcomeSteps(Set<WelcomeStep> seen) => seen.isEmpty
    ? const []
    : [
        for (final step in WelcomeStep.values)
          if (!seen.contains(step)) step,
      ];

/// Шаг пройден: отмечен или, для библиотеки, в ней уже есть тайтлы.
bool welcomeStepDone(
  WelcomeStep step,
  WelcomeProgress progress, {
  required int owned,
}) =>
    progress.done.contains(step) || (step == WelcomeStep.library && owned > 0);

/// Остались непройденные обязательные шаги.
bool welcomeUnfinished(WelcomeProgress progress, {required int owned}) =>
    WelcomeStep.values.any(
      (step) =>
          !step.optional && !welcomeStepDone(step, progress, owned: owned),
    );

class WelcomeNotifier extends AsyncNotifier<WelcomeProgress> {
  static const _seenKey = 'welcome.seen';
  static const _doneKey = 'welcome.done';

  @override
  Future<WelcomeProgress> build() async {
    final saved = await ref.read(settingsRepositoryProvider).readAll();
    Set<WelcomeStep> read(String key) => {
      for (final name in (saved[key] ?? '').split(','))
        ?WelcomeStep.values.asNameMap()[name],
    };
    return (seen: read(_seenKey), done: read(_doneKey));
  }

  /// Шаги показаны: значок «Новое» о них больше не напоминает.
  Future<void> markSeen(Iterable<WelcomeStep> steps) async {
    final current = await future;
    final seen = {...current.seen, ...steps};
    if (seen.length == current.seen.length) return;
    state = AsyncData((seen: seen, done: current.done));
    await _write(_seenKey, seen);
  }

  /// Шаг пройден: в списке у него галочка.
  Future<void> markDone(WelcomeStep step) async {
    final current = await future;
    if (current.done.contains(step)) return;
    final done = {...current.done, step};
    state = AsyncData((seen: current.seen, done: done));
    await _write(_doneKey, done);
  }

  Future<void> _write(String key, Set<WelcomeStep> steps) => ref
      .read(settingsRepositoryProvider)
      .write(key, [for (final step in steps) step.name].join(','));
}

final welcomeProvider = AsyncNotifierProvider<WelcomeNotifier, WelcomeProgress>(
  WelcomeNotifier.new,
);

/// Разовые подсказки: какие уже прочитаны и какая видна сейчас.
typedef TipsState = ({Set<String> seen, String? active});

class TipsNotifier extends AsyncNotifier<TipsState> {
  static const _key = 'tips.seen';

  @override
  Future<TipsState> build() async {
    final saved = await ref.read(settingsRepositoryProvider).readAll();
    return (
      seen: {
        for (final id in (saved[_key] ?? '').split(','))
          if (id.isNotEmpty) id,
      },
      active: null,
    );
  }

  /// Показывает подсказку, если сейчас не видна другая.
  void request(String id) {
    final current = state.value;
    if (current == null ||
        current.active != null ||
        current.seen.contains(id)) {
      return;
    }
    state = AsyncData((seen: current.seen, active: id));
  }

  /// Убирает подсказку с экрана, не отмечая прочитанной.
  void release(String id) {
    if (!ref.mounted) return;
    final current = state.value;
    if (current == null || current.active != id) return;
    state = AsyncData((seen: current.seen, active: null));
  }

  /// Подсказка прочитана и больше не показывается.
  Future<void> dismiss(String id) async {
    final current = state.value;
    if (current == null) return;
    final seen = {...current.seen, id};
    state = AsyncData((seen: seen, active: null));
    await ref.read(settingsRepositoryProvider).write(_key, seen.join(','));
  }
}

final tipsProvider = AsyncNotifierProvider<TipsNotifier, TipsState>(
  TipsNotifier.new,
);
