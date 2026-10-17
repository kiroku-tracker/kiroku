import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kiroku/data/database/app_database.dart';
import 'package:kiroku/data/database/library_repository.dart';
import 'package:kiroku/data/database/status_action.dart';
import 'package:kiroku/data/providers.dart';
import 'package:kiroku/data/shikimori/anime_info.dart';
import 'package:kiroku/data/watch/watch_sources.dart';
import 'package:kiroku/features/player/player_session.dart';
import 'package:kiroku/features/watch/watch_actions.dart';

class _Source implements WatchSource {
  @override
  String get id => 'yummy';

  @override
  String get name => 'YummyAnime';

  @override
  Future<WatchTarget> resolve({
    required int shikimoriId,
    required String title,
  }) async => WatchTarget(
    uri: Uri.parse('https://ru.yummyani.me/catalog/item/show'),
    found: true,
  );
}

class _Sessions extends PlayerSessionNotifier {
  final opened = <({Uri uri, int? episode})>[];

  @override
  void open(
    Uri uri, {
    required String title,
    int? animeId,
    int? episode,
    String? dubbing,
  }) => opened.add((uri: uri, episode: episode));
}

void main() {
  testWidgets('смотреть серию во встроенном плеере', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    const info = AnimeInfo(
      id: 7,
      name: 'Show',
      russian: 'Тайтл',
      kind: 'tv',
      episodes: 12,
      episodesAired: 12,
      releaseStatus: 'released',
    );
    await LibraryRepository(database).add(info, StatusAction.watching);
    final anime = (await LibraryRepository(database).animesByIds([7]))[7]!;
    final sessions = _Sessions();
    late WidgetRef widgetRef;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          watchSourceProvider.overrideWithValue(_Source()),
          playerSessionProvider.overrideWith(() => sessions),
        ],
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, _) {
              widgetRef = ref;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    await tester.runAsync(() => watchEpisode(widgetRef, anime, 5));

    expect(sessions.opened.single.episode, 5);
    expect(sessions.opened.single.uri.path, '/catalog/item/show');
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  });
}
