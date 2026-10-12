import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/widgets/app_menu_anchor.dart';
import '../../core/labels.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/poster.dart';
import '../../core/widgets/poster_card.dart';
import '../../core/widgets/release_badge.dart';
import '../../core/widgets/status_menu.dart';
import '../../data/database/app_database.dart';
import '../../data/database/franchise_rules.dart';
import '../../data/database/library_repository.dart';
import '../../data/database/queue_repository.dart';
import '../library/add_to_library_button.dart';
import '../library/entry_status_button.dart';
import '../title/title_screen.dart';
import 'franchise_actions.dart';

class FranchisePart {
  const FranchisePart({required this.anime, this.item});

  final Anime anime;
  final LibraryItem? item;
}

/// Части франшизы с учётом ручных правок.
({List<FranchisePart> main, List<FranchisePart> extra}) franchiseParts(
  String key,
  WatchOrder? order,
  List<LibraryItem> library,
) {
  final itemById = {for (final item in library) item.anime.id: item};
  bool belongs(Anime anime) {
    final item = itemById[anime.id];
    return item == null || franchiseKeyOf(item.entry, item.anime) == key;
  }

  FranchisePart part(Anime anime) =>
      FranchisePart(anime: anime, item: itemById[anime.id]);

  final main = [
    for (final anime in order?.main ?? const <Anime>[])
      if (belongs(anime)) part(anime),
  ];
  final extra = [
    for (final anime in order?.extra ?? const <Anime>[])
      if (belongs(anime)) part(anime),
  ];
  final shown = {
    for (final part in [...main, ...extra]) part.anime.id,
  };
  final movedIn = [
    for (final item in library)
      if (franchiseKeyOf(item.entry, item.anime) == key &&
          !shown.contains(item.anime.id))
        FranchisePart(anime: item.anime, item: item),
  ];
  if (movedIn.isNotEmpty) {
    main
      ..addAll(movedIn)
      ..sort((a, b) => compareByAirDate(a.anime, b.anime));
  }
  return (main: main, extra: extra);
}

/// Список частей франшизы.
class WatchOrderList extends StatelessWidget {
  const WatchOrderList({
    super.key,
    required this.parts,
    required this.backLabel,
    this.numbered = true,
    this.currentAnimeId,
    this.queue,
  });

  final List<FranchisePart> parts;
  final String backLabel;

  final bool numbered;

  final int? currentAnimeId;

  final ActiveQueue? queue;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final (index, part) in parts.indexed)
          _PartRow(
            part: part,
            number: numbered ? index + 1 : null,
            current: part.anime.id == currentAnimeId,
            queueState: queue?.stateOf(part.anime.id),
            backLabel: backLabel,
          ),
      ],
    );
  }
}

class _PartRow extends ConsumerStatefulWidget {
  const _PartRow({
    required this.part,
    required this.number,
    required this.current,
    required this.backLabel,
    this.queueState,
  });

  final FranchisePart part;
  final int? number;
  final bool current;
  final String backLabel;

  final String? queueState;

  @override
  ConsumerState<_PartRow> createState() => _PartRowState();
}

class _PartRowState extends ConsumerState<_PartRow> {
  bool _hovered = false;
  final _menu = MenuController();

  @override
  Widget build(BuildContext context) {
    final anime = widget.part.anime;
    final item = widget.part.item;
    final release = anime.release;
    final inLibrary = item != null;
    final dim = !inLibrary && !_hovered;
    final details = [
      kindLabel(anime.kind),
      if (anime.year != null) '${anime.year}',
      if (anime.episodes > 1) episodesLabel(anime.episodes),
    ].join(' · ');

    final row = Material(
      color: widget.current
          ? const Color(0xFF221F2E)
          : _hovered
          ? AppColors.cardHover
          : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: widget.current
            ? null
            : () => openTitle(
                context,
                animeId: anime.id,
                backLabel: widget.backLabel,
              ),
        onSecondaryTapDown: item == null
            ? null
            : (details) => _menu.open(position: details.localPosition),
        onHover: (value) => setState(() => _hovered = value),
        borderRadius: BorderRadius.circular(10),
        hoverColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              SizedBox(
                width: 30,
                child: switch (widget.queueState) {
                  'active' => const Tooltip(
                    message: 'Сейчас по очереди',
                    child: Icon(
                      LucideIcons.play,
                      size: 16,
                      color: AppColors.accentText,
                    ),
                  ),
                  'done' => const Tooltip(
                    message: 'Пройдено в очереди',
                    child: Icon(
                      LucideIcons.check,
                      size: 16,
                      color: Color(0xFF8FD9A8),
                    ),
                  ),
                  _ => Text(
                    widget.number?.toString() ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                },
              ),
              const SizedBox(width: 8),
              Opacity(
                opacity: dim ? 0.55 : 1,
                child: SizedBox(
                  width: 40,
                  child: Poster(
                    url: anime.posterUrl,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Opacity(
                  opacity: dim ? 0.6 : 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        anime.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              details,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          if (!release.isReleased) ...[
                            const SizedBox(width: 8),
                            ReleaseBadge(release: release),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (item != null) ...[
                if (!release.isAnnounced)
                  SizedBox(
                    width: 110,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${item.progress.watched} / '
                          '${release.availableEpisodes}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 5),
                        ProgressBar(
                          value: release.availableEpisodes == 0
                              ? 0
                              : item.progress.watched /
                                    release.availableEpisodes,
                          height: 4,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 170,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: EntryStatusButton(
                      animeId: anime.id,
                      title: anime.title,
                      status: item.status,
                      release: release,
                      compact: true,
                    ),
                  ),
                ),
              ] else
                SizedBox(
                  width: 170,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: AddToLibraryButton(
                      anime: anime.toInfo(),
                      compact: true,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (item == null) return row;
    return AppMenuAnchor(
      controller: _menu,
      style: AppTheme.menuStyle,
      menuChildren: [
        for (final action in franchiseMenuActions(context, ref, item))
          AppMenuItem(
            label: action.label,
            icon: action.icon,
            color: AppColors.menuItemText,
            onPressed: action.onPressed,
          ),
      ],
      child: row,
    );
  }
}
