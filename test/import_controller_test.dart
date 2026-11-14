import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kiroku/data/database/watch_status.dart';
import 'package:kiroku/data/import/import_plan.dart';
import 'package:kiroku/data/providers.dart';
import 'package:kiroku/data/shikimori/anime_info.dart';
import 'package:kiroku/features/import/import_controller.dart';

AnimeInfo _info(int id) => AnimeInfo(
  id: id,
  name: 'Anime $id',
  russian: 'Аниме $id',
  episodes: 12,
  episodesAired: 12,
  releaseStatus: 'released',
);

ImportItem _item(int id) => ImportItem(
  sourceTitle: 'Аниме $id',
  anime: _info(id),
  status: WatchStatus.watching,
  viewings: [
    ImportViewing(
      completed: false,
      episodes: [for (var n = 1; n <= 5; n++) ImportEpisode(n)],
    ),
  ],
);

final _plan = ImportPlan(
  sourceName: 'AniLibria',
  userName: 'Вася',
  items: [
    _item(1),
    _item(2),
    _item(3),
    _item(10),
    const ImportItem(sourceTitle: 'Неизвестный'),
  ],
);

Future<ProviderContainer> _started({Map<int, WatchStatus>? owned}) async {
  final container = ProviderContainer(
    overrides: [
      libraryStatusesProvider.overrideWith(
        (ref) => Stream.value(owned ?? {10: WatchStatus.completed}),
      ),
    ],
  );
  addTearDown(container.dispose);
  container.listen(importControllerProvider, (_, _) {});
  await container.read(importControllerProvider.notifier).start(_plan);
  return container;
}

void main() {
  test('группы и счётчики', () async {
    final container = await _started();
    final state = container.read(importControllerProvider)!;
    expect(state.count(ImportGroup.add), 3);
    expect(state.count(ImportGroup.existing), 1);
    expect(state.count(ImportGroup.notFound), 1);
    expect(state.toTransfer, 3);
    expect(state.groupOf(4), ImportGroup.notFound);
  });

  test('галочка у карточки меняет число для переноса', () async {
    final container = await _started();
    final controller = container.read(importControllerProvider.notifier);
    controller.toggle(0);
    expect(container.read(importControllerProvider)!.toTransfer, 2);
    expect(container.read(importControllerProvider)!.isChecked(0), isFalse);
    controller.toggle(0);
    expect(container.read(importControllerProvider)!.toTransfer, 3);
  });

  test('общая замена ставит и снимает галочки у «Уже есть»', () async {
    final container = await _started();
    final controller = container.read(importControllerProvider.notifier);
    controller.setReplace(true);
    expect(container.read(importControllerProvider)!.toTransfer, 4);
    expect(container.read(importControllerProvider)!.isChecked(3), isTrue);
    controller.setReplace(false);
    expect(container.read(importControllerProvider)!.toTransfer, 3);
  });

  test('галочка у «Уже есть» вручную и общая замена', () async {
    final container = await _started();
    final controller = container.read(importControllerProvider.notifier);
    controller.toggle(3);
    expect(container.read(importControllerProvider)!.toTransfer, 4);
    controller.setReplace(false);
    expect(container.read(importControllerProvider)!.isChecked(3), isFalse);
  });

  test('удалённый из библиотеки тайтл считается «Добавятся»', () async {
    final container = await _started(owned: {});
    final state = container.read(importControllerProvider)!;
    expect(state.groupOf(3), ImportGroup.add);
    expect(state.toTransfer, 4);
  });

  test('правки статуса, сердечка и серий попадают в selected', () async {
    final container = await _started();
    final controller = container.read(importControllerProvider.notifier);
    controller.setStatus(0, WatchStatus.completed);
    controller.setFavorite(1, true);
    controller.setEpisodes(2, 3);
    final selected = container.read(importControllerProvider)!.selected;
    expect(selected[0].status, WatchStatus.completed);
    expect(selected[0].viewings.last.episodes.length, 12);
    expect(selected[1].favorite, isTrue);
    expect(selected[2].episodesMarked, 3);
  });

  test('ручной выбор переводит «Не найдены» в «Добавятся»', () async {
    final container = await _started();
    final controller = container.read(importControllerProvider.notifier);
    controller.match(4, _info(50));
    var state = container.read(importControllerProvider)!;
    expect(state.groupOf(4), ImportGroup.add);
    expect(state.isChecked(4), isTrue);
    expect(state.toTransfer, 4);

    controller.match(4, _info(10));
    state = container.read(importControllerProvider)!;
    expect(state.groupOf(4), ImportGroup.existing);
    expect(state.isChecked(4), isTrue);
  });
}
