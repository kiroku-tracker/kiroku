import '../shikimori/user_rate.dart';
import 'import_plan.dart';

/// Список Shikimori в виде тайтлов для переноса.
List<ImportItem> shikimoriItems(List<UserRate> rates) => [
  for (final rate in rates)
    ImportItem(
      sourceTitle: rate.anime.title,
      anime: rate.anime,
      status: rate.watchStatus,
      score: rate.score,
      note: rate.text?.trim() ?? '',
      viewings: [
        for (var i = 0; i < rate.completedViewings; i++)
          ImportViewing(
            completed: true,
            episodes: [
              for (var n = 1; n <= rate.completedEpisodes; n++)
                ImportEpisode(n),
            ],
          ),
        if (rate.currentEpisodes > 0)
          ImportViewing(
            completed: false,
            episodes: [
              for (var n = 1; n <= rate.currentEpisodes; n++) ImportEpisode(n),
            ],
          ),
      ],
      createdAt: rate.createdAt,
      updatedAt: rate.updatedAt,
    ),
];
