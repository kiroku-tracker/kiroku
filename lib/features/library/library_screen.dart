import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app_section.dart';
import '../../core/labels.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/card_grid.dart';
import '../../core/widgets/fresh_badge.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/panel.dart';
import '../../core/widgets/poster_card.dart';
import '../../data/database/app_database.dart';
import '../../data/database/franchise_rules.dart';
import '../../data/database/library_repository.dart';
import '../../data/database/settings_repository.dart';
import '../../data/database/watch_status.dart';
import '../../data/providers.dart';
import '../franchise/franchise_card.dart';
import '../import/shikimori_import.dart';
import '../notifications/notice_center.dart';
import '../title/title_screen.dart';
import 'continue_watching.dart';
import 'entry_status_button.dart';
import 'library_filter.dart';
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
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _resetFilters(LibraryPrefs prefs) {
    _query.clear();
    setState(() => _tab = null);
    ref
        .read(libraryPrefsProvider.notifier)
        .change((_) => prefs.copyWith(kind: KindFilter.all));
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(libraryItemsProvider);
    final prefs = ref.watch(libraryPrefsProvider).value ?? const LibraryPrefs();
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
      data: (all) {
        if (all.isEmpty) {
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

        final visible = libraryUnits(
          all,
          status: _tab,
          query: _query.text,
          kind: prefs.kind,
          sort: prefs.sort,
          groupFranchises: prefs.groupFranchises,
          franchises: ref.watch(franchisesProvider).value ?? const {},
        );
        final showContinue =
            ref.watch(appPrefsProvider).value?.showContinue ?? true;
        final continueItems =
            showContinue &&
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
                        const PageHeader(
                          title: 'Библиотека',
                          trailing: NoticesButton(),
                        ),
                        const SizedBox(height: 18),
                        if (continueItems.isNotEmpty) ...[
                          ContinueWatching(items: continueItems),
                          const SizedBox(height: 26),
                        ],
                        StatusTabs(
                          current: _tab,
                          counts: countByStatus(all),
                          onChanged: (tab) => setState(() => _tab = tab),
                        ),
                        const SizedBox(height: 14),
                        LibraryFilterBar(
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
                      ? SliverToBoxAdapter(child: _emptyState(prefs))
                      : prefs.view == LibraryView.table
                      ? SliverToBoxAdapter(
                          child: LibraryTable(units: visible, tab: _tab),
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
                                ),
                                final FranchiseUnit unit => FranchiseCard(
                                  unit: unit,
                                  tab: _tab,
                                  backLabel: 'Назад в библиотеку',
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

  Widget _emptyState(LibraryPrefs prefs) {
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
    final tab = _tab;
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
  });

  final LibraryItem item;

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
    return PosterCard(
      posterUrl: anime.posterUrl,
      posterBadge: EntryStatusButton(
        animeId: anime.id,
        title: anime.title,
        status: item.status,
        release: release,
        compact: true,
      ),
      posterBadgeEnd: fresh > 0 ? FreshBadge(count: fresh) : null,
      title: anime.title,
      subtitle: franchiseName != null
          ? 'Из франшизы «$franchiseName»'
          : anime.russian.isNotEmpty
          ? anime.name
          : '',
      meta: Text(
        progressLabel(
          release,
          item.progress.watched,
          cycleNumber: item.progress.cycleNumber,
        ),
      ),
      extra: ProgressBar(
        value: available == 0 ? 0 : item.progress.watched / available,
      ),
      onTap: () => openTitle(context, animeId: anime.id, backLabel: backLabel),
      menu: () => titleCardMenu(ref, item),
      action: WatchNextButton(
        anime: anime,
        status: item.status,
        next: item.progress.nextEpisode,
        watched: item.progress.watched,
      ),
    );
  }
}
