import 'package:flutter/material.dart';

import '../../data/shikimori/release_facts.dart';
import '../labels.dart';

/// Плашка статуса выхода.
class ReleaseBadge extends StatelessWidget {
  const ReleaseBadge({
    super.key,
    required this.release,
    this.nextEpisodeAt,
    this.detailed = false,
  });

  final ReleaseFacts release;
  final DateTime? nextEpisodeAt;
  final bool detailed;

  @override
  Widget build(BuildContext context) {
    final next = nextEpisodeAt;
    final (String label, Color color, Color background) = release.isReleased
        ? ('Вышел', const Color(0xFFAEE8C0), const Color(0xFF1C4930))
        : release.isOngoing
        ? (
            detailed && next != null
                ? 'Онгоинг · серия ${release.aired + 1} '
                      '${relativeDay(next).toLowerCase()}'
                : 'Онгоинг',
            const Color(0xFFDDD5FF),
            const Color(0xFF3A2D76),
          )
        : release.isAnnounced
        ? (
            detailed && next != null
                ? 'Анонс · премьера ${relativeDay(next).toLowerCase()}'
                : 'Анонс',
            const Color(0xFFD8D2E5),
            const Color(0xFF35313E),
          )
        : ('Нет данных', const Color(0xFFB9B4C1), const Color(0xFF2A2830));

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: detailed ? 9 : 7,
        vertical: detailed ? 4 : 3,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: detailed ? 12 : 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
