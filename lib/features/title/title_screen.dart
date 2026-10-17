import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../discord/discord_menu.dart';
import '../../core/widgets/app_menu_anchor.dart';
import '../../core/labels.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/status_menu.dart';
import '../../data/database/user_groups_repository.dart';
import '../../core/widgets/panel.dart';
import '../../core/widgets/poster.dart';
import '../../core/widgets/poster_card.dart';
import '../../core/widgets/release_badge.dart';
import '../../core/widgets/star_rating.dart';
import '../../data/database/app_database.dart';
import '../../data/database/franchise_rules.dart';
import '../../data/database/library_repository.dart';
import '../../data/database/watch_status.dart';
import '../../data/providers.dart';
import '../../data/shikimori/release_facts.dart';
import '../../data/shikimori/shikimori_client.dart';
import '../franchise/franchise_actions.dart';
import '../groups/group_actions.dart';
import '../groups/group_screen.dart';
import '../franchise/title_franchise_panel.dart';
import '../library/add_to_library_button.dart';
import '../library/entry_status_button.dart';
import '../library/library_actions.dart';
import '../notifications/alerts_button.dart';
import '../notifications/site_line.dart';
import '../watch/watch_button.dart';
import '../watch/watch_next_button.dart';
import 'episodes_panel.dart';
import 'history_panel.dart';
import 'note_panel.dart';

/// Открывает страницу тайтла.
void openTitle(
  BuildContext context, {
  required int animeId,
  required String backLabel,
}) {
  Navigator.of(context)
      .push(titleRoute(animeId: animeId, backLabel: backLabel));
}

/// Маршрут страницы тайтла.
Route<void> titleRoute({required int animeId, required String backLabel}) =>
    PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 160),
      reverseTransitionDuration: const Duration(milliseconds: 120),
      pageBuilder: (_, _, _) =>
          TitleScreen(animeId: animeId, backLabel: backLabel),
      transitionsBuilder: (_, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    );

class TitleScreen extends ConsumerStatefulWidget {
  const TitleScreen({
    super.key,
    required this.animeId,
    required this.backLabel,
  });

  final int animeId;
  final String backLabel;

  @override
  ConsumerState<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends ConsumerState<TitleScreen> {
  bool _loadingDetails = true;

  String? _selectedCycleId;
  String? _detailsError;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  /// Загружает подробности тайтла.
  Future<void> _loadDetails() async {
    setState(() {
      _loadingDetails = true;
      _detailsError = null;
    });
    try {
      final anime = await ref
          .read(shikimoriClientProvider)
          .getAnime(widget.animeId);
      if (anime != null) {
        await ref.read(libraryRepositoryProvider).saveAnime(anime);
      }
      if (mounted) setState(() => _loadingDetails = false);
    } catch (error) {
      if (mounted) {
        setState(() {
          _loadingDetails = false;
          _detailsError = '$error';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final anime = ref.watch(animeProvider(widget.animeId)).value;
    final entry = ref.watch(libraryEntryProvider(widget.animeId)).value;
    final history = entry == null
        ? const <CycleHistory>[]
        : ref.watch(titleHistoryProvider(widget.animeId)).value ??
              const <CycleHistory>[];
    final status = entry == null
        ? WatchStatus.planned
        : WatchStatus.fromName(entry.status);
    final viewing = CurrentViewing.of(history, status);
    final current = viewing.cycle;
    final selectedId =
        history.any((cycle) => cycle.cycle.id == _selectedCycleId) &&
            _selectedCycleId != current?.cycle.id
        ? _selectedCycleId
        : null;
    final canRestart =
        current != null && current.events.isNotEmpty && !current.isCompleted;
    final showHistory =
        history.length > 1 ||
        (history.length == 1 && (history.first.isCompleted || current == null));

    const gap = SizedBox(height: 18);
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
              if (anime != null && entry != null)
                TitleAlertsButton(anime: anime, entry: entry),
              if (anime != null)
                _MoreMenu(
                  anime: anime,
                  entry: entry,
                  canRestart: canRestart,
                  markNext: entry == null
                      ? null
                      : _markable(anime, viewing.events.keys.toSet()),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (anime == null)
            _buildMissing()
          else ...[
            _Hero(anime: anime, entry: entry, viewing: viewing),
            const SizedBox(height: 32),
            if (entry != null) ...[
              EpisodesPanel(
                anime: anime,
                history: history,
                viewing: viewing,
                selectedCycleId: selectedId,
                onShowCurrent: () => setState(() => _selectedCycleId = null),
              ),
              gap,
              if (showHistory) ...[
                HistoryPanel(
                  anime: anime,
                  history: history,
                  viewing: viewing,
                  selectedCycleId: selectedId,
                  onSelect: (id) => setState(() => _selectedCycleId = id),
                ),
                gap,
              ],
            ],
            if (_franchiseKey(anime, entry) case final key?) ...[
              TitleFranchisePanel(
                key: ValueKey(key),
                franchiseKey: key,
                animeId: anime.id,
              ),
              gap,
            ],
            _AboutPanel(
              anime: anime,
              loading: _loadingDetails,
              error: _detailsError,
              onRetry: _loadDetails,
            ),
            if (!anime.release.isReleased) ...[
              gap,
              _BroadcastPanel(anime: anime, entry: entry),
            ],
            if (entry != null) ...[gap, NotePanel(entry: entry)],
          ],
        ],
      ),
    );
  }

  static String? _franchiseKey(Anime anime, LibraryEntry? entry) {
    if (entry != null) return franchiseKeyOf(entry, anime);
    final key = anime.franchise;
    return key == null || key.isEmpty ? null : key;
  }

  Widget _buildMissing() {
    if (_loadingDetails) {
      return const Padding(
        padding: EdgeInsets.only(top: 80),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return Row(
      children: [
        Flexible(
          child: Text(
            'Не удалось загрузить тайтл: ${_detailsError ?? 'не найден на Shikimori'}',
            style: const TextStyle(color: AppColors.muted, fontSize: 15),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: _loadDetails,
          icon: const Icon(LucideIcons.rotateCcw),
          label: const Text('Повторить'),
        ),
      ],
    );
  }
}

class _Hero extends ConsumerWidget {
  const _Hero({
    required this.anime,
    required this.entry,
    required this.viewing,
  });

  final Anime anime;
  final LibraryEntry? entry;
  final CurrentViewing viewing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final release = anime.release;
    final progress = ref.watch(titleProgressProvider(anime.id));
    final nextAt = anime.nextEpisodeAt;
    final details = [
      releaseSummary(release),
      if (anime.shikimoriScore != null && anime.shikimoriScore! > 0)
        'Shikimori ${anime.shikimoriScore!.toStringAsFixed(1)}',
    ].where((part) => part.isNotEmpty).join(' · ');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 240,
          child: DecoratedBox(
            position: DecorationPosition.foreground,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF33313A)),
            ),
            child: Poster(
              url: anime.posterOriginalUrl ?? anime.posterUrl,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        const SizedBox(width: 44),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                runSpacing: 6,
                children: [
                  if (entry == null)
                    const _Chip('Не в библиотеке')
                  else
                    EntryStatusButton(
                      animeId: anime.id,
                      title: anime.title,
                      status: WatchStatus.fromName(entry!.status),
                      release: release,
                      compact: true,
                      allowRemove: false,
                    ),
                  Tooltip(
                    message: nextAt == null || release.isReleased
                        ? ''
                        : release.isAnnounced
                        ? 'Премьера: ${formatDateTime(nextAt)}'
                        : 'Серия ${release.aired + 1}: ${formatDateTime(nextAt)}',
                    child: ReleaseBadge(
                      release: release,
                      nextEpisodeAt: nextAt,
                      detailed: true,
                    ),
                  ),
                  Text(
                    [
                      kindLabel(anime.kind),
                      if (anime.year != null) '${anime.year}',
                    ].join(' · '),
                    style: const TextStyle(color: AppColors.muted),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SelectableText(
                anime.title,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              if (anime.russian.isNotEmpty && anime.name.isNotEmpty) ...[
                const SizedBox(height: 6),
                SelectableText(
                  anime.name,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              if (details.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  details,
                  style: const TextStyle(color: AppColors.muted, fontSize: 14),
                ),
              ],
              if (entry != null)
                _GroupLinks(
                  item: LibraryItem(entry: entry!, anime: anime),
                ),
              if (entry != null) ...[
                const SizedBox(height: 14),
                StarRating(
                  score: entry!.score,
                  onChanged: (score) => ref
                      .read(libraryRepositoryProvider)
                      .setScore(anime.id, score),
                ),
              ],
              if (entry != null && !release.isAnnounced) ...[
                const SizedBox(height: 24),
                _ProgressBlock(
                  release: release,
                  watched: progress.watched,
                  cycleNumber: progress.cycleNumber,
                ),
              ],
              const SizedBox(height: 22),
              Wrap(
                spacing: 9,
                runSpacing: 9,
                children: [
                  if (entry == null) ...[
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 220),
                      child: AddToLibraryButton(
                        anime: anime.toInfo(),
                        label: 'Добавить в библиотеку',
                      ),
                    ),
                    WatchButton(anime: anime, primary: false),
                  ] else ...[
                    WatchButton(
                      anime: anime,
                      next: WatchNext.of(
                        anime,
                        status: WatchStatus.fromName(entry!.status),
                        next: _firstUnwatched(viewing.events.keys.toSet()),
                        watched: viewing.events.length,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GroupLinks extends ConsumerWidget {
  const _GroupLinks({required this.item});

  final LibraryItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref.watch(groupMembersProvider).value ?? const {};
    final ids = groupsOf(item, members);
    final groups = [
      for (final group in ref.watch(userGroupsProvider).value ?? const [])
        if (ids.contains(group.id)) group,
    ];
    if (groups.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Wrap(
        spacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Icon(LucideIcons.folder, size: 15, color: AppColors.muted),
          const SizedBox(width: 2),
          const Text('В группах:', style: TextStyle(color: AppColors.muted)),
          for (final group in groups)
            TextButton(
              onPressed: () => openGroup(context, group.id),
              style: TextButton.styleFrom(
                minimumSize: const Size(0, 28),
                padding: const EdgeInsets.symmetric(horizontal: 6),
              ),
              child: Text(group.name),
            ),
        ],
      ),
    );
  }
}

class _MoreMenu extends ConsumerWidget {
  const _MoreMenu({
    required this.anime,
    required this.entry,
    required this.canRestart,
    this.markNext,
  });

  final Anime anime;

  final LibraryEntry? entry;

  final bool canRestart;

  final int? markNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = this.entry;
    final inLibrary = entry != null;
    return AppMenuAnchor(
      style: AppTheme.menuStyle,
      alignmentOffset: const Offset(-216, 6),
      menuChildren: [
        if (markNext case final episode?)
          AppMenuItem(
            label: 'Отметить серию $episode',
            icon: LucideIcons.circleCheck,
            color: AppColors.menuItemText,
            onPressed: () =>
                markNextEpisode(ref, animeId: anime.id, title: anime.title),
          ),
        AppMenuItem(
          label: 'Открыть на Shikimori',
          icon: LucideIcons.externalLink,
          color: AppColors.menuItemText,
          onPressed: () => launchUrl(ShikimoriClient.animePage(anime.id)),
        ),
        ?discordTitleItem(ref, anime: anime, entry: entry),
        if (inLibrary && canRestart)
          AppMenuItem(
            label: 'Начать просмотр заново',
            icon: LucideIcons.rotateCcw,
            color: AppColors.menuItemText,
            onPressed: () => restartViewing(ref, animeId: anime.id),
          ),
        if (entry != null) ...[
          const Divider(height: 9, thickness: 1, color: Color(0xFF35323C)),
          AppMenuItem(
            label: 'Группы…',
            icon: LucideIcons.folders,
            color: AppColors.menuItemText,
            onPressed: () {
              final item = LibraryItem(entry: entry, anime: anime);
              showGroupsDialog(
                context,
                title: anime.title,
                addKey: memberKeyOf(item),
                keys: {memberKeyOf(item), 'a:${anime.id}'},
              );
            },
          ),
          for (final action in franchiseMenuActions(
            context,
            ref,
            LibraryItem(entry: entry, anime: anime),
          ))
            AppMenuItem(
              label: action.label,
              icon: action.icon,
              color: AppColors.menuItemText,
              onPressed: action.onPressed,
            ),
        ],
        if (inLibrary) ...[
          const Divider(height: 9, thickness: 1, color: Color(0xFF35323C)),
          AppMenuItem(
            label: 'Убрать из библиотеки',
            icon: LucideIcons.trash2,
            color: AppColors.dangerText,
            onPressed: () =>
                removeFromLibrary(ref, animeId: anime.id, title: anime.title),
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

class _ProgressBlock extends StatelessWidget {
  const _ProgressBlock({
    required this.release,
    required this.watched,
    required this.cycleNumber,
  });

  final ReleaseFacts release;
  final int watched;

  final int cycleNumber;

  @override
  Widget build(BuildContext context) {
    final available = release.availableEpisodes;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  cycleNumber > 1 ? '$cycleNumber-й просмотр' : 'Прогресс',
                  style: const TextStyle(color: Color(0xFFC9C5D0)),
                ),
              ),
              Text(
                release.isOngoing
                    ? '$watched / $available вышедших'
                    : '$watched / $available',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 9),
          ProgressBar(
            value: available == 0 ? 0 : watched / available,
            height: 9,
          ),
        ],
      ),
    );
  }
}

class _AboutPanel extends StatelessWidget {
  const _AboutPanel({
    required this.anime,
    required this.loading,
    required this.error,
    required this.onRetry,
  });

  final Anime anime;
  final bool loading;
  final String? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    const muted = TextStyle(color: AppColors.muted, fontSize: 15);
    final hasDetails = anime.detailsLoadedAt != null;

    final Widget description;
    if (anime.description != null) {
      description = _CollapsibleText(anime.description!);
    } else if (!hasDetails && loading) {
      description = const Text('Загрузка описания…', style: muted);
    } else if (!hasDetails && error != null) {
      description = Row(
        children: [
          const Flexible(child: Text('Описание не загрузилось.', style: muted)),
          TextButton(onPressed: onRetry, child: const Text('Повторить')),
        ],
      );
    } else {
      description = const Text('На Shikimori пока нет описания.', style: muted);
    }

    final facts = <(String, Widget)>[
      if (anime.genreList.isNotEmpty)
        (
          'Жанры',
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [for (final genre in anime.genreList) _Chip(genre)],
          ),
        ),
      if (anime.studioList.isNotEmpty)
        ('Студия', Text(anime.studioList.join(', '))),
      if (anime.episodeDuration != null && anime.episodeDuration! > 0)
        ('Длительность серии', Text('${anime.episodeDuration} мин.')),
      if (ageRatingLabel(anime.ageRating) case final rating?)
        ('Возрастной рейтинг', Text(rating)),
    ];

    return Panel(
      title: 'О тайтле',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: description,
          ),
          for (final (label, value) in facts) ...[
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 190,
                  child: Text(
                    label,
                    style: const TextStyle(color: AppColors.muted),
                  ),
                ),
                Expanded(child: value),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _BroadcastPanel extends ConsumerWidget {
  const _BroadcastPanel({required this.anime, this.entry});

  final Anime anime;
  final LibraryEntry? entry;

  /// Строка о сериях на YummyAnime.
  String? _siteLine(WidgetRef ref) {
    if (!anime.release.isOngoing) return null;
    ref.watch(siteEpisodesRefreshProvider(anime.id));
    return siteLine(ref, anime, entry);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final site = _siteLine(ref);
    final release = anime.release;
    final next = anime.nextEpisodeAt;

    final String title;
    final String detail;
    final String state;
    final Color stateColor;
    final Color stateBackground;
    if (release.isReleased) {
      title = releaseSummary(release).isEmpty
          ? 'Показ завершён'
          : releaseSummary(release);
      detail = 'Все серии японского эфира вышли.';
      state = 'Вышло';
      stateColor = const Color(0xFFBCF4D0);
      stateBackground = const Color(0xFF184B2D);
    } else if (release.isOngoing) {
      title = releaseSummary(release);
      detail = next == null
          ? 'Дата следующей серии пока не объявлена.'
          : 'Серия ${release.aired + 1}: ${formatDateTime(next)} · ${relativeDay(next).toLowerCase()}';
      state = 'Онгоинг';
      stateColor = const Color(0xFFDDD5FF);
      stateBackground = const Color(0xFF3A2D76);
    } else if (release.isAnnounced) {
      title = release.episodes > 0
          ? 'Заявлено ${episodesLabel(release.episodes)}'
          : 'Число серий не объявлено';
      detail = next == null
          ? 'Дата премьеры пока не объявлена.'
          : 'Премьера: ${formatDateTime(next)} · ${relativeDay(next).toLowerCase()}';
      state = 'Анонс';
      stateColor = const Color(0xFFD8D2E5);
      stateBackground = const Color(0xFF35313E);
    } else {
      title = 'Нет данных';
      detail = 'Shikimori не сообщил статус показа.';
      state = 'Неизвестно';
      stateColor = const Color(0xFFD8D2E5);
      stateBackground = const Color(0xFF35313E);
    }

    return Panel(
      title: 'Японский эфир',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            release.isReleased
                ? LucideIcons.circleCheck
                : LucideIcons.radioTower,
            color: const Color(0xFFA899FF),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(detail, style: const TextStyle(color: Color(0xFFA7A2AE))),
                const SizedBox(height: 8),
                _Chip(state, color: stateColor, background: stateBackground),
                if (site != null) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.monitorPlay,
                        size: 16,
                        color: AppColors.muted,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          site,
                          style: const TextStyle(color: Color(0xFFA7A2AE)),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(
    this.text, {
    this.color = const Color(0xFFB9B4C1),
    this.background = const Color(0xFF242229),
  });

  final String text;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF4A4651)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CollapsibleText extends StatefulWidget {
  const _CollapsibleText(this.text);

  final String text;

  @override
  State<_CollapsibleText> createState() => _CollapsibleTextState();
}

class _CollapsibleTextState extends State<_CollapsibleText> {
  static const _maxLines = 4;
  static const _style = TextStyle(
    fontFamily: AppTheme.fontFamily,
    fontSize: 15,
    height: 1.6,
    color: Color(0xFFDEDBE4),
  );

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: widget.text, style: _style),
          maxLines: _maxLines,
          textDirection: TextDirection.ltr,
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(maxWidth: constraints.maxWidth);
        final overflows = painter.didExceedMaxLines;
        painter.dispose();

        if (!overflows) return SelectableText(widget.text, style: _style);
        void toggle() => setState(() => _expanded = !_expanded);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MouseRegion(
              cursor: _expanded
                  ? SystemMouseCursors.text
                  : SystemMouseCursors.click,
              child: GestureDetector(
                onTap: _expanded ? null : toggle,
                child: _expanded
                    ? SelectableText(widget.text, style: _style)
                    : ShaderMask(
                        blendMode: BlendMode.dstIn,
                        shaderCallback: (rect) => const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white,
                            Colors.white,
                            Colors.transparent,
                          ],
                          stops: [0, 0.55, 1],
                        ).createShader(rect),
                        child: Text(
                          widget.text,
                          style: _style,
                          maxLines: _maxLines,
                          overflow: TextOverflow.clip,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 4),
            _TextLink(
              label: _expanded ? 'Свернуть' : 'Развернуть',
              onTap: toggle,
            ),
          ],
        );
      },
    );
  }
}

class _TextLink extends StatefulWidget {
  const _TextLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_TextLink> createState() => _TextLinkState();
}

class _TextLinkState extends State<_TextLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Text(
          widget.label,
          style: TextStyle(
            fontSize: 13,
            color: _hovered ? AppColors.text : AppColors.muted,
            decoration: _hovered ? TextDecoration.underline : null,
            decorationColor: AppColors.muted,
          ),
        ),
      ),
    );
  }
}

/// Первая неотмеченная серия.
/// Следующая серия, если её можно отметить: она уже вышла.
int? _markable(Anime anime, Set<int> watched) {
  final release = anime.release;
  final next = _firstUnwatched(watched);
  return release.isAnnounced || next > release.availableEpisodes ? null : next;
}

int _firstUnwatched(Set<int> watched) {
  var next = 1;
  while (watched.contains(next)) {
    next++;
  }
  return next;
}
