import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app_section.dart';
import '../../core/labels.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/card_grid.dart';
import '../../core/widgets/card_marks.dart';
import '../../core/widgets/fresh_badge.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/panel.dart';
import '../../core/widgets/poster_card.dart';
import '../../data/database/app_database.dart';
import '../../data/database/franchise_rules.dart';
import '../../data/database/library_repository.dart';
import '../../data/database/settings_repository.dart';
import '../../data/database/user_groups_repository.dart';
import '../../data/database/watch_status.dart';
import '../../data/providers.dart';
import '../franchise/franchise_card.dart';
import '../groups/group_actions.dart';
import '../import/shikimori_import.dart';
import '../notifications/notice_center.dart';
import '../title/title_screen.dart';
import 'continue_watching.dart';
import 'entry_status_button.dart';
import 'library_filter.dart';
import 'library_header.dart';
import 'library_table.dart';
import 'library_toolbar.dart';
import '../watch/watch_next_button.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  static final _bodyHeight = PosterCard.bodyHeight(withExtra: true);

  WatchStatus? _tab = WatchStatus.watching;

  /// Открыта вкладка «Избранное».
  bool _favorites = false;
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _resetFilters(LibraryPrefs prefs) {
    _query.clear();
    setState(() {
      _tab = null;
      _favorites = false;
    });
    ref
        .read(libraryPrefsProvider.notifier)
        .change((_) => prefs.copyWith(kind: KindFilter.all));
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(libraryItemsProvider);
    final prefs = ref.watch(libraryPrefsProvider).value ?? const LibraryPrefs();
    final groupId = ref.watch(libraryGroupProvider);
    final groupMembers = groupId == null
        ? null
        : ref.watch(groupMembersProvider).value?[groupId] ?? const <String>{};
    final group = groupId == null
        ? null
        : ref
              .watch(userGroupsProvider)
              .value
              ?.where((group) => group.id == groupId)
              .firstOrNull;
    final padding = pagePadding();

    return items.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Padding(
        padding: padding,
        child: Text(
          'Не удалось открыть библиотеку: $error',
          style: const TextStyle(color: AppColors.dangerText),
        ),
      ),
      data: (library) {
        final all = groupMembers == null
            ? library
            : groupItems(library, groupMembers);
        if (library.isEmpty) {
          return SingleChildScrollView(
            padding: padding,
            child: Column(
              children: [
                const PageHeader(
                  title: 'Библиотека',
                  trailing: NoticesButton(),
                ),
                const SizedBox(height: 18),
                EmptyState(
                  title: 'Библиотека пока пустая',
                  text:
                      'Тайтлы добавляются через поиск или импорт с Shikimori.',
                  actions: [
                    FilledButton.icon(
                      onPressed: () => ref
                          .read(appSectionProvider.notifier)
                          .open(AppSection.search),
                      icon: const Icon(LucideIcons.search),
                      label: const Text('Перейти к поиску'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => showShikimoriImportDialog(context),
                      icon: const Icon(LucideIcons.download),
                      label: const Text('Импорт из Shikimori'),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        final franchises = ref.watch(franchisesProvider).value ?? const {};
        final tab = _favorites ? null : _tab;
        final visible = libraryUnits(
          all,
          status: _tab,
          query: _query.text,
          kind: prefs.kind,
          sort: prefs.sortIn(tab),
          groupFranchises: prefs.groupFranchises,
          franchises: franchises,
          favorites: _favorites,
          planned: prefs.planned,
        );
        final favoriteCount = libraryUnits(
          all,
          status: null,
          query: '',
          kind: KindFilter.all,
          sort: prefs.sort,
          groupFranchises: prefs.groupFranchises,
          franchises: franchises,
          favorites: true,
        ).length;
        final showContinue =
            ref.watch(appPrefsProvider).value?.showContinue ?? true;
        final continueItems =
            showContinue &&
                !_favorites &&
                (_tab == WatchStatus.watching || _tab == null) &&
                _query.text.isEmpty &&
                prefs.kind == KindFilter.all
            ? continueWatching(all)
            : const <LibraryItem>[];

        return LayoutBuilder(
          builder: (context, constraints) {
            final contentWidth = constraints.maxWidth - padding.horizontal;
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: padding.copyWith(bottom: 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const LibraryHeader(),
                        const SizedBox(height: 18),
                        if (continueItems.isNotEmpty) ...[
                          ContinueWatching(items: continueItems),
                          const SizedBox(height: 26),
                        ],
                        StatusTabs(
                          current: _tab,
                          counts: countByStatus(all),
                          onChanged: (tab) => setState(() {
                            _tab = tab;
                            _favorites = false;
                          }),
                          favorites: _favorites,
                          favoriteCount: favoriteCount,
                          onFavorites: () => setState(() => _favorites = true),
                        ),
                        if (tab == WatchStatus.planned) ...[
                          const SizedBox(height: 10),
                          PlannedTabs(
                            current: prefs.planned,
                            counts: plannedCounts(all),
                            onChanged: (filter) => ref
                                .read(libraryPrefsProvider.notifier)
                                .change(
                                  (prefs) => prefs.copyWith(planned: filter),
                                ),
                          ),
                        ],
                        const SizedBox(height: 14),
                        LibraryFilterBar(
                          tab: tab,
                          queryController: _query,
                          onQueryChanged: (_) => setState(() {}),
                          prefs: prefs,
                          onPrefsChanged: (next) => ref
                              .read(libraryPrefsProvider.notifier)
                              .change((_) => next),
                        ),
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: padding.copyWith(top: 0),
                  sliver: visible.isEmpty
                      ? SliverToBoxAdapter(
                          child: _emptyState(
                            prefs,
                            groupEmpty: groupMembers != null && all.isEmpty,
                          ),
                        )
                      : prefs.view == LibraryView.table
                      ? SliverToBoxAdapter(
                          child: LibraryTable(units: visible, tab: tab),
                        )
                      : SliverGrid.builder(
                          gridDelegate: posterGridDelegate(
                            width: contentWidth,
                            bodyHeight: _bodyHeight,
                          ),
                          itemCount: visible.length,
                          itemBuilder: (context, index) =>
                              switch (visible[index]) {
                                final TitleUnit unit => LibraryTitleCard(
                                  item: unit.item,
                                  franchiseName: unit.franchiseName,
                                  group: group,
                                ),
                                final FranchiseUnit unit => FranchiseCard(
                                  unit: unit,
                                  backLabel: 'Назад в библиотеку',
                                  group: group,
                                ),
                              },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _emptyState(LibraryPrefs prefs, {bool groupEmpty = false}) {
    if (groupEmpty) {
      return const EmptyState(
        title: 'В группе пока пусто',
        text: 'Тайтлы и франшизы попадают в группу через меню «⋯» на их странице.',
      );
    }
    final filtered = _query.text.isNotEmpty || prefs.kind != KindFilter.all;
    if (filtered) {
      return EmptyState(
        title: 'Ничего не найдено',
        text: 'По этому запросу и фильтрам тайтлов нет.',
        actions: [
          OutlinedButton.icon(
            onPressed: () => _resetFilters(prefs),
            icon: const Icon(LucideIcons.rotateCcw),
            label: const Text('Сбросить фильтры'),
          ),
        ],
      );
    }
    if (_favorites) {
      return const EmptyState(
        title: 'В избранном пока пусто',
        text: 'Сюда попадают тайтлы и франшизы с сердечком на их странице.',
      );
    }
    final tab = _tab;
    if (tab == WatchStatus.planned && prefs.planned != PlannedFilter.all) {
      return EmptyState(
        title: 'В «${prefs.planned.label}» пока пусто',
        text: switch (prefs.planned) {
          PlannedFilter.available =>
            'Здесь будут тайтлы, которые вышли целиком.',
          PlannedFilter.airing =>
            'Здесь будут тайтлы, у которых выходят серии.',
          _ => 'Здесь будут анонсы.',
        },
      );
    }
    return EmptyState(
      title: tab == null ? 'Пусто' : 'В «${tab.label}» пока пусто',
      text: switch (tab) {
        WatchStatus.watching =>
          'Можно начать смотреть что-нибудь из «Хочу посмотреть».',
        _ => 'Здесь появятся тайтлы с этим статусом.',
      },
      actions: [
        if (tab == WatchStatus.watching)
          OutlinedButton.icon(
            onPressed: () => setState(() => _tab = WatchStatus.planned),
            icon: const Icon(LucideIcons.clock3),
            label: const Text('Открыть «Хочу посмотреть»'),
          ),
      ],
    );
  }
}

/// Карточка тайтла в библиотеке.
class LibraryTitleCard extends ConsumerWidget {
  const LibraryTitleCard({
    super.key,
    required this.item,
    this.franchiseName,
    this.backLabel = 'Назад в библиотеку',
    this.group,
  });

  final LibraryItem item;

  /// Открытая в библиотеке группа: в меню есть «Убрать из группы».
  final UserGroup? group;

  final String backLabel;

  final String? franchiseName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final anime = item.anime;
    final release = anime.release;
    final available = release.availableEpisodes;
    final fresh = release.isOngoing && item.status == WatchStatus.watching
        ? unwatchedAired(item)
        : 0;
    final views = ref.watch(viewsProvider).value?[anime.id]?.views ?? 0;
    return PosterCard(
      posterUrl: anime.posterUrl,
      posterBadge: Wrap(
        spacing: 6,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          EntryStatusButton(
            animeId: anime.id,
            title: anime.title,
            status: item.status,
            release: release,
            compact: true,
          ),
          if (views > 1) ViewsBadge(count: views),
        ],
      ),
      posterBadgeEnd: fresh > 0 ? FreshBadge(count: fresh) : null,
      title: anime.title,
      subtitle: franchiseName != null
          ? 'Из франшизы «$franchiseName»'
          : anime.russian.isNotEmpty
          ? anime.name
          : '',
      meta: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text:
                  (item.status == WatchStatus.planned &&
                          item.progress.watched == 0
                      ? _plannedLabel(anime)
                      : null) ??
                  progressLabel(
                    release,
                    item.progress.watched,
                    // У просмотренного номер просмотра уже на плашке постера.
                    cycleNumber: item.status == WatchStatus.completed
                        ? 1
                        : item.progress.cycleNumber,
                  ),
            ),
            if (item.entry.score case final score?) ...[
              const TextSpan(text: '  ·  '),
              const WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Icon(
                  LucideIcons.star,
                  size: 13,
                  color: Color(0xFFFFC857),
                ),
              ),
              TextSpan(text: ' $score'),
            ],
          ],
        ),
      ),
      extra: ProgressBar(
        value: available == 0 ? 0 : item.progress.watched / available,
      ),
      onTap: () => openTitle(context, animeId: anime.id, backLabel: backLabel),
      menu: () => [
        ...titleCardMenu(ref, item),
        if (group case final group?)
          removeFromGroupItem(
            ref,
            group: group,
            title: anime.title,
            addKey: memberKeyOf(item),
            keys: {memberKeyOf(item), 'a:${anime.id}'},
          ),
      ],
      favorite: item.entry.favorite,
      onFavorite: () => ref
          .read(libraryRepositoryProvider)
          .setFavorite(anime.id, !item.entry.favorite),
      action: WatchNextButton(
        anime: anime,
        status: item.status,
        next: item.progress.nextEpisode,
        watched: item.progress.watched,
        whenWatched: CardFacts(
          years: anime.year?.toString(),
          genres: anime.genreList,
        ),
      ),
    );
  }
}

/// Подпись «Хочу посмотреть»: сколько серий вышло и когда следующая или
/// премьера.
String? _plannedLabel(Anime anime) {
  final release = anime.release;
  final next = anime.nextEpisodeAt?.toLocal();
  final now = DateTime.now();
  final soon = next == null || next.isBefore(now)
      ? null
      : next.year == now.year
      ? formatDayMonth(next)
      : formatDate(next);
  if (release.isAnnounced) {
    final airedOn = anime.airedOn;
    if (soon != null) return 'Премьера: $soon';
    return airedOn == null ? null : 'Премьера: ${formatAiredOn(airedOn)}';
  }
  if (!release.isOngoing) return null;
  final aired = release.episodes > 0
      ? 'Вышло ${release.aired} из ${release.episodes}'
      : 'Вышло ${release.aired}';
  return soon == null ? aired : '$aired · следующая $soon';
}
