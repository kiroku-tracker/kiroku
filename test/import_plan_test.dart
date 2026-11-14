import 'package:flutter_test/flutter_test.dart';

import 'package:kiroku/data/database/watch_status.dart';
import 'package:kiroku/data/import/import_plan.dart';
import 'package:kiroku/data/shikimori/anime_info.dart';

const _anime = AnimeInfo(
  id: 1,
  name: 'Show',
  russian: 'Тайтл',
  episodes: 12,
  episodesAired: 12,
  releaseStatus: 'released',
);

final _day = DateTime(2026, 1, 1);

ImportItem _item({
  WatchStatus status = WatchStatus.watching,
  List<ImportViewing>? viewings,
}) => ImportItem(
  sourceTitle: 'Тайтл',
  anime: _anime,
  status: status,
  viewings:
      viewings ??
      [
        ImportViewing(
          completed: false,
          episodes: [for (var n = 1; n <= 5; n++) ImportEpisode(n, _day)],
        ),
      ],
);

void main() {
  test('меньше серий: остаются первые с датами', () {
    final item = _item().withEpisodeCount(3);
    expect(item.episodesMarked, 3);
    expect(item.viewings.last.episodes.map((e) => e.number), [1, 2, 3]);
    expect(item.viewings.last.episodes.every((e) => e.at == _day), isTrue);
  });

  test('больше серий: добавляются без дат', () {
    final item = _item().withEpisodeCount(7);
    expect(item.viewings.last.episodes.length, 7);
    expect(item.viewings.last.episodes[4].at, _day);
    expect(item.viewings.last.episodes[5].at, isNull);
    expect(item.viewings.last.episodes[6].number, 7);
  });

  test('ноль серий: пустой последний просмотр', () {
    final item = _item().withEpisodeCount(0);
    expect(item.episodesMarked, 0);
    expect(item.viewings.last.episodes, isEmpty);
  });

  test('«Просмотрено» заполняет все серии и завершает просмотр', () {
    final item = _item().withStatus(WatchStatus.completed);
    final last = item.viewings.last;
    expect(item.status, WatchStatus.completed);
    expect(last.completed, isTrue);
    expect(last.episodes.length, 12);
    expect(last.episodes.take(5).every((e) => e.at == _day), isTrue);
    expect(last.episodes.skip(5).every((e) => e.at == null), isTrue);
  });

  test('число серий берётся из доступных, если всего серий 0', () {
    const ongoing = AnimeInfo(
      id: 2,
      name: 'On',
      russian: 'Онгоинг',
      episodes: 0,
      episodesAired: 7,
      releaseStatus: 'ongoing',
    );
    final item = ImportItem(
      sourceTitle: 'Онгоинг',
      anime: ongoing,
      status: WatchStatus.watching,
    ).withStatus(WatchStatus.completed);
    expect(item.viewings.last.episodes.length, 7);
  });

  test('из «Просмотрено» в «Смотрю»: просмотр не завершён, серии на месте', () {
    final done = _item().withStatus(WatchStatus.completed);
    final back = done.withStatus(WatchStatus.watching);
    expect(back.viewings.last.completed, isFalse);
    expect(back.viewings.last.episodes.length, 12);
  });

  test('пустой список просмотров: одна незавершённая запись', () {
    final item = ImportItem(
      sourceTitle: 'Тайтл',
      anime: _anime,
    ).withEpisodeCount(2);
    expect(item.viewings.length, 1);
    expect(item.viewings.single.completed, isFalse);
    expect(item.episodesMarked, 2);
  });

  test('withAnime задаёт номер Shikimori', () {
    final lost = ImportItem(sourceTitle: 'Неизвестный');
    expect(lost.shikimoriId, isNull);
    expect(lost.withAnime(_anime).shikimoriId, 1);
  });

  test('withFavorite меняет сердечко', () {
    expect(_item().withFavorite(true).favorite, isTrue);
  });
}
