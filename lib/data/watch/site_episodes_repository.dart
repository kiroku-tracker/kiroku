import '../database/app_database.dart';
import '../database/settings_repository.dart';
import '../yummy/yummy_client.dart';

/// Серии на YummyAnime по озвучкам.
class SiteEpisodesInfo {
  const SiteEpisodesInfo({this.byDubbing = const {}, this.checkedAt});

  final Map<String, int> byDubbing;
  final DateTime? checkedAt;

  bool get checked => checkedAt != null;

  List<MapEntry<String, int>> get sorted =>
      byDubbing.entries.toList()..sort((a, b) {
        final voiced =
            (YummyClient.isVoiceOver(b.key) ? 1 : 0) -
            (YummyClient.isVoiceOver(a.key) ? 1 : 0);
        if (voiced != 0) return voiced;
        final count = b.value - a.value;
        return count != 0 ? count : a.key.compareTo(b.key);
      });
}

class SiteEpisodesRepository {
  SiteEpisodesRepository(this._db, this._settings, this._client);

  final AppDatabase _db;
  final SettingsRepository _settings;
  final YummyClient _client;

  static const _marker = '';

  Stream<SiteEpisodesInfo> watch(int animeId) => (_db.select(
    _db.siteEpisodes,
  )..where((row) => row.animeId.equals(animeId))).watch().map(_info);
  Future<SiteEpisodesInfo> read(int animeId) async => _info(
    await (_db.select(
      _db.siteEpisodes,
    )..where((row) => row.animeId.equals(animeId))).get(),
  );

  /// Загружает и сохраняет серии тайтла.
  Future<({SiteEpisodesInfo before, SiteEpisodesInfo after})> refresh(
    int animeId,
  ) async {
    final before = await read(animeId);
    final id = await yummyId(animeId);
    final byDubbing = id == null
        ? const <String, int>{}
        : await _client.episodesByDubbing(id);
    final now = DateTime.now();
    await _db.transaction(() async {
      await (_db.delete(
        _db.siteEpisodes,
      )..where((row) => row.animeId.equals(animeId))).go();
      await _db.batch((batch) {
        batch.insertAll(_db.siteEpisodes, [
          SiteEpisodesCompanion.insert(
            animeId: animeId,
            dubbing: _marker,
            episodes: 0,
            updatedAt: now,
          ),
          for (final MapEntry(:key, :value) in byDubbing.entries)
            SiteEpisodesCompanion.insert(
              animeId: animeId,
              dubbing: key,
              episodes: value,
              updatedAt: now,
            ),
        ]);
      });
    });
    return (
      before: before,
      after: SiteEpisodesInfo(byDubbing: byDubbing, checkedAt: now),
    );
  }

  /// Номер тайтла в API YummyAnime.
  Future<int?> yummyId(int animeId) async {
    final key = 'yummy.aid.$animeId';
    final saved = int.tryParse((await _settings.readAll())[key] ?? '');
    if (saved != null) return saved;
    final title = await _client.findByShikimoriId(animeId);
    if (title == null || title.id == null) return null;
    await _settings.write(key, '${title.id}');
    await _settings.write('yummy.id.$animeId', title.slug);
    await _settings.write('yummy.${title.slug}', '$animeId');
    return title.id;
  }

  static SiteEpisodesInfo _info(List<SiteEpisode> rows) {
    DateTime? checkedAt;
    final byDubbing = <String, int>{};
    for (final row in rows) {
      if (row.dubbing == _marker) {
        checkedAt = row.updatedAt;
      } else {
        byDubbing[row.dubbing] = row.episodes;
      }
    }
    return SiteEpisodesInfo(byDubbing: byDubbing, checkedAt: checkedAt);
  }
}
