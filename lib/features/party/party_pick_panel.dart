import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/labels.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/poster.dart';
import '../../data/database/app_database.dart';
import '../../data/database/library_repository.dart';
import '../../data/database/watch_status.dart';
import '../../data/providers.dart';
import '../../data/shikimori/anime_info.dart';
import '../watch/watch_next_button.dart';

/// Поиск тайтла для комнаты: без запроса «Смотрю» из библиотеки, по
/// названию библиотека и Shikimori. Выбранный тайтл уходит в [onPick].
class PartyPickPanel extends ConsumerStatefulWidget {
  const PartyPickPanel({super.key, required this.onPick});

  final ValueChanged<Anime> onPick;

  @override
  ConsumerState<PartyPickPanel> createState() => _PartyPickPanelState();
}

class _PartyPickPanelState extends ConsumerState<PartyPickPanel> {
  final _query = TextEditingController();
  Timer? _debounce;
  String _text = '';
  List<AnimeInfo> _found = const [];
  bool _loading = false;
  String? _error;
  int _request = 0;

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    super.dispose();
  }

  void _changed(String value) {
    final text = value.trim();
    _debounce?.cancel();
    setState(() {
      _text = text;
      _error = null;
      if (text.length < 2) {
        _found = const [];
        _loading = false;
        _request++;
      }
    });
    if (text.length >= 2) {
      _debounce = Timer(const Duration(milliseconds: 350), _search);
    }
  }

  Future<void> _search() async {
    final text = _text;
    final request = ++_request;
    setState(() => _loading = true);
    try {
      final found = await ref
          .read(shikimoriClientProvider)
          .searchAnimes(text, limit: 12);
      if (!mounted || request != _request) return;
      setState(() {
        _found = found;
        _loading = false;
      });
    } on Object {
      if (!mounted || request != _request) return;
      setState(() {
        _loading = false;
        _error = 'Shikimori не ответил';
      });
    }
  }

  void _finish(Anime anime) {
    Navigator.of(context).pop();
    widget.onPick(anime);
  }

  Future<void> _pickInfo(AnimeInfo info) async {
    final repository = ref.read(libraryRepositoryProvider);
    await repository.saveAnime(info);
    final anime = (await repository.animesByIds([info.id]))[info.id];
    if (!mounted || anime == null) return;
    _finish(anime);
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(libraryItemsProvider).value ?? const [];
    final query = _text.toLowerCase();
    final library = [
      for (final item in items)
        if (query.isEmpty
            ? item.status == WatchStatus.watching
            : item.anime.title.toLowerCase().contains(query) ||
                  item.anime.name.toLowerCase().contains(query))
          item,
    ].take(query.isEmpty ? 8 : 5).toList();
    final known = {for (final item in library) item.anime.id};
    final online = [
      for (final info in _found)
        if (!known.contains(info.id)) info,
    ];
    void first() {
      if (library.isNotEmpty) {
        _finish(library.first.anime);
      } else if (online.isNotEmpty) {
        _pickInfo(online.first);
      }
    }

    return Material(
      color: AppColors.menu,
      elevation: 12,
      shadowColor: const Color(0x85000000),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.menuBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: TextField(
              controller: _query,
              autofocus: true,
              onChanged: _changed,
              onSubmitted: (_) => first(),
              decoration: const InputDecoration(
                hintText: 'Название тайтла',
                isDense: true,
                prefixIcon: Icon(LucideIcons.search, size: 18),
              ),
            ),
          ),
          if (_loading)
            const LinearProgressIndicator(
              minHeight: 2,
              backgroundColor: Colors.transparent,
              color: AppColors.accentText,
            )
          else
            const SizedBox(height: 2),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: 8),
              children: [
                if (library.isNotEmpty) ...[
                  _Heading(query.isEmpty ? 'Смотрю' : 'В библиотеке'),
                  for (final item in library)
                    _PickRow(
                      posterUrl: item.anime.posterUrl,
                      title: item.anime.title,
                      subtitle: _nextLabel(item),
                      onTap: () => _finish(item.anime),
                    ),
                ],
                if (online.isNotEmpty) ...[
                  const _Heading('Shikimori'),
                  for (final info in online)
                    _PickRow(
                      posterUrl: info.posterUrl,
                      title: info.russian.isNotEmpty ? info.russian : info.name,
                      subtitle: [
                        kindLabel(info.kind),
                        if ((info.airedOn?.length ?? 0) >= 4)
                          info.airedOn!.substring(0, 4),
                      ].join(' · '),
                      onTap: () => _pickInfo(info),
                    ),
                ],
                if (_error case final error?)
                  _Note(error)
                else if (library.isEmpty && online.isEmpty && !_loading)
                  _Note(
                    query.isEmpty ? 'Начните вводить название' : 'Не найдено',
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Какая серия следующая у тайтла из библиотеки.
  static String _nextLabel(LibraryItem item) {
    final next = WatchNext.of(
      item.anime,
      status: item.status,
      next: item.progress.nextEpisode,
      watched: item.progress.watched,
    );
    final episode = next.episode;
    return episode == null ? next.label : 'Серия $episode';
  }
}

/// Заголовок группы результатов.
class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.muted,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Пояснение вместо результатов.
class _Note extends StatelessWidget {
  const _Note(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Text(text, style: const TextStyle(color: AppColors.muted)),
    );
  }
}

/// Строка результата: постер, название, подпись.
class _PickRow extends StatelessWidget {
  const _PickRow({
    required this.posterUrl,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String? posterUrl;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      hoverColor: AppColors.menuItemHover,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            SizedBox(
              width: 34,
              height: 48,
              child: posterUrl == null
                  ? DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.poster,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    )
                  : Poster(
                      url: posterUrl,
                      borderRadius: BorderRadius.circular(5),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.menuItemText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
