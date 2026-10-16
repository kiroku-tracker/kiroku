import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../discord/discord_menu.dart';
import '../../core/widgets/app_menu_anchor.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/panel.dart';
import '../../core/widgets/poster.dart';
import '../../core/widgets/poster_card.dart';
import '../../core/widgets/status_menu.dart';
import '../../data/database/app_database.dart';
import '../../data/database/franchise_rules.dart';
import '../../data/database/status_action.dart';
import '../../data/database/user_groups_repository.dart';
import '../../data/database/watch_status.dart';
import '../../data/providers.dart';
import '../notifications/release_watcher.dart';
import '../../data/shikimori/shikimori_client.dart';
import '../groups/group_actions.dart';
import '../notifications/alerts_button.dart';
import '../library/library_actions.dart';
import '../library/library_filter.dart';
import '../title/title_screen.dart';
import '../watch/watch_button.dart';
import 'franchise_actions.dart';
import 'franchise_card.dart';
import 'watch_order_list.dart';

void openFranchise(
  BuildContext context, {
  required String key,
  required String backLabel,
}) {
  Navigator.of(context).push(
    PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 160),
      reverseTransitionDuration: const Duration(milliseconds: 120),
      pageBuilder: (_, _, _) =>
          FranchiseScreen(franchiseKey: key, backLabel: backLabel),
      transitionsBuilder: (_, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  );
}

class FranchiseScreen extends ConsumerStatefulWidget {
  const FranchiseScreen({
    super.key,
    required this.franchiseKey,
    required this.backLabel,
  });

  final String franchiseKey;
  final String backLabel;

  @override
  ConsumerState<FranchiseScreen> createState() => _FranchiseScreenState();
}

class _FranchiseScreenState extends ConsumerState<FranchiseScreen> {
  bool _showExtra = false;

  @override
  Widget build(BuildContext context) {
    final key = widget.franchiseKey;
    final loading = ref.watch(franchiseLoadProvider(key));
    final library = ref.watch(libraryItemsProvider).value ?? const [];
    final row = ref.watch(franchisesProvider).value?[key];
    final order = ref.watch(watchOrderProvider(key)).value;
    final parts = franchiseParts(key, order, library);
    final owned = [
      for (final part in [...parts.main, ...parts.extra])
        if (part.item != null) part.item!,
    ];
    final title = owned.isEmpty && row?.name == null && row?.autoName == null
        ? (parts.main.firstOrNull?.anime.title ?? 'Франшиза')
        : franchiseName(row, owned);
    final cover =
        [
          ...parts.main,
          ...parts.extra,
        ].where((part) => part.anime.id == row?.coverAnimeId).firstOrNull ??
        (parts.main.isNotEmpty ? parts.main.first : null);
    final missingMain = [
      for (final part in parts.main)
        if (part.item == null) part.anime,
    ];
    final mainDone = parts.main
        .where((part) => part.item?.status == WatchStatus.completed)
        .length;
    final average = averageScoreOf(owned);
    const backLabel = 'Назад к франшизе';

    return SingleChildScrollView(
      padding: pagePadding(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TextButton.icon(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(LucideIcons.arrowLeft, size: 18),
                label: Text(widget.backLabel),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
              const Spacer(),
              if (owned.isNotEmpty)
                FranchiseAlertsButton(
                  franchiseKey: key,
                  name: title,
                  partIds: [for (final item in owned) item.anime.id],
                ),
              _MoreMenu(
                franchiseKey: key,
                name: title,
                hasCustomName: row?.name != null,
                ownedParts: [for (final item in owned) item.anime],
                coverId: cover?.anime.id,
                shikimoriId: isCustomFranchise(key)
                    ? null
                    : parts.main.firstOrNull?.anime.id,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 200,
                child: DecoratedBox(
                  position: DecorationPosition.foreground,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF33313A)),
                  ),
                  child: Poster(
                    url: cover?.anime.posterUrl,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(width: 40),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        FranchiseBadge(parts: owned.length),
                        Text(
                          parts.main.isEmpty
                              ? 'В библиотеке: ${partsLabel(owned.length)}'
                              : 'Основная линия: ${partsLabel(parts.main.length)}'
                                    '${parts.extra.isEmpty ? '' : ' · дополнительно: ${parts.extra.length}'}',
                          style: const TextStyle(color: AppColors.muted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SelectableText(
                      title,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    if (average != null) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(
                            LucideIcons.star,
                            size: 16,
                            color: Color(0xFFFFC857),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${formatAverage(average)} из 10',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'средняя оценка частей',
                            style: TextStyle(color: AppColors.muted),
                          ),
                        ],
                      ),
                    ],
                    if (parts.main.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Просмотрено основных частей',
                                    style: TextStyle(color: Color(0xFFC9C5D0)),
                                  ),
                                ),
                                Text(
                                  '$mainDone / ${parts.main.length}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 9),
                            ProgressBar(
                              value: mainDone / parts.main.length,
                              height: 9,
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    _Actions(
                      franchiseKey: key,
                      main: parts.main,
                      missing: missingMain,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Panel(
            title: 'Порядок просмотра',
            child: parts.main.isEmpty
                ? _LoadingState(
                    loading: loading.isLoading || order == null,
                    error: loading.hasError,
                    onRetry: () => ref.invalidate(franchiseLoadProvider(key)),
                  )
                : WatchOrderList(
                    parts: parts.main,
                    backLabel: backLabel,
                    queue: ref.watch(activeQueuesProvider).value?[key],
                  ),
          ),
          if (parts.extra.isNotEmpty) ...[
            const SizedBox(height: 18),
            Panel(
              title: 'Дополнительно',
              trailing: TextButton.icon(
                onPressed: () => setState(() => _showExtra = !_showExtra),
                icon: Icon(
                  _showExtra ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                  size: 16,
                ),
                label: Text(
                  _showExtra ? 'Свернуть' : 'Показать · ${parts.extra.length}',
                ),
              ),
              child: _showExtra
                  ? WatchOrderList(
                      parts: parts.extra,
                      numbered: false,
                      backLabel: backLabel,
                    )
                  : const Text(
                      'Побочные истории, спин-оффы, пересказы и спецвыпуски.',
                      style: TextStyle(color: AppColors.muted),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState({
    required this.loading,
    required this.error,
    required this.onRetry,
  });

  final bool loading;
  final bool error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (error) {
      return Row(
        children: [
          const Flexible(
            child: Text(
              'Не удалось загрузить части франшизы из Shikimori.',
              style: TextStyle(color: AppColors.muted),
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(LucideIcons.rotateCcw),
            label: const Text('Повторить'),
          ),
        ],
      );
    }
    if (loading) {
      return const Row(
        children: [
          SizedBox.square(
            dimension: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text(
            'Загрузка частей франшизы…',
            style: TextStyle(color: AppColors.muted),
          ),
        ],
      );
    }
    return const Text(
      'Части франшизы не найдены.',
      style: TextStyle(color: AppColors.muted),
    );
  }
}

class _MoreMenu extends ConsumerWidget {
  const _MoreMenu({
    required this.franchiseKey,
    required this.name,
    required this.hasCustomName,
    required this.ownedParts,
    required this.coverId,
    required this.shikimoriId,
  });

  final String franchiseKey;
  final String name;
  final bool hasCustomName;
  final List<Anime> ownedParts;
  final int? coverId;

  final int? shikimoriId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shikimoriId = this.shikimoriId;
    return AppMenuAnchor(
      style: AppTheme.menuStyle,
      alignmentOffset: const Offset(-216, 6),
      menuChildren: [
        AppMenuItem(
          label: 'Переименовать…',
          icon: LucideIcons.pencil,
          color: AppColors.menuItemText,
          onPressed: () =>
              renameFranchise(context, ref, key: franchiseKey, current: name),
        ),
        if (hasCustomName && !isCustomFranchise(franchiseKey))
          AppMenuItem(
            label: 'Название как у Shikimori',
            icon: LucideIcons.rotateCcw,
            color: AppColors.menuItemText,
            onPressed: () => resetFranchiseName(ref, key: franchiseKey),
          ),
        if (ownedParts.length > 1)
          AppMenuItem(
            label: 'Выбрать обложку…',
            icon: LucideIcons.image,
            color: AppColors.menuItemText,
            onPressed: () => chooseFranchiseCover(
              context,
              ref,
              key: franchiseKey,
              parts: ownedParts,
              current: coverId,
            ),
          ),
        if (ownedParts.isNotEmpty)
          AppMenuItem(
            label: 'Группы…',
            icon: LucideIcons.folders,
            color: AppColors.menuItemText,
            onPressed: () => showGroupsDialog(
              context,
              title: name,
              addKey: franchiseMemberKey(franchiseKey),
              keys: {
                franchiseMemberKey(franchiseKey),
                for (final anime in ownedParts) 'a:${anime.id}',
              },
            ),
          ),
        if (ownedParts.isNotEmpty)
          ?discordFranchiseItem(
            context,
            ref,
            franchiseKey: franchiseKey,
            parts: ownedParts,
          ),
        if (shikimoriId != null)
          AppMenuItem(
            label: 'Открыть на Shikimori',
            icon: LucideIcons.externalLink,
            color: AppColors.menuItemText,
            onPressed: () =>
                launchUrl(ShikimoriClient.franchisePage(shikimoriId)),
          ),
        if (ownedParts.isNotEmpty) ...[
          const Divider(height: 9, thickness: 1, color: Color(0xFF35323C)),
          AppMenuItem(
            label: 'Убрать из библиотеки',
            icon: LucideIcons.trash2,
            color: AppColors.dangerText,
            onPressed: () =>
                removeFranchise(context, ref, name: name, parts: ownedParts),
          ),
        ],
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

class _Actions extends ConsumerWidget {
  const _Actions({
    required this.franchiseKey,
    required this.main,
    required this.missing,
  });

  final String franchiseKey;
  final List<FranchisePart> main;
  final List<Anime> missing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref.watch(activeQueuesProvider).value?[franchiseKey];
    final activeId = queue?.active?.animeId;
    final active = main.where((part) => part.anime.id == activeId).firstOrNull;
    final item = active?.item;

    final addMissing = missing.isEmpty
        ? null
        : OutlinedButton.icon(
            onPressed: () => addAllToLibrary(ref, [
              for (final anime in missing) anime.toInfo(),
            ], StatusAction.planned),
            icon: const Icon(LucideIcons.listPlus),
            label: Text(
              missing.length == main.length
                  ? 'Добавить все основные части'
                  : 'Добавить недостающие · ${missing.length}',
            ),
          );

    if (queue == null || active == null || item == null) {
      final plan = queuePlan(main);
      final rewatch = isRewatch([
        for (final part in main)
          if (part.anime.release.availableEpisodes > 0) part,
      ]);
      return Wrap(
        spacing: 9,
        runSpacing: 9,
        children: [
          Tooltip(
            message: rewatch
                ? 'Все части начнутся заново, по порядку'
                : 'Части идут по порядку, досмотренные пропускаются',
            child: FilledButton.icon(
              onPressed: plan.isEmpty
                  ? null
                  : () => startQueue(ref, key: franchiseKey, plan: plan),
              icon: Icon(rewatch ? LucideIcons.rotateCcw : LucideIcons.play),
              label: Text(
                rewatch ? 'Пересмотреть по порядку' : 'Смотреть по порядку',
              ),
            ),
          ),
          ?addMissing,
        ],
      );
    }

    final next = unwatchedAired(item) > 0 ? item.progress.nextEpisode : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              const WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Icon(
                  LucideIcons.listOrdered,
                  size: 15,
                  color: AppColors.accentText,
                ),
              ),
              TextSpan(
                text:
                    '  По порядку: часть ${queue.activePosition} из '
                    '${queue.items.length} · ',
                style: const TextStyle(color: AppColors.muted),
              ),
              TextSpan(
                text: active.anime.title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 9,
          runSpacing: 9,
          children: [
            WatchButton(anime: active.anime),
            if (next != null)
              OutlinedButton.icon(
                onPressed: () => markNextEpisode(
                  ref,
                  animeId: active.anime.id,
                  title: active.anime.title,
                ),
                icon: const Icon(LucideIcons.circleCheck),
                label: Text('Следующая серия · $next'),
              )
            else
              Tooltip(
                message: 'Новые серии этой части ещё не вышли',
                child: OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(LucideIcons.checkCheck),
                  label: const Text('Все вышедшие просмотрены'),
                ),
              ),
            OutlinedButton.icon(
              onPressed: () => openTitle(
                context,
                animeId: active.anime.id,
                backLabel: 'Назад к франшизе',
              ),
              icon: const Icon(LucideIcons.arrowRight),
              label: const Text('Открыть часть'),
            ),
            TextButton.icon(
              onPressed: () => stopQueue(ref, key: franchiseKey),
              icon: const Icon(LucideIcons.circleStop),
              label: const Text('Остановить очередь'),
            ),
            ?addMissing,
          ],
        ),
      ],
    );
  }
}
