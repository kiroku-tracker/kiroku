import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../discord/discord_menu.dart';
import '../../core/widgets/app_menu_anchor.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/card_grid.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/panel.dart';
import '../../core/widgets/poster_card.dart';
import '../../core/widgets/status_menu.dart';
import '../../data/database/app_database.dart';
import '../../data/database/franchise_rules.dart';
import '../../data/database/user_groups_repository.dart';
import '../../data/database/watch_status.dart';
import '../franchise/franchise_card.dart';
import '../library/library_screen.dart';
import '../library/library_filter.dart';
import '../library/library_toolbar.dart';
import 'group_actions.dart';
import 'group_model.dart';

void openGroup(BuildContext context, String groupId) {
  Navigator.of(context).push(
    PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 160),
      reverseTransitionDuration: const Duration(milliseconds: 120),
      pageBuilder: (_, _, _) => GroupScreen(groupId: groupId),
      transitionsBuilder: (_, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  );
}

class GroupScreen extends ConsumerStatefulWidget {
  const GroupScreen({super.key, required this.groupId});

  final String groupId;

  @override
  ConsumerState<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends ConsumerState<GroupScreen> {
  static final _bodyHeight = PosterCard.bodyHeight(withExtra: true);

  WatchStatus? _tab;

  @override
  Widget build(BuildContext context) {
    final views = ref.watch(groupViewsProvider).value;
    final view = views
        ?.where((view) => view.group.id == widget.groupId)
        .firstOrNull;
    final padding = pagePadding(top: 18);

    final back = TextButton.icon(
      onPressed: () => Navigator.of(context).maybePop(),
      icon: const Icon(LucideIcons.arrowLeft, size: 18),
      label: const Text('Назад к группам'),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
    if (view == null) {
      return Padding(
        padding: padding,
        child: Align(alignment: Alignment.topLeft, child: back),
      );
    }

    final units = [
      for (final unit in view.units)
        if (_tab == null ||
            switch (unit) {
              TitleUnit(:final item) => item.status == _tab,
              FranchiseUnit() => unit.has(_tab!),
            })
          unit,
    ];
    final average = view.averageScore;

    return LayoutBuilder(
      builder: (context, constraints) => CustomScrollView(
        slivers: [
          SliverPadding(
            padding: padding.copyWith(bottom: 18),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      back,
                      const Spacer(),
                      _MoreMenu(view: view),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.folder,
                        size: 26,
                        color: AppColors.accentText,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          view.group.name,
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    [
                      view.items.isEmpty ? 'Пока пусто' : view.summary,
                      if (view.items.isNotEmpty)
                        'просмотрено ${view.completedCount} из ${view.items.length}',
                      if (average != null)
                        'средняя оценка ${formatAverage(average)}',
                    ].join(' · '),
                    style: const TextStyle(color: AppColors.muted),
                  ),
                  if (view.items.isNotEmpty) ...[
                    const SizedBox(height: 22),
                    StatusTabs(
                      current: _tab,
                      counts: countByStatus(view.items),
                      onChanged: (tab) => setState(() => _tab = tab),
                    ),
                  ],
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: padding.copyWith(top: 0),
            sliver: view.items.isEmpty
                ? const SliverToBoxAdapter(
                    child: EmptyState(
                      title: 'В группе пока пусто',
                      text:
                          'Добавить: «…» → «Группы…» на странице тайтла или '
                          'франшизы.',
                    ),
                  )
                : units.isEmpty
                ? SliverToBoxAdapter(
                    child: EmptyState(
                      title: 'В «${_tab!.label}» пусто',
                      text: 'Нет тайтлов с этим статусом.',
                      actions: [
                        OutlinedButton(
                          onPressed: () => setState(() => _tab = null),
                          child: const Text('Показать все'),
                        ),
                      ],
                    ),
                  )
                : SliverGrid.builder(
                    gridDelegate: posterGridDelegate(
                      width: constraints.maxWidth - padding.horizontal,
                      bodyHeight: _bodyHeight,
                    ),
                    itemCount: units.length,
                    itemBuilder: (context, index) =>
                        _MemberCard(view: view, unit: units[index], tab: _tab),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Карточка в группе.
class _MemberCard extends ConsumerStatefulWidget {
  const _MemberCard({required this.view, required this.unit, this.tab});

  final GroupView view;
  final LibraryUnit unit;
  final WatchStatus? tab;

  @override
  ConsumerState<_MemberCard> createState() => _MemberCardState();
}

class _MemberCardState extends ConsumerState<_MemberCard> {
  final _menu = MenuController();

  @override
  Widget build(BuildContext context) {
    const backLabel = 'Назад к группе';
    final unit = widget.unit;
    final (String title, String addKey, Set<String> keys) = switch (unit) {
      TitleUnit(:final item) => (
        item.anime.title,
        memberKeyOf(item),
        {memberKeyOf(item), 'a:${item.anime.id}'},
      ),
      FranchiseUnit(:final key, :final name, :final items) => (
        name,
        franchiseMemberKey(key),
        {
          franchiseMemberKey(key),
          for (final item in items) 'a:${item.anime.id}',
        },
      ),
    };

    return AppMenuAnchor(
      controller: _menu,
      style: AppTheme.menuStyle,
      menuChildren: [
        AppMenuItem(
          label: 'Убрать из группы',
          icon: LucideIcons.folderMinus,
          color: AppColors.dangerText,
          onPressed: () => setGroupMembership(
            ref,
            groupId: widget.view.group.id,
            groupName: widget.view.group.name,
            title: title,
            addKey: addKey,
            keys: keys,
            member: false,
          ),
        ),
      ],
      child: GestureDetector(
        onSecondaryTapDown: (details) =>
            _menu.open(position: details.localPosition),
        child: switch (unit) {
          TitleUnit(:final item) => LibraryTitleCard(
            item: item,
            backLabel: backLabel,
          ),
          FranchiseUnit() => FranchiseCard(
            unit: unit,
            tab: widget.tab,
            backLabel: backLabel,
          ),
        },
      ),
    );
  }
}

class _MoreMenu extends ConsumerWidget {
  const _MoreMenu({required this.view});

  final GroupView view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppMenuAnchor(
      style: AppTheme.menuStyle,
      alignmentOffset: const Offset(-216, 6),
      menuChildren: [
        AppMenuItem(
          label: 'Переименовать…',
          icon: LucideIcons.pencil,
          color: AppColors.menuItemText,
          onPressed: () => renameGroup(
            context,
            ref,
            id: view.group.id,
            current: view.group.name,
          ),
        ),
        ?discordGroupItem(context, ref, view),
        const Divider(height: 9, thickness: 1, color: Color(0xFF35323C)),
        AppMenuItem(
          label: 'Удалить группу',
          icon: LucideIcons.trash2,
          color: AppColors.dangerText,
          onPressed: () {
            deleteGroup(ref, id: view.group.id, name: view.group.name);
            Navigator.of(context).maybePop();
          },
        ),
      ],
      builder: (context, controller, _) => IconButton(
        tooltip: 'Ещё',
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
        icon: const Icon(LucideIcons.ellipsis, size: 20),
      ),
    );
  }
}
