import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/labels.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/card_grid.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/panel.dart';
import '../../data/database/app_database.dart';
import '../../data/database/library_repository.dart';
import '../../data/database/watch_status.dart';
import '../../data/providers.dart';
import '../library/library_toolbar.dart';
import '../search/search_result_card.dart';
import 'discover_logic.dart';
import 'swipe_deck.dart';

const _backLabel = 'Назад к «Что посмотреть»';

/// Раздел «Что посмотреть»: продолжения начатых франшиз и похожее на
/// просмотренное, сеткой или карточками по одной.
class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  bool _similar = false;
  bool _cards = true;
  List<SimilarPick>? _picks;
  bool _loading = false;
  String? _error;

  Future<void> _load(List<LibraryItem> library) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final picks = await loadSimilarPicks(
        ref.read(shikimoriClientProvider),
        library,
      );
      if (!mounted) return;
      setState(() {
        _picks = picks;
        _loading = false;
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Shikimori не ответил';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final library = ref.watch(libraryItemsProvider).value;
    final continuations = ref.watch(franchiseContinuationsProvider);
    final statuses = ref.watch(libraryStatusesProvider).value ?? const {};
    final hidden = ref.watch(discoverHiddenProvider).value ?? const {};
    if (_similar &&
        _picks == null &&
        !_loading &&
        _error == null &&
        library != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_loading) _load(library);
      });
    }
    final picks = _picks;
    final List<DiscoverEntry>? entries = _similar
        ? picks == null
              ? null
              : [
                  for (final pick in picks)
                    if (!hidden.contains(pick.anime.id))
                      (
                        anime: pick.anime,
                        reason: pick.because.length > 1
                            ? 'Похоже на «${pick.because[0]}» и '
                                  '«${pick.because[1]}»'
                            : 'Похоже на «${pick.because.first}»',
                      ),
                ]
        : [
            for (final next in continuations)
              if (!hidden.contains(next.anime.id))
                (
                  anime: next.anime.toInfo(),
                  reason: next.left > 1
                      ? '«${next.franchise}» · не смотрели ${next.left} '
                            '${plural(next.left, 'часть', 'части', 'частей')}'
                      : '«${next.franchise}»',
                ),
          ];

    final padding = pagePadding();
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth - padding.horizontal;
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: padding.copyWith(bottom: 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PageHeader(
                      title: 'Что посмотреть',
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TabChip(
                            icon: LucideIcons.galleryHorizontalEnd,
                            label: 'Карточки',
                            active: _cards,
                            onTap: () => setState(() => _cards = true),
                          ),
                          const SizedBox(width: 7),
                          TabChip(
                            icon: LucideIcons.layoutGrid,
                            label: 'Сетка',
                            active: !_cards,
                            onTap: () => setState(() => _cards = false),
                          ),
                          if (_similar && library != null) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              tooltip: 'Подобрать заново',
                              onPressed: _loading ? null : () => _load(library),
                              icon: const Icon(LucideIcons.refreshCw, size: 18),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: [
                        TabChip(
                          icon: LucideIcons.layers3,
                          label: 'Продолжения франшиз',
                          count: _similar
                              ? null
                              : entries?.length ?? continuations.length,
                          active: !_similar,
                          onTap: () => setState(() => _similar = false),
                        ),
                        TabChip(
                          icon: LucideIcons.sparkles,
                          label: 'Похожее',
                          count: _similar ? entries?.length : null,
                          active: _similar,
                          onTap: () => setState(() => _similar = true),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _similar
                          ? 'Похоже на просмотренное с высокими оценками'
                          : 'Вышедшие части начатых франшиз',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: padding.copyWith(top: 0),
              sliver: _body(width, entries, statuses, library),
            ),
          ],
        );
      },
    );
  }

  Widget _body(
    double width,
    List<DiscoverEntry>? entries,
    Map<int, WatchStatus> statuses,
    List<LibraryItem>? library,
  ) {
    if (_similar) {
      if (_error case final error?) {
        return SliverToBoxAdapter(
          child: EmptyState(
            title: 'Не получилось подобрать',
            text: error,
            actions: [
              if (library != null)
                OutlinedButton.icon(
                  onPressed: () => _load(library),
                  icon: const Icon(LucideIcons.rotateCcw),
                  label: const Text('Повторить'),
                ),
            ],
          ),
        );
      }
      if (_loading || entries == null) {
        return const SliverToBoxAdapter(
          child: Row(
            children: [
              SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text(
                'Подбираем похожее…',
                style: TextStyle(color: AppColors.muted),
              ),
            ],
          ),
        );
      }
    }
    final list = entries ?? const <DiscoverEntry>[];
    if (list.isEmpty) {
      return SliverToBoxAdapter(
        child: _similar
            ? const EmptyState(
                title: 'Пока не из чего подбирать',
                text:
                    'Похожее подбирается по просмотренным тайтлам с оценками.',
              )
            : const EmptyState(
                title: 'Начатые франшизы досмотрены',
                text:
                    'Здесь появятся вышедшие части франшиз, которые ещё не '
                    'смотрели.',
              ),
      );
    }
    if (_cards) {
      return SliverToBoxAdapter(
        child: SwipeDeck(
          key: ValueKey(_similar),
          entries: list,
          backLabel: _backLabel,
        ),
      );
    }
    return SliverGrid.builder(
      gridDelegate: posterGridDelegate(
        width: width,
        bodyHeight: SearchResultCard.bodyHeight,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) => SearchResultCard(
        anime: list[index].anime,
        status: statuses[list[index].anime.id],
        reason: list[index].reason,
        backLabel: _backLabel,
      ),
    );
  }
}
