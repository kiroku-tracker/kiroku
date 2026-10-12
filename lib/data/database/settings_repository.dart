import 'app_database.dart';

/// Настройки в базе.
class SettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;

  Future<Map<String, String>> readAll() async => {
    for (final row in await _db.select(_db.appSettings).get())
      row.key: row.value,
  };

  Future<void> write(String key, String value) => _db
      .into(_db.appSettings)
      .insertOnConflictUpdate(
        AppSettingsCompanion.insert(key: key, value: value),
      );
}

enum LibraryView { tiles, table }

enum LibrarySort {
  updated('Недавно изменённые'),
  added('Недавно добавленные'),
  title('По названию'),
  progress('По прогрессу'),
  score('По моей оценке'),
  nextEpisode('По дате следующей серии');

  const LibrarySort(this.label);

  final String label;
}

/// Фильтр по типу тайтла.
enum KindFilter {
  all('Все типы'),
  tv('Сериалы'),
  movie('Фильмы'),
  ova('OVA'),
  ona('ONA'),
  special('Спецвыпуски'),
  other('Другие');

  const KindFilter(this.label);

  final String label;

  bool matches(String? kind) => switch (this) {
    KindFilter.all => true,
    KindFilter.other => !const {
      'tv',
      'movie',
      'ova',
      'ona',
      'special',
    }.contains(kind),
    _ => kind == name,
  };
}

class LibraryPrefs {
  const LibraryPrefs({
    this.view = LibraryView.tiles,
    this.sort = LibrarySort.updated,
    this.kind = KindFilter.all,
    this.groupFranchises = true,
  });

  factory LibraryPrefs.fromSettings(Map<String, String> settings) {
    T pick<T extends Enum>(List<T> values, String key, T fallback) =>
        values.firstWhere(
          (value) => value.name == settings[key],
          orElse: () => fallback,
        );
    return LibraryPrefs(
      view: pick(LibraryView.values, 'library.view', LibraryView.tiles),
      sort: pick(LibrarySort.values, 'library.sort', LibrarySort.updated),
      kind: pick(KindFilter.values, 'library.kind', KindFilter.all),
      groupFranchises: settings['library.groupFranchises'] != 'false',
    );
  }

  final LibraryView view;
  final LibrarySort sort;
  final KindFilter kind;

  final bool groupFranchises;

  LibraryPrefs copyWith({
    LibraryView? view,
    LibrarySort? sort,
    KindFilter? kind,
    bool? groupFranchises,
  }) => LibraryPrefs(
    view: view ?? this.view,
    sort: sort ?? this.sort,
    kind: kind ?? this.kind,
    groupFranchises: groupFranchises ?? this.groupFranchises,
  );
}

class AppPrefs {
  const AppPrefs({
    this.closeToTray = true,
    this.notifyEpisodes = true,
    this.notifyFranchises = true,
    this.trayHintShown = false,
    this.autoMark = true,
    this.autoMarkThreshold = 85,
    this.yummyHost,
    this.episodeAlert = EpisodeAlert.air,
    this.showContinue = true,
    this.autoAdd = true,
    this.checkUpdates = true,
    this.discord = false,
    this.discordSitesOff = const {},
    this.watchInApp = false,
  });

  factory AppPrefs.fromSettings(Map<String, String> settings) => AppPrefs(
    closeToTray: settings['app.closeToTray'] != 'false',
    notifyEpisodes: settings['notify.episodes'] != 'false',
    notifyFranchises: settings['notify.franchises'] != 'false',
    trayHintShown: settings['app.trayHintShown'] == 'true',
    autoMark: settings['autoMark.enabled'] != 'false',
    autoMarkThreshold: int.tryParse(settings['autoMark.threshold'] ?? '') ?? 85,
    yummyHost: YummyHost.values
        .where((host) => host.name == settings['yummy.host'])
        .firstOrNull,
    episodeAlert: EpisodeAlert.values.firstWhere(
      (alert) => alert.name == settings['notify.when'],
      orElse: () => EpisodeAlert.air,
    ),
    showContinue: settings['library.continue'] != 'false',
    autoAdd: settings['autoMark.add'] != 'false',
    checkUpdates: settings['updates.check'] != 'false',
    discord: settings['discord.enabled'] == 'true',
    watchInApp: settings['watch.inApp'] == 'true',
    discordSitesOff: {
      for (final site in (settings['discord.sitesOff'] ?? '').split('|'))
        if (site.isNotEmpty) site,
    },
  );

  final bool closeToTray;

  final bool notifyEpisodes;

  final bool notifyFranchises;

  final bool trayHintShown;

  final bool autoMark;

  final int autoMarkThreshold;

  final YummyHost? yummyHost;

  final EpisodeAlert episodeAlert;

  final bool showContinue;

  final bool autoAdd;

  final bool checkUpdates;

  final bool discord;

  final Set<String> discordSitesOff;

  final bool watchInApp;

  YummyHost get effectiveYummyHost => yummyHost ?? YummyHost.ru;

  Map<String, String> toSettings() => {
    'app.closeToTray': '$closeToTray',
    'notify.episodes': '$notifyEpisodes',
    'notify.franchises': '$notifyFranchises',
    'app.trayHintShown': '$trayHintShown',
    'autoMark.enabled': '$autoMark',
    'autoMark.threshold': '$autoMarkThreshold',
    if (yummyHost != null) 'yummy.host': yummyHost!.name,
    'notify.when': episodeAlert.name,
    'library.continue': '$showContinue',
    'autoMark.add': '$autoAdd',
    'updates.check': '$checkUpdates',
    'discord.enabled': '$discord',
    'watch.inApp': '$watchInApp',
    'discord.sitesOff': discordSitesOff.join('|'),
  };

  AppPrefs copyWith({
    bool? closeToTray,
    bool? notifyEpisodes,
    bool? notifyFranchises,
    bool? trayHintShown,
    bool? autoMark,
    int? autoMarkThreshold,
    YummyHost? yummyHost,
    EpisodeAlert? episodeAlert,
    bool? showContinue,
    bool? autoAdd,
    bool? checkUpdates,
    bool? discord,
    Set<String>? discordSitesOff,
    bool? watchInApp,
  }) => AppPrefs(
    closeToTray: closeToTray ?? this.closeToTray,
    notifyEpisodes: notifyEpisodes ?? this.notifyEpisodes,
    notifyFranchises: notifyFranchises ?? this.notifyFranchises,
    trayHintShown: trayHintShown ?? this.trayHintShown,
    autoMark: autoMark ?? this.autoMark,
    autoMarkThreshold: autoMarkThreshold ?? this.autoMarkThreshold,
    yummyHost: yummyHost ?? this.yummyHost,
    episodeAlert: episodeAlert ?? this.episodeAlert,
    showContinue: showContinue ?? this.showContinue,
    autoAdd: autoAdd ?? this.autoAdd,
    checkUpdates: checkUpdates ?? this.checkUpdates,
    discord: discord ?? this.discord,
    discordSitesOff: discordSitesOff ?? this.discordSitesOff,
    watchInApp: watchInApp ?? this.watchInApp,
  );
}

enum YummyHost {
  ru('ru.yummyani.me', 'Новый дизайн'),
  old('old.yummyani.me', 'Старый дизайн');

  const YummyHost(this.domain, this.label);

  final String domain;
  final String label;

  static YummyHost? ofDomain(String domain) =>
      values.where((host) => host.domain == domain).firstOrNull;
}

/// Когда сообщать о серии.
enum EpisodeAlert {
  air('В японском эфире'),
  site('На YummyAnime');

  const EpisodeAlert(this.label);

  final String label;
}
