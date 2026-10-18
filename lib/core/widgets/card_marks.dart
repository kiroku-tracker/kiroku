import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_colors.dart';

/// Число просмотров со значком двух стрелок по кругу.
class ViewsMark extends StatelessWidget {
  const ViewsMark({
    super.key,
    required this.count,
    this.size = 13,
    this.color = AppColors.muted,
  });

  final int count;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Просмотров: $count',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.refreshCw, size: size, color: color),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: TextStyle(
              color: color,
              fontSize: size,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Плашка на постере: значок и число.
class PosterPill extends StatelessWidget {
  const PosterPill({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 3, 8, 3),
      decoration: BoxDecoration(
        color: const Color(0xE6131217),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF46424F)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.text),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Плашка числа просмотров на постере.
class ViewsBadge extends StatelessWidget {
  const ViewsBadge({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: 'Просмотров: $count',
    child: PosterPill(icon: LucideIcons.refreshCw, text: '$count'),
  );
}

/// Год и жанры на месте кнопки у просмотренной карточки.
class CardFacts extends StatelessWidget {
  const CardFacts({super.key, required this.years, required this.genres});

  final String? years;
  final List<String> genres;

  @override
  Widget build(BuildContext context) {
    final text = [
      ?years,
      if (genres.isNotEmpty) genres.take(3).join(', '),
    ].join(' · ');
    if (text.isEmpty) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.muted,
          fontSize: 13,
          height: 1.35,
        ),
      ),
    );
  }
}
