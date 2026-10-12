import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

/// Группы, франшизы и тайтлы, скрытые в Discord.
class DiscordHidden {
  const DiscordHidden({
    this.groups = const {},
    this.franchises = const {},
    this.titles = const {},
  });

  factory DiscordHidden.fromSettings(Map<String, String> settings) {
    Set<String> read(String key) => {
      for (final value in (settings[key] ?? '').split('|'))
        if (value.isNotEmpty) value,
    };
    return DiscordHidden(
      groups: read(_groupsKey),
      franchises: read(_franchisesKey),
      titles: {for (final value in read(_titlesKey)) ?int.tryParse(value)},
    );
  }

  static const _groupsKey = 'discord.hiddenGroups';
  static const _franchisesKey = 'discord.hiddenFranchises';
  static const _titlesKey = 'discord.hiddenTitles';

  final Set<String> groups;
  final Set<String> franchises;
  final Set<int> titles;

  Map<String, String> toSettings() => {
    _groupsKey: groups.join('|'),
    _franchisesKey: franchises.join('|'),
    _titlesKey: titles.join('|'),
  };

  /// Скрыт ли тайтл сам, своей франшизой или одной из групп.
  bool hides({
    required int animeId,
    String? franchiseKey,
    Iterable<String> groupIds = const [],
  }) =>
      titles.contains(animeId) ||
      (franchiseKey != null && franchises.contains(franchiseKey)) ||
      groupIds.any(groups.contains);

  DiscordHidden _with({
    Iterable<String> groups = const [],
    Iterable<String> franchises = const [],
    Iterable<int> titles = const [],
    required bool hidden,
  }) {
    Set<T> apply<T>(Set<T> current, Iterable<T> values) =>
        hidden ? {...current, ...values} : current.difference(values.toSet());
    return DiscordHidden(
      groups: apply(this.groups, groups),
      franchises: apply(this.franchises, franchises),
      titles: apply(this.titles, titles),
    );
  }
}

class DiscordHiddenNotifier extends AsyncNotifier<DiscordHidden> {
  @override
  Future<DiscordHidden> build() async => DiscordHidden.fromSettings(
    await ref.read(settingsRepositoryProvider).readAll(),
  );

  /// Скрывает или показывает группу вместе с её франшизами и тайтлами.
  Future<void> setGroup(
    String groupId, {
    required Iterable<String> franchises,
    required Iterable<int> titles,
    required bool hidden,
  }) => _save(
    (current) => current._with(
      groups: [groupId],
      franchises: franchises,
      titles: titles,
      hidden: hidden,
    ),
  );

  /// Скрывает или показывает франшизу вместе с её тайтлами.
  Future<void> setFranchise(
    String key, {
    required Iterable<int> titles,
    required bool hidden,
  }) => _save(
    (current) =>
        current._with(franchises: [key], titles: titles, hidden: hidden),
  );

  /// Скрывает или показывает тайтл.
  Future<void> setTitle(int animeId, {required bool hidden}) =>
      _save((current) => current._with(titles: [animeId], hidden: hidden));

  Future<void> _save(DiscordHidden Function(DiscordHidden) edit) async {
    final next = edit(state.value ?? await future);
    state = AsyncData(next);
    final settings = ref.read(settingsRepositoryProvider);
    for (final MapEntry(:key, :value) in next.toSettings().entries) {
      await settings.write(key, value);
    }
  }
}

final discordHiddenProvider =
    AsyncNotifierProvider<DiscordHiddenNotifier, DiscordHidden>(
      DiscordHiddenNotifier.new,
    );
