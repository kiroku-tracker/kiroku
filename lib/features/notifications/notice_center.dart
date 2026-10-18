import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/labels.dart';
import '../../core/theme/app_colors.dart';
import '../../core/toast.dart';
import '../../core/widgets/popup_panel.dart';
import '../../core/widgets/select_button.dart';
import '../../core/widgets/setting_rows.dart';
import '../../data/database/app_database.dart';
import '../../data/database/franchise_rules.dart';
import '../../data/database/library_repository.dart';
import '../../data/database/notices_repository.dart';
import '../../data/database/settings_repository.dart';
import '../../data/providers.dart';
import '../franchise/franchise_screen.dart';
import '../title/title_screen.dart';
import 'alert_rules.dart';
import 'release_events.dart';
import 'release_watcher.dart';

/// Кнопка центра уведомлений с числом непрочитанных.
class NoticesButton extends ConsumerWidget {
  const NoticesButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadNoticesProvider).value ?? 0;
    ref.watch(noticesProvider);
    return Tooltip(
      message: 'Уведомления',
      child: TextButton(
        onPressed: () => _open(context),
        style: TextButton.styleFrom(
          minimumSize: const Size(40, 40),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          foregroundColor: AppColors.navIdle,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.bell, size: 19),
            if (unread > 0) ...[
              const SizedBox(width: 7),
              _Badge(count: unread),
            ],
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context) {
    final box = context.findRenderObject()! as RenderBox;
    final anchor = box.localToGlobal(Offset.zero) & box.size;
    final sectionContext = context;
    Navigator.of(context, rootNavigator: true).push(
      PopupPanelRoute(
        anchor: anchor,
        builder: (_) => _NoticesPanel(
          openTitle: (animeId) => openTitle(
            sectionContext,
            animeId: animeId,
            backLabel: 'Назад в библиотеку',
          ),
          openFranchise: (key) => openFranchise(
            sectionContext,
            key: key,
            backLabel: 'Назад в библиотеку',
          ),
        ),
      ),
    );
  }
}

/// Число непрочитанных на фиолетовом круге.
class _Badge extends StatelessWidget {
  const _Badge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 20),
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}

/// Что показано в панели.
enum _View { notices, settings, exceptions }

/// Центр уведомлений: список, настройки и отдельные настройки.
class _NoticesPanel extends ConsumerStatefulWidget {
  const _NoticesPanel({required this.openTitle, required this.openFranchise});

  final ValueChanged<int> openTitle;
  final ValueChanged<String> openFranchise;

  @override
  ConsumerState<_NoticesPanel> createState() => _NoticesPanelState();
}

class _NoticesPanelState extends ConsumerState<_NoticesPanel> {
  late final NoticesRepository _notices;
  NoticeCategory? _category;
  _View _view = _View.notices;
  _View _back = _View.notices;
  Set<int>? _unread;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _notices = ref.read(noticesRepositoryProvider);
    ref.listenManual(noticesProvider, (_, next) {
      final notices = next.value;
      if (notices == null || _unread != null) return;
      setState(
        () => _unread = {
          for (final notice in notices)
            if (!notice.read) notice.id,
        },
      );
      _notices.markAllRead();
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    _notices.markAllRead();
    super.dispose();
  }

  void _close() => Navigator.of(context).pop();

  void _show(_View view) => setState(() {
    _back = _view;
    _view = view;
  });

  Future<void> _checkNow() async {
    setState(() => _checking = true);
    final events = await ref.read(releaseWatcherProvider).check();
    if (!mounted) return;
    setState(() => _checking = false);
    ref
        .read(toastProvider.notifier)
        .show(events.isEmpty ? 'Нового нет' : 'Новое: ${events.length}');
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.menu,
      elevation: 12,
      shadowColor: const Color(0x85000000),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.menuBorder),
      ),
      child: switch (_view) {
        _View.notices => _noticesView(),
        _View.settings => _settingsView(),
        _View.exceptions => _exceptionsView(),
      },
    );
  }

  Widget _noticesView() {
    final all = ref.watch(noticesProvider).value ?? const <Notice>[];
    final notices = [
      for (final notice in all)
        if (_category == null || notice.category == _category!.name) notice,
    ];
    final exceptions = _Exceptions.of(ref);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(
          title: 'Уведомления',
          trailing: IconButton(
            tooltip: 'Настройки уведомлений',
            onPressed: () => _show(_View.settings),
            icon: const Icon(LucideIcons.settings, size: 18),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 6,
            children: [
              _CategoryTab(
                label: 'Все',
                active: _category == null,
                onTap: () => setState(() => _category = null),
              ),
              for (final category in NoticeCategory.values)
                _CategoryTab(
                  label: category.label,
                  active: _category == category,
                  onTap: () => setState(() => _category = category),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (notices.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
            child: Text(
              _category == null
                  ? 'Уведомлений пока нет.'
                  : 'В этой категории пока пусто.',
              style: const TextStyle(color: AppColors.muted),
            ),
          )
        else
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              itemCount: notices.length,
              itemBuilder: (context, index) {
                final notice = notices[index];
                return _NoticeTile(
                  notice: notice,
                  unread:
                      !notice.read || (_unread?.contains(notice.id) ?? false),
                  onTap: () {
                    _close();
                    widget.openTitle(notice.animeId);
                  },
                );
              },
            ),
          ),
        if (!exceptions.isEmpty) _exceptionsLink(exceptions),
      ],
    );
  }

  /// Ссылка на отдельные настройки внизу панели.
  Widget _exceptionsLink(_Exceptions exceptions) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(height: 1, color: AppColors.menuBorder),
        InkWell(
          onTap: () => _show(_View.exceptions),
          hoverColor: AppColors.menuItemHover,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 12, 12),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.slidersHorizontal,
                  size: 16,
                  color: AppColors.navIdle,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    exceptions.summary,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                const Icon(
                  LucideIcons.chevronRight,
                  size: 16,
                  color: AppColors.navIdle,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _settingsView() {
    final prefs = ref.watch(appPrefsProvider).value ?? const AppPrefs();
    void change(AppPrefs Function(AppPrefs) edit) =>
        ref.read(appPrefsProvider.notifier).change(edit);
    final exceptions = _Exceptions.of(ref);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(
          title: 'Настройки уведомлений',
          onBack: () => _show(_View.notices),
          trailing: IconButton(
            tooltip: 'Проверить сейчас',
            onPressed: _checking ? null : _checkNow,
            icon: _checking
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(LucideIcons.refreshCw, size: 18),
          ),
        ),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SettingSection('Новые серии'),
                ChoiceRow(
                  title: '«Хочу посмотреть»',
                  control: _modeSelect(
                    prefs.alertPlanned,
                    (mode) =>
                        change((prefs) => prefs.copyWith(alertPlanned: mode)),
                  ),
                ),
                SettingRow(
                  title: 'Ждать перевод',
                  text: prefs.episodeAlert == EpisodeAlert.site
                      ? 'Уведомление, когда серия выйдет на YummyAnime'
                      : 'Уведомление сразу после показа в Японии',
                  value: prefs.episodeAlert == EpisodeAlert.site,
                  onChanged: (value) => change(
                    (prefs) => prefs.copyWith(
                      episodeAlert: value
                          ? EpisodeAlert.site
                          : EpisodeAlert.air,
                    ),
                  ),
                ),
                const SettingSection('Франшизы'),
                SettingRow(
                  title: 'Новые части',
                  text: 'Части, которых нет в библиотеке',
                  value: prefs.notifyFranchises,
                  onChanged: (value) => change(
                    (prefs) => prefs.copyWith(notifyFranchises: value),
                  ),
                ),
                SettingRow(
                  title: 'Анонс',
                  text: 'Объявлена на Shikimori',
                  value: prefs.notifySeasonAnnounce,
                  enabled: prefs.notifyFranchises,
                  sub: true,
                  onChanged: (value) => change(
                    (prefs) => prefs.copyWith(notifySeasonAnnounce: value),
                  ),
                ),
                SettingRow(
                  title: 'Начало показа',
                  text: 'Вышла 1-я серия',
                  value: prefs.notifySeasonStart,
                  enabled: prefs.notifyFranchises,
                  sub: true,
                  onChanged: (value) => change(
                    (prefs) => prefs.copyWith(notifySeasonStart: value),
                  ),
                ),
                const SettingNote(
                  'Отдельно для тайтла или франшизы: колокольчик на их странице',
                ),
              ],
            ),
          ),
        ),
        if (!exceptions.isEmpty) _exceptionsLink(exceptions),
      ],
    );
  }

  /// Выбор уведомлений о сериях.
  Widget _modeSelect(
    EpisodeAlertMode value,
    ValueChanged<EpisodeAlertMode> onChanged,
  ) => SelectButton<EpisodeAlertMode>(
    icon: value == EpisodeAlertMode.off
        ? LucideIcons.bellOff
        : LucideIcons.bell,
    tooltip: 'Уведомления о сериях',
    value: value,
    options: EpisodeAlertMode.values,
    labelOf: (mode) => mode.label,
    onChanged: onChanged,
  );

  Widget _exceptionsView() {
    final exceptions = _Exceptions.of(ref);
    final library = ref.read(libraryRepositoryProvider);
    final franchises = ref.read(franchiseRepositoryProvider);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(title: 'Отдельные настройки', onBack: () => _show(_back)),
        if (exceptions.isEmpty)
          const Padding(
            padding: EdgeInsets.fromLTRB(18, 12, 18, 24),
            child: Text(
              'Все тайтлы и франшизы по общей настройке.',
              style: TextStyle(color: AppColors.muted),
            ),
          )
        else
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
              children: [
                if (exceptions.titles.isNotEmpty) ...[
                  const _GroupHeader('Тайтлы'),
                  for (final (:item, :mode) in exceptions.titles)
                    _ExceptionRow(
                      name: item.anime.title,
                      detail: mode.label,
                      on: mode != EpisodeAlertMode.off,
                      action: 'Сбросить',
                      onOpen: () {
                        _close();
                        widget.openTitle(item.anime.id);
                      },
                      onAction: () => library.setAlertMode(item.anime.id, null),
                    ),
                ],
                for (final group in exceptions.franchises) ...[
                  _GroupHeader('Франшизы · ${group.label}'),
                  for (final franchise in group.items)
                    _ExceptionRow(
                      name: franchise.name,
                      on: group.on,
                      action: group.on ? 'Выключить' : 'Включить',
                      onOpen: () {
                        _close();
                        widget.openFranchise(franchise.key);
                      },
                      onAction: () {
                        final flags = alertFlags(
                          on: !group.on,
                          byDefault: exceptions.prefs.notifyFranchises,
                        );
                        franchises.setAlerts(
                          franchise.key,
                          muted: flags.muted,
                          alertsOn: flags.alertsOn,
                        );
                      },
                    ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

/// Тайтлы и франшизы с уведомлениями не по общей настройке: при включённой
/// настройке отключённые, при выключенной включённые отдельно.
class _Exceptions {
  const _Exceptions({
    required this.prefs,
    required this.titles,
    required this.franchises,
  });

  factory _Exceptions.of(WidgetRef ref) {
    final prefs = ref.watch(appPrefsProvider).value ?? const AppPrefs();
    final items = ref.watch(libraryItemsProvider).value ?? const [];
    final rows = ref.watch(franchisesProvider).value ?? const {};

    final titles = [
      for (final item in items)
        if (ownAlertMode(item.entry) case final mode?
            when mode != defaultAlertMode(item.entry, prefs))
          (item: item, mode: mode),
    ];

    final franchises = <({String key, String name})>[];
    final byKey = <String, List<LibraryItem>>{};
    for (final item in items) {
      final key = franchiseKeyOf(item.entry, item.anime);
      if (key != null) byKey.putIfAbsent(key, () => []).add(item);
    }
    bool listed(Franchise row) =>
        prefs.notifyFranchises ? row.muted : row.alertsOn;
    for (final row in rows.values) {
      final own = byKey[row.key];
      if (own == null || !listed(row)) continue;
      franchises.add((key: row.key, name: franchiseName(row, own)));
    }

    return _Exceptions(
      prefs: prefs,
      titles: titles,
      franchises: [
        if (franchises.isNotEmpty)
          _Group(
            label: prefs.notifyFranchises ? 'отключены' : 'включены отдельно',
            on: !prefs.notifyFranchises,
            items: franchises,
          ),
      ],
    );
  }

  final AppPrefs prefs;

  /// Тайтлы с уведомлениями о сериях не по общей настройке.
  final List<({LibraryItem item, EpisodeAlertMode mode})> titles;
  final List<_Group<({String key, String name})>> franchises;

  bool get isEmpty => titles.isEmpty && franchises.isEmpty;

  /// Строка-ссылка под списком уведомлений.
  String get summary {
    final parts = <String>[
      if (titles.isNotEmpty)
        'Настроены отдельно: ${titles.length} '
            '${plural(titles.length, 'тайтл', 'тайтла', 'тайтлов')}',
    ];
    for (final group in franchises) {
      final count = group.items.length;
      parts.add(
        '${_capital(group.label)}: $count '
        '${plural(count, 'франшиза', 'франшизы', 'франшиз')}',
      );
    }
    return parts.join(' · ');
  }

  static String _capital(String text) =>
      text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);
}

class _Group<T> {
  const _Group({required this.label, required this.on, required this.items});

  final String label;
  final bool on;
  final List<T> items;
}

/// Заголовок панели, при необходимости со стрелкой назад.
class _Header extends StatelessWidget {
  const _Header({required this.title, this.onBack, this.trailing});

  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(onBack == null ? 18 : 8, 8, 8, 6),
      child: SizedBox(
        height: 40,
        child: Row(
          children: [
            if (onBack != null) ...[
              IconButton(
                tooltip: 'Назад',
                onPressed: onBack,
                icon: const Icon(LucideIcons.arrowLeft, size: 18),
              ),
              const SizedBox(width: 4),
            ],
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

/// Вкладка категории.
class _CategoryTab extends StatelessWidget {
  const _CategoryTab({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? const Color(0xFF2B2642) : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(9),
        side: BorderSide(
          color: active ? const Color(0xFF6654C9) : const Color(0xFF323039),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        hoverColor: AppColors.menuItemHover,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : AppColors.navIdle,
            ),
          ),
        ),
      ),
    );
  }
}

/// Строка уведомления.
class _NoticeTile extends StatelessWidget {
  const _NoticeTile({
    required this.notice,
    required this.unread,
    required this.onTap,
  });

  final Notice notice;
  final bool unread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final seasons = notice.category == NoticeCategory.seasons.name;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      hoverColor: AppColors.menuItemHover,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.only(top: 7),
              decoration: BoxDecoration(
                color: unread ? AppColors.accent : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                seasons ? LucideIcons.clapperboard : LucideIcons.tv,
                size: 16,
                color: AppColors.navIdle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notice.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notice.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              timeAgo(notice.createdAt),
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

/// Заголовок группы отдельных настроек.
class _GroupHeader extends StatelessWidget {
  const _GroupHeader(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 4),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.muted,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Тайтл или франшиза с отдельной настройкой.
class _ExceptionRow extends StatelessWidget {
  const _ExceptionRow({
    required this.name,
    required this.on,
    required this.action,
    required this.onOpen,
    required this.onAction,
    this.detail,
  });

  final String name;
  final String? detail;
  final bool on;
  final String action;
  final VoidCallback onOpen;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(10),
      hoverColor: AppColors.menuItemHover,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 4, 4, 4),
        child: Row(
          children: [
            Icon(
              on ? LucideIcons.bell : LucideIcons.bellOff,
              size: 16,
              color: AppColors.navIdle,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (detail case final detail?)
                    Text(
                      detail,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
            ),
            TextButton(onPressed: onAction, child: Text(action)),
          ],
        ),
      ),
    );
  }
}
