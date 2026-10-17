import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:kiroku/data/database/app_database.dart';
import 'package:kiroku/data/database/watch_status.dart';
import 'package:kiroku/features/watch/watch_next_button.dart';

Anime _anime({String status = 'released', int episodes = 12, int aired = 12}) =>
    Anime(
      id: 1,
      name: 'Name',
      russian: 'Тайтл',
      episodes: episodes,
      episodesAired: aired,
      releaseStatus: status,
      updatedAt: DateTime(2026),
    );

void main() {
  test('следующая серия', () {
    final next = WatchNext.of(
      _anime(),
      status: WatchStatus.watching,
      next: 4,
      watched: 3,
    );
    expect(next.label, 'Смотреть · серия 4');
    expect(next.episode, 4);
    expect(next.restart, isFalse);
  });

  test('всё вышедшее просмотрено', () {
    final next = WatchNext.of(
      _anime(status: 'ongoing', aired: 5),
      status: WatchStatus.watching,
      next: 6,
      watched: 5,
    );
    expect(next.label, 'Нет новых серий');
    expect(next.episode, isNull);
  });

  test('заново и анонс', () {
    final again = WatchNext.of(
      _anime(),
      status: WatchStatus.completed,
      next: 13,
      watched: 12,
    );
    expect(again.label, 'Смотреть заново');
    expect(again.episode, 1);
    expect(again.restart, isTrue);
    expect(again.icon, LucideIcons.rotateCcw);

    final announced = WatchNext.of(
      _anime(status: 'anons', aired: 0),
      status: WatchStatus.planned,
      next: 1,
      watched: 0,
    );
    expect(announced.label, 'Ещё не вышло');
    expect(announced.episode, isNull);
  });
}
