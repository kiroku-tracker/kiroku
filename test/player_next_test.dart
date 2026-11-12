import 'package:flutter_test/flutter_test.dart';

import 'package:kiroku/data/database/app_database.dart';
import 'package:kiroku/features/franchise/watch_order_list.dart';
import 'package:kiroku/features/player/frame_reports.dart';
import 'package:kiroku/features/player/player_next.dart';

FranchisePart _part(int id, String status) => FranchisePart(
  anime: Anime(
    id: id,
    name: 'Name $id',
    russian: 'Часть $id',
    kind: 'tv',
    episodes: 12,
    episodesAired: status == 'anons' ? 0 : 12,
    releaseStatus: status,
    updatedAt: DateTime(2026),
  ),
);

void main() {
  test('следующая вышедшая часть франшизы', () {
    final main = [_part(1, 'released'), _part(2, 'ongoing'), _part(3, 'anons')];
    expect(nextFranchisePart(main, 1)?.anime.id, 2);
    expect(nextFranchisePart(main, 2), isNull);
    expect(nextFranchisePart(main, 3), isNull);
    expect(nextFranchisePart(main, 99), isNull);
  });

  test('конец вышедшего сезона', () {
    final released = _part(1, 'released').anime;
    final ongoing = _part(2, 'ongoing').anime;
    expect(seasonFinished(released, 12), isTrue);
    expect(seasonFinished(released, 11), isFalse);
    expect(seasonFinished(released, null), isFalse);
    expect(seasonFinished(ongoing, 12), isFalse);
  });

  test('серия закончилась', () {
    FrameVideo video(double time, {bool paused = true, bool ended = false}) =>
        FrameVideo(
          time: time,
          duration: 1440,
          paused: paused,
          muted: false,
          ended: ended,
        );
    expect(video(1440, ended: true).finished, isTrue);
    expect(video(1439.5).finished, isTrue);
    expect(video(1439.5, paused: false).finished, isFalse);
    expect(video(1300).finished, isFalse);
  });
}
