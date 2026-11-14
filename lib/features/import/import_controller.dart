import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/watch_status.dart';
import '../../data/import/import_plan.dart';
import '../../data/providers.dart';
import '../../data/shikimori/anime_info.dart';

/// Список для переноса с правками человека.
class ImportState {
  const ImportState({
    required this.plan,
    required this.items,
    required this.statuses,
    this.overrides = const {},
    this.replace = false,
  });

  final ImportPlan plan;
  final List<ImportItem> items;

  /// Тайтлы, которые уже есть в библиотеке, и их статусы.
  final Map<int, WatchStatus> statuses;

  /// Галочки, которые человек поставил или снял сам.
  final Map<int, bool> overrides;
  final bool replace;

  ImportGroup groupOf(int index) {
    final id = items[index].shikimoriId;
    if (id == null) return ImportGroup.notFound;
    return statuses.containsKey(id) ? ImportGroup.existing : ImportGroup.add;
  }

  /// Статус тайтла в Kiroku, если он там есть.
  WatchStatus? libraryStatus(int index) => statuses[items[index].shikimoriId];

  bool isChecked(int index) =>
      overrides[index] ??
      switch (groupOf(index)) {
        ImportGroup.add => true,
        ImportGroup.existing => replace,
        ImportGroup.notFound => false,
      };

  /// Сколько тайтлов в группе.
  int count(ImportGroup group) => [
    for (var i = 0; i < items.length; i++)
      if (groupOf(i) == group) i,
  ].length;

  /// Сколько тайтлов группы с галочкой.
  int selectedIn(ImportGroup group) => [
    for (var i = 0; i < items.length; i++)
      if (groupOf(i) == group && isChecked(i)) i,
  ].length;

  int get toTransfer =>
      selectedIn(ImportGroup.add) + selectedIn(ImportGroup.existing);

  /// Тайтлы, которые будут записаны.
  List<ImportItem> get selected => [
    for (var i = 0; i < items.length; i++)
      if (groupOf(i) != ImportGroup.notFound && isChecked(i)) items[i],
  ];

  ImportState copyWith({
    List<ImportItem>? items,
    Map<int, WatchStatus>? statuses,
    Map<int, bool>? overrides,
    bool? replace,
  }) => ImportState(
    plan: plan,
    items: items ?? this.items,
    statuses: statuses ?? this.statuses,
    overrides: overrides ?? this.overrides,
    replace: replace ?? this.replace,
  );
}

class ImportController extends Notifier<ImportState?> {
  @override
  ImportState? build() {
    ref.listen(libraryStatusesProvider, (_, next) {
      final current = state;
      final statuses = next.value;
      if (current != null && statuses != null) {
        state = current.copyWith(statuses: statuses);
      }
    });
    return null;
  }

  /// Начинает работу со списком.
  Future<void> start(ImportPlan plan) async {
    final statuses = await ref.read(libraryStatusesProvider.future);
    state = ImportState(
      plan: plan,
      items: List.of(plan.items),
      statuses: statuses,
    );
  }

  void toggle(int index) {
    final current = state;
    if (current == null) return;
    state = current.copyWith(
      overrides: {...current.overrides, index: !current.isChecked(index)},
    );
  }

  /// Общая галочка замены: сбрасывает ручные галочки у «Уже есть».
  void setReplace(bool value) {
    final current = state;
    if (current == null) return;
    final overrides = {
      for (final entry in current.overrides.entries)
        if (current.groupOf(entry.key) != ImportGroup.existing)
          entry.key: entry.value,
    };
    state = current.copyWith(replace: value, overrides: overrides);
  }

  void _edit(int index, ImportItem Function(ImportItem item) change) {
    final current = state;
    if (current == null) return;
    final items = List.of(current.items);
    items[index] = change(items[index]);
    state = current.copyWith(items: items);
  }

  void setStatus(int index, WatchStatus status) =>
      _edit(index, (item) => item.withStatus(status));

  void setFavorite(int index, bool value) =>
      _edit(index, (item) => item.withFavorite(value));

  void setEpisodes(int index, int count) =>
      _edit(index, (item) => item.withEpisodeCount(count));

  /// Привязывает тайтл из «Не найдены» к выбранному тайтлу Shikimori.
  void match(int index, AnimeInfo anime) {
    _edit(index, (item) => item.withAnime(anime));
    final current = state;
    if (current == null) return;
    state = current.copyWith(overrides: {...current.overrides, index: true});
  }
}

final importControllerProvider =
    NotifierProvider<ImportController, ImportState?>(ImportController.new);
