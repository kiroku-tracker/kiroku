import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_colors.dart';
import 'poster.dart';

/// Обложка из нескольких постеров.
class PosterCollage extends StatelessWidget {
  const PosterCollage({
    super.key,
    required this.urls,
    this.borderRadius = BorderRadius.zero,
  });

  final List<String?> urls;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    if (urls.isEmpty) {
      return AspectRatio(
        aspectRatio: 2 / 3,
        child: ClipRRect(
          borderRadius: borderRadius,
          child: const ColoredBox(
            color: AppColors.poster,
            child: Center(
              child: Icon(
                LucideIcons.folder,
                color: AppColors.posterPlaceholder,
                size: 40,
              ),
            ),
          ),
        ),
      );
    }
    if (urls.length == 1) {
      return Poster(url: urls.single, borderRadius: borderRadius);
    }
    final cells = [...urls.take(4)];
    Widget cell(int index) => index < cells.length
        ? Poster(url: cells[index])
        : const AspectRatio(
            aspectRatio: 2 / 3,
            child: ColoredBox(color: AppColors.poster),
          );
    return AspectRatio(
      aspectRatio: 2 / 3,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: ColoredBox(
          color: AppColors.background,
          child: Column(
            children:
                [
                    for (final row in const [0, 2])
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(child: cell(row)),
                            const SizedBox(width: 2),
                            Expanded(child: cell(row + 1)),
                          ],
                        ),
                      ),
                  ].expand((row) => [row, const SizedBox(height: 2)]).toList()
                  ..removeLast(),
          ),
        ),
      ),
    );
  }
}
