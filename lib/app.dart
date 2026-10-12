import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'app_section.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/toast.dart';
import 'core/widgets/app_menu_anchor.dart';
import 'features/calendar/calendar_screen.dart';
import 'features/groups/groups_screen.dart';
import 'features/journal/journal_screen.dart';
import 'features/library/library_screen.dart';
import 'features/player/player_screen.dart';
import 'features/search/search_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/updates/update_dialog.dart';
import 'system/backups.dart';
import 'system/desktop.dart';
import 'system/updates.dart';

class KirokuApp extends StatelessWidget {
  const KirokuApp({super.key, this.desktop = false});

  final bool desktop;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kiroku',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      locale: const Locale('ru'),
      supportedLocales: const [Locale('ru')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: AppShell(desktop: desktop),
    );
  }
}

/// Главное окно: боковое меню и открытый раздел.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, this.desktop = false});

  final bool desktop;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  @override
  void initState() {
    super.initState();
    if (widget.desktop) ref.read(desktopControllerProvider).start();
    if (Backups.restoredAtStart) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => ref
            .read(toastProvider.notifier)
            .show('Данные восстановлены из копии'),
      );
    }
  }

  static const _sectionRoots = {
    AppSection.library: LibraryScreen(),
    AppSection.groups: GroupsScreen(),
    AppSection.calendar: CalendarScreen(),
    AppSection.journal: JournalScreen(),
    AppSection.search: SearchScreen(),
    AppSection.settings: SettingsScreen(),
  };

  @override
  Widget build(BuildContext context) {
    final section = ref.watch(appSectionProvider);
    void back() => sectionNavigatorKeys[section]?.currentState?.maybePop();
    void open(AppSection section) =>
        ref.read(appSectionProvider.notifier).open(section);
    return Scaffold(body: ToastHost(child: _shortcuts(back, open)));
  }

  /// Обработка Esc: закрыть меню, убрать курсор из поля или вернуться назад.
  static void _escape(VoidCallback back) {
    final focus = FocusManager.instance.primaryFocus;
    if (OpenMenus.any) {
      OpenMenus.closeAll();
    } else if (focus?.context?.findAncestorWidgetOfExactType<EditableText>() !=
        null) {
      focus!.unfocus();
    } else {
      back();
    }
  }

  /// Горячие клавиши всего окна.
  Widget _shortcuts(VoidCallback back, void Function(AppSection section) open) {
    final section = ref.watch(appSectionProvider);
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () => _escape(back),
        const SingleActivator(LogicalKeyboardKey.keyF, control: true): () {
          open(AppSection.search);
          ref.read(searchFocusProvider.notifier).request();
        },
        const SingleActivator(LogicalKeyboardKey.arrowLeft, alt: true): back,
        for (final (index, section) in _numbered.indexed)
          SingleActivator(_digits[index], control: true): () => open(section),
        const SingleActivator(LogicalKeyboardKey.comma, control: true): () =>
            open(AppSection.settings),
      },
      child: Focus(
        autofocus: true,
        child: Listener(
          onPointerDown: (event) {
            if (event.buttons & kBackMouseButton != 0) back();
          },
          child: Row(
            children: [
              if (!ref.watch(playerFullScreenProvider)) ...[
                const _Sidebar(),
                const VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: AppColors.divider,
                ),
              ],
              Expanded(
                child: IndexedStack(
                  index: section.index,
                  children: [
                    for (final entry in _sectionRoots.entries)
                      _SectionNavigator(
                        navigatorKey: sectionNavigatorKeys[entry.key]!,
                        root: entry.value,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const _numbered = [
    AppSection.library,
    AppSection.groups,
    AppSection.calendar,
    AppSection.journal,
    AppSection.search,
  ];
  static const _digits = [
    LogicalKeyboardKey.digit1,
    LogicalKeyboardKey.digit2,
    LogicalKeyboardKey.digit3,
    LogicalKeyboardKey.digit4,
    LogicalKeyboardKey.digit5,
  ];
}

class _SectionNavigator extends StatelessWidget {
  const _SectionNavigator({required this.navigatorKey, required this.root});

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget root;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (_) =>
          PageRouteBuilder<void>(pageBuilder: (_, _, _) => root),
    );
  }
}

/// Боковое меню с разделами.
class _Sidebar extends ConsumerWidget {
  const _Sidebar();

  static const _top = [
    (AppSection.library, LucideIcons.library, 'Библиотека'),
    (AppSection.groups, LucideIcons.folders, 'Группы'),
    (AppSection.calendar, LucideIcons.calendarDays, 'Календарь'),
    (AppSection.journal, LucideIcons.history, 'Журнал отметок'),
    (AppSection.search, LucideIcons.search, 'Поиск'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(appSectionProvider);
    void open(AppSection section) =>
        ref.read(appSectionProvider.notifier).open(section);

    return Container(
      width: 60,
      color: AppColors.sidebar,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          for (final (section, icon, label) in _top)
            _SidebarItem(
              icon: icon,
              label: label,
              active: section == current,
              onTap: () => open(section),
            ),
          const Spacer(),
          const _UpdateButton(),
          _SidebarItem(
            icon: LucideIcons.settings,
            label: 'Настройки',
            active: current == AppSection.settings,
            onTap: () => open(AppSection.settings),
          ),
        ],
      ),
    );
  }
}

/// Кнопка обновления над настройками.
class _UpdateButton extends ConsumerWidget {
  const _UpdateButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final releases = ref.watch(updatesProvider);
    if (releases.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Tooltip(
        message: 'Обновить до ${releases.first.version}',
        positionDelegate: _besideIcon,
        child: IconButton(
          onPressed: () => showUpdateDialog(context, releases),
          style: ButtonStyle(
            fixedSize: const WidgetStatePropertyAll(Size.square(32)),
            minimumSize: const WidgetStatePropertyAll(Size.square(32)),
            padding: const WidgetStatePropertyAll(EdgeInsets.zero),
            shape: const WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(11)),
              ),
            ),
            side: WidgetStatePropertyAll(
              BorderSide(color: AppColors.update.withValues(alpha: 0.4)),
            ),
            backgroundColor: WidgetStateProperty.resolveWith(
              (states) => AppColors.update.withValues(
                alpha: states.contains(WidgetState.hovered) ? 0.2 : 0.1,
              ),
            ),
            foregroundColor: const WidgetStatePropertyAll(AppColors.updateText),
          ),
          icon: const Icon(LucideIcons.arrowUp, size: 16),
        ),
      ),
    );
  }
}

/// Положение подсказки справа от иконки.
Offset _besideIcon(TooltipPositionContext context) => Offset(
  context.target.dx + context.targetSize.width / 2 + 10,
  context.target.dy - context.tooltipSize.height / 2,
);

class _SidebarItem extends StatefulWidget {
  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final highlighted = widget.active || _hovered;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Tooltip(
        message: widget.label,
        positionDelegate: _besideIcon,
        child: Semantics(
          button: true,
          selected: widget.active,
          label: widget.label,
          child: Material(
            color: highlighted ? AppColors.navActive : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            child: InkWell(
              onTap: widget.onTap,
              onHover: (value) => setState(() => _hovered = value),
              borderRadius: BorderRadius.circular(9),
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: SizedBox.square(
                dimension: 42,
                child: Icon(
                  widget.icon,
                  size: 20,
                  color: highlighted ? Colors.white : AppColors.navIdle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
