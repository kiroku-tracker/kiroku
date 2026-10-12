import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/labels.dart';
import '../../core/theme/app_colors.dart';
import '../../data/database/app_database.dart';
import '../../data/database/status_action.dart';
import '../../data/providers.dart';
import '../../data/shikimori/anime_info.dart';
import '../franchise/franchise_screen.dart';
import '../franchise/watch_order_list.dart';
import '../library/library_actions.dart';

/// Франшизы в результатах поиска.
List<({String key, List<AnimeInfo> animes})> franchiseHits(
  List<AnimeInfo> results, {
  int limit = 2,
}) {
  final groups = <String, List<AnimeInfo>>{};
  for (final anime in results) {
    final key = anime.franchise;
    if (key == null || key.isEmpty) continue;
    groups.putIfAbsent(key, () => []).add(anime);
  }
  return [
    for (final MapEntry(:key, :value) in groups.entries)
      if (value.length >= 2) (key: key, animes: value),
  ].take(limit).toList();
}

/// Строка франшизы над результатами поиска.
class FranchiseHit extends ConsumerStatefulWidget {
  const FranchiseHit({
    super.key,
    required this.franchiseKey,
    required this.animes,
  });

  final String franchiseKey;

  final List<AnimeInfo> animes;

  @override
  ConsumerState<FranchiseHit> createState() => _FranchiseHitState();
}

class _FranchiseHitState extends ConsumerState<FranchiseHit> {
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    unawaited(_save());
  }

  Future<void> _save() async {
    final repository = ref.read(libraryRepositoryProvider);
    for (final anime in widget.animes) {
      await repository.saveAnime(anime);
    }
    if (mounted) setState(() => _saved = true);
  }

  @override
  Widget build(BuildContext context) {
    final key = widget.franchiseKey;
    final load = _saved ? ref.watch(franchiseLoadProvider(key)) : null;
    final library = ref.watch(libraryItemsProvider).value ?? const [];
    final order = ref.watch(watchOrderProvider(key)).value;
    final row = ref.watch(franchisesProvider).value?[key];
    final parts = franchiseParts(key, order, library);
    final ready = load != null && !load.isLoading && order != null;
    final missing = [
      for (final part in parts.main)
        if (part.item == null) part.anime,
    ];
    final name =
        row?.name ??
        row?.autoName ??
        parts.main.firstOrNull?.anime.title ??
        widget.animes.first.title;

    final String detail;
    if (!ready) {
      detail = 'Загрузка частей…';
    } else {
      final main = parts.main.length;
      detail = [
        '$main ${plural(main, 'основная часть', 'основные части', 'основных частей')}',
        if (parts.extra.isNotEmpty) 'дополнительно: ${parts.extra.length}',
      ].join(' · ');
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.panelBorder),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.layers, size: 18, color: AppColors.accentText),
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Франшиза: $name',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text: '  ·  $detail',
                    style: const TextStyle(color: AppColors.muted),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: !ready || missing.isEmpty
                ? null
                : () => addAllToLibrary(ref, [
                    for (final anime in missing) anime.toInfo(),
                  ], StatusAction.planned),
            icon: const Icon(LucideIcons.listPlus),
            label: Text(
              ready && missing.isEmpty
                  ? 'Основные части в библиотеке'
                  : ready && missing.length < parts.main.length
                  ? 'Добавить недостающие · ${missing.length}'
                  : 'Добавить все основные части',
            ),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: _saved
                ? () => openFranchise(
                    context,
                    key: key,
                    backLabel: 'Назад к поиску',
                  )
                : null,
            icon: const Icon(LucideIcons.listOrdered, size: 16),
            label: const Text('Открыть франшизу'),
          ),
        ],
      ),
    );
  }
}
