import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/app_database.dart';
import '../data/database/discord_hidden.dart';
import '../data/database/franchise_rules.dart';
import '../data/database/library_repository.dart';
import '../data/database/user_groups_repository.dart';
import '../data/providers.dart';
import '../data/shikimori/shikimori_client.dart';
import '../features/autotrack/auto_marker.dart';
import 'discord_rpc.dart';

/// Сайты, просмотр на которых может попадать в статус.
const discordSites = ['YummyAnime'];

/// Статус «Смотрит» в Discord.
class DiscordPresence {
  DiscordPresence(this._ref);

  static const clientId = '1559212700553322506';

  final Ref _ref;
  final _rpc = DiscordRpc(clientId);
  final _subscriptions = <ProviderSubscription<Object?>>[];

  String? _shown;
  DateTime? _lastConnect;
  bool _busy = false;

  void start() {
    _subscriptions.addAll([
      _ref.listen(nowPlayingProvider, (_, _) => _update()),
      _ref.listen(appPrefsProvider, (_, _) => _update()),
      _ref.listen(discordHiddenProvider, (_, _) => _update()),
    ]);
  }

  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.close();
    }
    _rpc.close();
  }

  Future<void> _update() async {
    if (_busy) return;
    _busy = true;
    try {
      await _apply(await _activity());
    } on Object {
      // Ошибка пропускается.
    } finally {
      _busy = false;
    }
  }

  Future<Map<String, Object?>?> _activity() async {
    final prefs = _ref.read(appPrefsProvider).value;
    final now = _ref.read(nowPlayingProvider);
    final id = now?.animeId;
    if (prefs == null || !prefs.discord) return null;
    if (now != null && prefs.discordSitesOff.contains(now.site)) return null;
    if (now == null || !now.playing || id == null) return null;

    final library = _ref.read(libraryRepositoryProvider);
    final anime = (await library.animesByIds([id]))[id];
    final entry = await library.watchEntry(id).first;
    final hidden = await _ref.read(discordHiddenProvider.future);
    final members = await _ref.read(groupMembersProvider.future);
    if (anime == null
        ? hidden.titles.contains(id)
        : anime.hiddenIn(hidden, entry: entry, members: members)) {
      return null;
    }

    final title = _cut(anime?.title ?? now.title);
    final episode = now.episode;
    final total = anime?.episodes ?? 0;
    final start = DateTime.now().subtract(
      Duration(milliseconds: (now.position * 1000).round()),
    );
    final poster = anime?.posterUrl;
    return {
      'type': 3,
      'details': title,
      if (episode != null)
        'state': total >= episode && total > 0
            ? 'Серия $episode из $total'
            : 'Серия $episode',
      if (now.duration > 0)
        'timestamps': {
          'start': start.millisecondsSinceEpoch,
          'end': start
              .add(Duration(milliseconds: (now.duration * 1000).round()))
              .millisecondsSinceEpoch,
        },
      if (poster != null && poster.startsWith('https://'))
        'assets': {'large_image': poster, 'large_text': title},
      'buttons': [
        {
          'label': 'Открыть на Shikimori',
          'url': ShikimoriClient.animePage(id).toString(),
        },
      ],
    };
  }

  Future<void> _apply(Map<String, Object?>? activity) async {
    final signature = activity == null ? null : _signature(activity);
    if (signature == _shown) return;
    if (activity == null) {
      await _rpc.setActivity(null);
      _shown = null;
      if (!(_ref.read(appPrefsProvider).value?.discord ?? false)) _rpc.close();
      return;
    }
    if (!_rpc.connected) {
      final last = _lastConnect;
      if (last != null &&
          DateTime.now().difference(last) < const Duration(seconds: 30)) {
        return;
      }
      _lastConnect = DateTime.now();
      if (!await _rpc.connect()) return;
    }
    await _rpc.setActivity(activity);
    _shown = _rpc.connected ? signature : null;
  }

  /// Подпись статуса без мелких сдвигов времени.
  static String _signature(Map<String, Object?> activity) {
    final timestamps = activity['timestamps'] as Map?;
    return jsonEncode({
      ...activity,
      if (timestamps != null)
        'timestamps': (timestamps['start'] as int) ~/ 10000,
    });
  }

  static String _cut(String text) =>
      text.length <= 120 ? text : '${text.substring(0, 119)}…';
}

final discordPresenceProvider = Provider<DiscordPresence>((ref) {
  final presence = DiscordPresence(ref);
  ref.onDispose(presence.dispose);
  return presence;
});

/// Тайтл в формате для проверки скрытия.
extension DiscordAnime on Anime {
  bool hiddenIn(
    DiscordHidden hidden, {
    LibraryEntry? entry,
    Map<String, Set<String>> members = const {},
  }) {
    final item = entry == null ? null : LibraryItem(entry: entry, anime: this);
    final key = item != null ? franchiseKeyOf(item.entry, this) : franchise;
    return hidden.hides(
      animeId: id,
      franchiseKey: key == null || key.isEmpty ? null : key,
      groupIds: item == null ? const [] : groupsOf(item, members),
    );
  }
}
