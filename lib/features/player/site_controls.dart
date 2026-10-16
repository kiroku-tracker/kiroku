import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/labels.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/select_button.dart';
import '../../data/database/library_repository.dart';
import '../../data/database/watch_status.dart';
import '../../data/providers.dart';
import 'site_catalog.dart';

/// Выбор озвучки, плеера и серии над видео сайта.
class SiteControls extends ConsumerWidget {
  const SiteControls({
    super.key,
    required this.animeId,
    required this.catalog,
    required this.choice,
    required this.onChoose,
  });

  final int animeId;
  final SiteCatalog catalog;
  final SiteChoice choice;
  final ValueChanged<SiteChoice> onChoose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dubbings = catalog.dubbings;
    final dubbing = dubbings.contains(choice.dubbing)
        ? choice.dubbing!
        : dubbings.first;
    final players = catalog.players(dubbing);
    final player = players.contains(choice.player)
        ? choice.player!
        : players.first;
    final current = (dubbing: dubbing, player: player, episode: choice.episode);
    final episodes = catalog.episodes(dubbing, player);

    final entry = ref.watch(libraryEntryProvider(animeId)).value;
    final history = entry == null
        ? const <CycleHistory>[]
        : ref.watch(titleHistoryProvider(animeId)).value ??
              const <CycleHistory>[];
    final status = entry == null
        ? WatchStatus.planned
        : WatchStatus.fromName(entry.status);
    final watched = CurrentViewing.of(history, status).events.keys.toSet();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SelectButton<String>(
                icon: LucideIcons.mic,
                tooltip: 'Озвучка',
                value: dubbing,
                options: dubbings,
                labelOf: (value) =>
                    '${shortDubbing(value)} · '
                    '${episodesLabel(catalog.episodeCount(value))}',
                onChanged: (value) =>
                    onChoose(catalog.withDubbing(current, value)),
              ),
              const SizedBox(width: 8),
              SelectButton<String>(
                icon: LucideIcons.monitorPlay,
                tooltip: 'Плеер',
                value: player,
                options: players,
                labelOf: shortPlayer,
                onChanged: (value) =>
                    onChoose(catalog.withPlayer(current, value)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 118),
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final episode in episodes)
                    _EpisodeTile(
                      episode: episode,
                      watched: watched.contains(episode),
                      playing: episode == choice.episode,
                      onTap: () => onChoose((
                        dubbing: dubbing,
                        player: player,
                        episode: episode,
                      )),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Плитка серии.
class _EpisodeTile extends StatelessWidget {
  const _EpisodeTile({
    required this.episode,
    required this.watched,
    required this.playing,
    required this.onTap,
  });

  final int episode;
  final bool watched;
  final bool playing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: watched ? AppColors.accent : AppColors.secondaryButton,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: playing
            ? const BorderSide(color: AppColors.accentText, width: 2)
            : watched
            ? BorderSide.none
            : const BorderSide(color: AppColors.secondaryButtonBorder),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        hoverColor: Colors.white.withValues(alpha: 0.06),
        child: SizedBox(
          width: 48,
          height: 34,
          child: Center(
            child: Text(
              '$episode',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: watched ? Colors.white : AppColors.secondaryButtonText,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
