import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiroku/data/database/app_database.dart';
import 'package:kiroku/data/database/discord_hidden.dart';
import 'package:kiroku/data/providers.dart';

void main() {
  late AppDatabase database;
  late ProviderContainer container;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(database)],
    );
  });

  tearDown(() async {
    container.dispose();
    await database.close();
  });

  DiscordHiddenNotifier notifier() =>
      container.read(discordHiddenProvider.notifier);
  Future<DiscordHidden> hidden() =>
      container.read(discordHiddenProvider.future);

  test('группа скрывает франшизы и тайтлы', () async {
    await hidden();
    await notifier().setGroup(
      'g1',
      franchises: ['frieren'],
      titles: [1, 2],
      hidden: true,
    );
    final value = await hidden();
    expect(value.groups, {'g1'});
    expect(value.franchises, {'frieren'});
    expect(value.titles, {1, 2});
    expect(value.hides(animeId: 3, groupIds: ['g1']), isTrue);
    expect(value.hides(animeId: 3, groupIds: ['g2']), isFalse);

    await notifier().setGroup(
      'g1',
      franchises: ['frieren'],
      titles: [1, 2],
      hidden: false,
    );
    final shown = await hidden();
    expect(shown.groups, isEmpty);
    expect(shown.franchises, isEmpty);
    expect(shown.titles, isEmpty);
  });

  test('строгое правило', () async {
    await hidden();
    await notifier().setGroup('g1', franchises: [], titles: [], hidden: true);
    await notifier().setFranchise('frieren', titles: [1], hidden: false);
    final value = await hidden();
    expect(
      value.hides(animeId: 1, franchiseKey: 'frieren', groupIds: ['g1', 'g2']),
      isTrue,
    );
  });

  test('франшиза и тайтл', () async {
    await hidden();
    await notifier().setFranchise('frieren', titles: [1, 2], hidden: true);
    await notifier().setTitle(2, hidden: false);
    final value = await hidden();
    expect(value.hides(animeId: 2, franchiseKey: 'frieren'), isTrue);
    expect(value.hides(animeId: 2), isFalse);
    expect(value.hides(animeId: 1), isTrue);
  });

  test('сохранение', () async {
    await hidden();
    await notifier().setTitle(5, hidden: true);
    final settings = await container.read(settingsRepositoryProvider).readAll();
    expect(DiscordHidden.fromSettings(settings).titles, {5});
  });
}
