import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app_section.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/card_grid.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/select_button.dart';
import '../../data/providers.dart';
import '../../data/shikimori/anime_info.dart';
import '../../data/shikimori/anime_query.dart';
import 'franchise_hit.dart';
import 'search_result_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  static const _debounce = Duration(milliseconds: 400);
  static const _pageSize = 40;

  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _scroll = ScrollController();
  Timer? _debounceTimer;
  int _requestId = 0;

  int _seasonOffset = 0;
  SearchKind _kind = SearchKind.all;
  SearchStatus _status = SearchStatus.all;
  AnimeGenre? _genre;
  SearchYear _year = SearchYear.any;
  SearchOrder _order = SearchOrder.popularity;

  bool _loading = false;
  bool _loadingMore = false;
  bool _hasMore = false;
  int _page = 1;
  String? _error;
  List<AnimeInfo> _results = const [];

  AnimeQuery? _shown;

  String get _text => _controller.text.trim();
  bool get _searching => _text.length >= 2;
  AnimeSeason get _season =>
      AnimeSeason.of(DateTime.now()).shift(_seasonOffset);

  AnimeQuery get _query => AnimeQuery(
    search: _searching ? _text : '',
    season: _searching ? _year.code : _season.code,
    kind: _kind,
    status: _status,
    genre: _genre,
    order: _order,
  );

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _reload();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onChanged(String _) {
    _debounceTimer?.cancel();
    setState(() {}); // крестик очистки и подпись над результатами
    if (_query == _shown) return;
    if (_searching) {
      _debounceTimer = Timer(_debounce, _reload);
    } else {
      _reload();
    }
  }

  void _clear() {
    _controller.clear();
    _onChanged('');
    _focusNode.requestFocus();
  }

  /// Меняет фильтр и загружает заново.
  void _apply(VoidCallback change) {
    setState(change);
    _reload();
  }

  void _onScroll() {
    if (_scroll.position.extentAfter < 800) _loadMore();
  }

  Future<void> _reload() async {
    final query = _query;
    final requestId = ++_requestId;
    setState(() {
      _loading = true;
      _loadingMore = false;
      _error = null;
    });
    try {
      final results = await ref
          .read(shikimoriClientProvider)
          .browseAnimes(query, limit: _pageSize);
      if (!mounted || requestId != _requestId) return;
      _refreshLibrary(results);
      setState(() {
        _results = results;
        _shown = query;
        _page = 1;
        _hasMore = results.length == _pageSize;
        _loading = false;
      });
      if (_scroll.hasClients) _scroll.jumpTo(0);
    } catch (error) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _error = error is TimeoutException
            ? 'Shikimori не ответил за 15 секунд.'
            : 'Не удалось загрузить: $error';
        _loading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    final query = _shown;
    if (query == null || !_hasMore || _loading || _loadingMore) return;
    final requestId = _requestId;
    setState(() => _loadingMore = true);
    try {
      final more = await ref
          .read(shikimoriClientProvider)
          .browseAnimes(query, page: _page + 1, limit: _pageSize);
      if (!mounted || requestId != _requestId) return;
      _refreshLibrary(more);
      final known = {for (final anime in _results) anime.id};
      setState(() {
        _results = [
          ..._results,
          for (final anime in more)
            if (!known.contains(anime.id)) anime,
        ];
        _page++;
        _hasMore = more.length == _pageSize;
        _loadingMore = false;
      });
    } catch (_) {
      if (mounted && requestId == _requestId) {
        setState(() => _loadingMore = false);
      }
    }
  }

  /// Обновляет тайтлы библиотеки из результатов.
  void _refreshLibrary(List<AnimeInfo> animes) {
    final statuses = ref.read(libraryStatusesProvider).value ?? const {};
    final repository = ref.read(libraryRepositoryProvider);
    for (final anime in animes) {
      if (statuses.containsKey(anime.id)) {
        unawaited(repository.saveAnime(anime));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(appSectionProvider, (_, section) {
      if (section == AppSection.search) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _focusNode.requestFocus(),
        );
      }
    });
    ref.listen(searchFocusProvider, (_, _) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
        _controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _controller.text.length,
        );
      });
    });

    final padding = pagePadding();
    return Column(
      children: [
        Padding(
          padding: padding.copyWith(bottom: 0),
          child: Row(
            children: [
              Expanded(child: _buildField()),
              const SizedBox(width: 10),
              SelectButton<SearchOrder>(
                icon: LucideIcons.arrowUpDown,
                tooltip: 'Сортировка',
                value: _order,
                options: SearchOrder.values,
                labelOf: (order) => order.label,
                onChanged: (order) => _apply(() => _order = order),
              ),
            ],
          ),
        ),
        Padding(
          padding: padding.copyWith(top: 14, bottom: 18),
          child: _buildFilters(),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) => CustomScrollView(
              controller: _scroll,
              slivers: _buildResults(
                padding.copyWith(top: 0),
                constraints.maxWidth - padding.horizontal,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildField() {
    return CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.escape): _clear},
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: _onChanged,
        onSubmitted: (_) {
          _debounceTimer?.cancel();
          if (_query != _shown) _reload();
        },
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Найти',
          prefixIcon: const Icon(LucideIcons.search, size: 18),
          suffixIcon: _loading
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : _controller.text.isEmpty
              ? null
              : IconButton(
                  onPressed: _clear,
                  tooltip: 'Очистить',
                  icon: const Icon(LucideIcons.x, size: 18),
                ),
        ),
      ),
    );
  }

  /// Сезон и фильтры.
  Widget _buildFilters() {
    final genres = ref.watch(animeGenresProvider).value ?? const [];
    return Row(
      children: [
        SizedBox(
          height: 40,
          child: _searching ? _searchTitle() : _seasonSwitcher(),
        ),
        const Spacer(),
        SelectButton<SearchKind>(
          icon: LucideIcons.filter,
          tooltip: 'Тип',
          value: _kind,
          options: SearchKind.values,
          labelOf: (kind) => kind.label,
          onChanged: (kind) => _apply(() => _kind = kind),
        ),
        const SizedBox(width: 8),
        SelectButton<SearchStatus>(
          icon: LucideIcons.radioTower,
          tooltip: 'Статус',
          value: _status,
          options: SearchStatus.values,
          labelOf: (status) => status.label,
          onChanged: (status) => _apply(() => _status = status),
        ),
        const SizedBox(width: 8),
        SelectButton<AnimeGenre?>(
          icon: LucideIcons.tag,
          tooltip: 'Жанр',
          value: _genre,
          options: [null, ...genres],
          labelOf: (genre) => genre?.name ?? 'Все жанры',
          onChanged: (genre) => _apply(() => _genre = genre),
        ),
        const SizedBox(width: 8),
        Opacity(
          opacity: _searching ? 1 : 0.45,
          child: IgnorePointer(
            ignoring: !_searching,
            child: SelectButton<SearchYear>(
              icon: LucideIcons.calendar,
              tooltip: 'Год',
              value: _year,
              options: SearchYear.options(DateTime.now()),
              labelOf: (year) => year.label,
              onChanged: (year) => _apply(() => _year = year),
            ),
          ),
        ),
      ],
    );
  }

  Widget _seasonSwitcher() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Предыдущий сезон',
          onPressed: () => _apply(() => _seasonOffset--),
          icon: const Icon(LucideIcons.chevronLeft),
        ),
        SizedBox(
          width: 130,
          child: Text(
            _season.label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ),
        IconButton(
          tooltip: 'Следующий сезон',
          onPressed: () => _apply(() => _seasonOffset++),
          icon: const Icon(LucideIcons.chevronRight),
        ),
        IconButton(
          tooltip: 'Текущий сезон',
          onPressed: _seasonOffset == 0
              ? null
              : () => _apply(() => _seasonOffset = 0),
          icon: const Icon(LucideIcons.calendarCheck),
        ),
      ],
    );
  }

  Widget _searchTitle() {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Результаты поиска',
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
      ),
    );
  }

  List<Widget> _buildResults(EdgeInsets padding, double contentWidth) {
    final textStyle = const TextStyle(color: AppColors.muted, fontSize: 15);
    Widget message(Widget child) => SliverPadding(
      padding: padding,
      sliver: SliverToBoxAdapter(child: child),
    );

    if (_error != null) {
      return [
        message(
          Row(
            children: [
              Flexible(child: Text(_error!, style: textStyle)),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _reload,
                icon: const Icon(LucideIcons.rotateCcw),
                label: const Text('Повторить'),
              ),
            ],
          ),
        ),
      ];
    }
    final shown = _shown;
    if (shown == null) return const [];
    if (_results.isEmpty) {
      return [
        message(
          Text(
            shown.search.isEmpty
                ? 'По этим фильтрам в сезоне ничего нет.'
                : 'По запросу «${shown.search}» ничего не найдено.',
            style: textStyle,
          ),
        ),
      ];
    }

    final statuses = ref.watch(libraryStatusesProvider).value ?? const {};
    final hits = shown.search.isEmpty
        ? const <({String key, List<AnimeInfo> animes})>[]
        : franchiseHits(_results);
    return [
      if (hits.isNotEmpty)
        SliverPadding(
          padding: padding.copyWith(bottom: 18),
          sliver: SliverList.separated(
            itemCount: hits.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) => FranchiseHit(
              key: ValueKey(hits[index].key),
              franchiseKey: hits[index].key,
              animes: hits[index].animes,
            ),
          ),
        ),
      SliverPadding(
        padding: padding.copyWith(bottom: _hasMore ? 0 : padding.bottom),
        sliver: SliverGrid.builder(
          gridDelegate: posterGridDelegate(
            width: contentWidth,
            bodyHeight: SearchResultCard.bodyHeight,
          ),
          itemCount: _results.length,
          itemBuilder: (context, index) {
            final anime = _results[index];
            return SearchResultCard(anime: anime, status: statuses[anime.id]);
          },
        ),
      ),
      if (_hasMore)
        SliverPadding(
          padding: padding.copyWith(top: 18),
          sliver: const SliverToBoxAdapter(
            child: Center(
              child: SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
        ),
    ];
  }
}
