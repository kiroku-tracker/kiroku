import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/poster.dart';
import '../../data/providers.dart';
import '../../data/shikimori/anime_info.dart';

/// Окно с числом отмеченных серий.
Future<int?> askEpisodeCount(
  BuildContext context, {
  required int current,
  required int total,
}) => showDialog<int>(
  context: context,
  builder: (_) => _EpisodesDialog(current: current, total: total),
);

class _EpisodesDialog extends StatefulWidget {
  const _EpisodesDialog({required this.current, required this.total});

  final int current;
  final int total;

  @override
  State<_EpisodesDialog> createState() => _EpisodesDialogState();
}

class _EpisodesDialogState extends State<_EpisodesDialog> {
  late final _field = TextEditingController(text: '${widget.current}');

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  void _done() {
    final value = int.tryParse(_field.text.trim()) ?? widget.current;
    final limit = widget.total > 0 ? widget.total : value;
    Navigator.of(context).pop(value.clamp(0, limit));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Отмеченные серии'),
      content: SizedBox(
        width: 280,
        child: TextField(
          controller: _field,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: 'Серий',
            helperText: widget.total > 0 ? 'Всего ${widget.total}' : null,
          ),
          onSubmitted: (_) => _done(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        FilledButton(onPressed: _done, child: const Text('Готово')),
      ],
    );
  }
}

/// Окно поиска тайтла на Shikimori.
Future<AnimeInfo?> pickAnime(BuildContext context, {String initial = ''}) =>
    showDialog<AnimeInfo>(
      context: context,
      builder: (_) => _PickDialog(initial: initial),
    );

class _PickDialog extends ConsumerStatefulWidget {
  const _PickDialog({required this.initial});

  final String initial;

  @override
  ConsumerState<_PickDialog> createState() => _PickDialogState();
}

class _PickDialogState extends ConsumerState<_PickDialog> {
  late final _field = TextEditingController(text: widget.initial);
  List<AnimeInfo>? _found;
  var _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initial.isNotEmpty) _search();
  }

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _field.text.trim();
    if (query.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final found = await ref.read(shikimoriClientProvider).searchAnimes(query);
      if (mounted) setState(() => _found = found);
    } catch (error) {
      if (mounted) setState(() => _error = 'Shikimori не ответил: $error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final found = _found;
    return AlertDialog(
      title: const Text('Выбрать тайтл'),
      content: SizedBox(
        width: 460,
        height: 420,
        child: Column(
          children: [
            TextField(
              controller: _field,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Название на Shikimori',
              ),
              onSubmitted: (_) => _search(),
            ),
            const SizedBox(height: 12),
            if (_loading) const LinearProgressIndicator(),
            if (_error != null)
              Text(
                _error!,
                style: const TextStyle(color: AppColors.dangerText),
              ),
            if (found != null && found.isEmpty && !_loading)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Ничего не найдено',
                  style: TextStyle(color: AppColors.muted),
                ),
              ),
            Expanded(
              child: ListView(
                children: [
                  for (final anime in found ?? const <AnimeInfo>[])
                    ListTile(
                      dense: true,
                      leading: SizedBox(
                        width: 32,
                        child: Poster(
                          url: anime.posterUrl,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      title: Text(anime.title),
                      subtitle: Text(
                        [
                          if (anime.year case final year?) '$year',
                          ?anime.kind,
                        ].join(' · '),
                      ),
                      onTap: () => Navigator.of(context).pop(anime),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        FilledButton(onPressed: _search, child: const Text('Найти')),
      ],
    );
  }
}
