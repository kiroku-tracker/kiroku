import 'app_database.dart';
import 'watch_status.dart';

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

/// Пункты «Хочу посмотреть» по выходу серий.
enum PlannedFilter {
  all('Все', LibrarySort.updated),
  available('Доступно', LibrarySort.added),
  airing('Выходит', LibrarySort.nextEpisode),
  announced('Не вышло', LibrarySort.nextEpisode);

  const PlannedFilter(this.label, this.defaultSort);

  final String label;

  /// Сортировка пункта, пока её не меняли.
  final LibrarySort defaultSort;
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
    this.planned = PlannedFilter.all,
    this.plannedSorts = const {},
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
      planned: pick(PlannedFilter.values, 'library.planned', PlannedFilter.all),
      plannedSorts: {
        for (final filter in PlannedFilter.values)
          if (filter != PlannedFilter.all)
            filter: pick(
              LibrarySort.values,
              'library.sort.${filter.name}',
              filter.defaultSort,
            ),
      },
    );
  }

  final LibraryView view;
  final LibrarySort sort;
  final KindFilter kind;

  final bool groupFranchises;

  /// Выбранный пункт «Хочу посмотреть».
  final PlannedFilter planned;

  /// Сортировка пунктов «Хочу посмотреть», кроме «Все».
  final Map<PlannedFilter, LibrarySort> plannedSorts;

  bool _ownSort(WatchStatus? tab) =>
      tab == WatchStatus.planned && planned != PlannedFilter.all;

  /// Сортировка открытой вкладки: у пунктов «Хочу посмотреть» своя.
  LibrarySort sortIn(WatchStatus? tab) =>
      _ownSort(tab) ? plannedSorts[planned] ?? planned.defaultSort : sort;

  /// Меняет сортировку открытой вкладки.
  LibraryPrefs withSort(WatchStatus? tab, LibrarySort value) => _ownSort(tab)
      ? copyWith(plannedSorts: {...plannedSorts, planned: value})
      : copyWith(sort: value);

  LibraryPrefs copyWith({
    LibraryView? view,
    LibrarySort? sort,
    KindFilter? kind,
    bool? groupFranchises,
    PlannedFilter? planned,
    Map<PlannedFilter, LibrarySort>? plannedSorts,
  }) => LibraryPrefs(
    view: view ?? this.view,
    sort: sort ?? this.sort,
    kind: kind ?? this.kind,
    groupFranchises: groupFranchises ?? this.groupFranchises,
    planned: planned ?? this.planned,
    plannedSorts: plannedSorts ?? this.plannedSorts,
  );
}

/// Уведомления о сериях «Хочу посмотреть»; прежний выключатель «Новые
/// серии» выключал их совсем.
EpisodeAlertMode _plannedAlert(Map<String, String> settings) =>
    EpisodeAlertMode.values.asNameMap()[settings['notify.planned']] ??
    (settings['notify.episodes'] == 'false'
        ? EpisodeAlertMode.off
        : EpisodeAlertMode.episodes);

class AppPrefs {
  const AppPrefs({
    this.closeToTray = true,
    this.alertPlanned = EpisodeAlertMode.episodes,
    this.notifyFranchises = true,
    this.notifySeasonAnnounce = true,
    this.notifySeasonStart = true,
    this.trayHintShown = false,
    this.autoMark = true,
    this.autoMarkThreshold = 85,
    this.yummyHost,
    this.episodeAlert = EpisodeAlert.air,
    this.showContinue = true,
    this.posterOriginals = false,
    this.autoAdd = true,
    this.checkUpdates = true,
    this.discord = false,
    this.discordSitesOff = const {},
    this.watchInApp = true,
    this.hideSpoilers = true,
    this.partyNetwork = PartyNetwork.vpn,
    this.partyAddress = '',
    this.partyName = '',
    this.partyGuestRights = const {PartyRight.pause, PartyRight.seek},
  });

  factory AppPrefs.fromSettings(Map<String, String> settings) => AppPrefs(
    closeToTray: settings['app.closeToTray'] != 'false',
    alertPlanned: _plannedAlert(settings),
    notifyFranchises: settings['notify.franchises'] != 'false',
    notifySeasonAnnounce: settings['notify.seasonAnnounce'] != 'false',
    notifySeasonStart: settings['notify.seasonStart'] != 'false',
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
    posterOriginals: settings['library.posterOriginals'] == 'true',
    autoAdd: settings['autoMark.add'] != 'false',
    checkUpdates: settings['updates.check'] != 'false',
    discord: settings['discord.enabled'] == 'true',
    watchInApp: settings['watch.inApp'] != 'false',
    hideSpoilers: settings['watch.hideSpoilers'] != 'false',
    partyNetwork: PartyNetwork.values.firstWhere(
      (network) => network.name == settings['party.network'],
      orElse: () => PartyNetwork.vpn,
    ),
    partyAddress: settings['party.address'] ?? '',
    partyName: settings['party.name'] ?? '',
    partyGuestRights: partyRightsOf(settings['party.guestRights']),
    discordSitesOff: {
      for (final site in (settings['discord.sitesOff'] ?? '').split('|'))
        if (site.isNotEmpty) site,
    },
  );

  final bool closeToTray;

  /// Уведомления о сериях для «Хочу посмотреть».
  final EpisodeAlertMode alertPlanned;

  final bool notifyFranchises;

  final bool notifySeasonAnnounce;

  final bool notifySeasonStart;

  final bool trayHintShown;

  final bool autoMark;

  final int autoMarkThreshold;

  final YummyHost? yummyHost;

  final EpisodeAlert episodeAlert;

  final bool showContinue;

  /// Постеры в полном размере везде, а не только на странице тайтла.
  final bool posterOriginals;

  final bool autoAdd;

  final bool checkUpdates;

  final bool discord;

  final Set<String> discordSitesOff;

  final bool watchInApp;

  final bool hideSpoilers;

  final PartyNetwork partyNetwork;

  final String partyAddress;

  final String partyName;

  /// Права новых гостей в своей комнате.
  final Set<PartyRight> partyGuestRights;

  YummyHost get effectiveYummyHost => yummyHost ?? YummyHost.ru;

  Map<String, String> toSettings() => {
    'app.closeToTray': '$closeToTray',
    'notify.planned': alertPlanned.name,
    'notify.franchises': '$notifyFranchises',
    'notify.seasonAnnounce': '$notifySeasonAnnounce',
    'notify.seasonStart': '$notifySeasonStart',
    'app.trayHintShown': '$trayHintShown',
    'autoMark.enabled': '$autoMark',
    'autoMark.threshold': '$autoMarkThreshold',
    if (yummyHost != null) 'yummy.host': yummyHost!.name,
    'notify.when': episodeAlert.name,
    'library.continue': '$showContinue',
    'library.posterOriginals': '$posterOriginals',
    'autoMark.add': '$autoAdd',
    'updates.check': '$checkUpdates',
    'discord.enabled': '$discord',
    'watch.inApp': '$watchInApp',
    'watch.hideSpoilers': '$hideSpoilers',
    'party.network': partyNetwork.name,
    'party.address': partyAddress,
    'party.name': partyName,
    'party.guestRights': partyRightsText(partyGuestRights),
    'discord.sitesOff': discordSitesOff.join('|'),
  };

  AppPrefs copyWith({
    bool? closeToTray,
    EpisodeAlertMode? alertPlanned,
    bool? notifyFranchises,
    bool? notifySeasonAnnounce,
    bool? notifySeasonStart,
    bool? trayHintShown,
    bool? autoMark,
    int? autoMarkThreshold,
    YummyHost? yummyHost,
    EpisodeAlert? episodeAlert,
    bool? showContinue,
    bool? posterOriginals,
    bool? autoAdd,
    bool? checkUpdates,
    bool? discord,
    Set<String>? discordSitesOff,
    bool? watchInApp,
    bool? hideSpoilers,
    PartyNetwork? partyNetwork,
    String? partyAddress,
    String? partyName,
    Set<PartyRight>? partyGuestRights,
  }) => AppPrefs(
    closeToTray: closeToTray ?? this.closeToTray,
    alertPlanned: alertPlanned ?? this.alertPlanned,
    notifyFranchises: notifyFranchises ?? this.notifyFranchises,
    notifySeasonAnnounce: notifySeasonAnnounce ?? this.notifySeasonAnnounce,
    notifySeasonStart: notifySeasonStart ?? this.notifySeasonStart,
    trayHintShown: trayHintShown ?? this.trayHintShown,
    autoMark: autoMark ?? this.autoMark,
    autoMarkThreshold: autoMarkThreshold ?? this.autoMarkThreshold,
    yummyHost: yummyHost ?? this.yummyHost,
    episodeAlert: episodeAlert ?? this.episodeAlert,
    showContinue: showContinue ?? this.showContinue,
    posterOriginals: posterOriginals ?? this.posterOriginals,
    autoAdd: autoAdd ?? this.autoAdd,
    checkUpdates: checkUpdates ?? this.checkUpdates,
    discord: discord ?? this.discord,
    discordSitesOff: discordSitesOff ?? this.discordSitesOff,
    watchInApp: watchInApp ?? this.watchInApp,
    hideSpoilers: hideSpoilers ?? this.hideSpoilers,
    partyNetwork: partyNetwork ?? this.partyNetwork,
    partyAddress: partyAddress ?? this.partyAddress,
    partyName: partyName ?? this.partyName,
    partyGuestRights: partyGuestRights ?? this.partyGuestRights,
  );
}

/// Сеть для совместного просмотра.
enum PartyNetwork {
  vpn('Виртуальная сеть'),
  custom('Свой адрес');

  const PartyNetwork(this.label);

  final String label;
}

/// Что гость может делать с общим просмотром.
enum PartyRight {
  pause('Пауза, продолжение и скорость', 'пауза и скорость'),
  seek('Перемотка', 'перемотка'),
  episode('Выбор серии и озвучки', 'выбор серии');

  const PartyRight(this.label, this.short);

  final String label;
  final String short;
}

/// Права из строки настроек; без строки пауза и перемотка.
Set<PartyRight> partyRightsOf(String? text) {
  if (text == null) return const {PartyRight.pause, PartyRight.seek};
  final names = text.split(',');
  return {
    for (final right in PartyRight.values)
      if (names.contains(right.name)) right,
  };
}

/// Права строкой для настроек.
String partyRightsText(Set<PartyRight> rights) => [
  for (final right in PartyRight.values)
    if (rights.contains(right)) right.name,
].join(',');

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
/// Когда сообщать о сериях тайтла.
enum EpisodeAlertMode {
  off('Не уведомлять', 'Без уведомлений'),
  premiere('О премьере', 'О премьере'),
  episodes('О каждой серии', 'О каждой серии'),
  finished('Когда выйдут все серии', 'Когда выйдут все');

  const EpisodeAlertMode(this.label, this.short);

  final String label;

  /// Подпись на кнопке уведомлений.
  final String short;
}

enum EpisodeAlert {
  air('сразу после показа в Японии'),
  site('любой перевод на YummyAnime');

  const EpisodeAlert(this.label);

  final String label;
}
