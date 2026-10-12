import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_colors.dart';

class Poster extends StatelessWidget {
  const Poster({
    super.key,
    required this.url,
    this.borderRadius = BorderRadius.zero,
  });

  final String? url;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    const placeholder = ColoredBox(
      color: AppColors.poster,
      child: Center(
        child: Icon(
          LucideIcons.imageOff,
          color: AppColors.posterPlaceholder,
          size: 28,
        ),
      ),
    );
    return AspectRatio(
      aspectRatio: 2 / 3,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: url == null || url!.isEmpty
            ? placeholder
            : ColoredBox(
                color: AppColors.poster,
                child: Image.network(
                  url!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  frameBuilder: (context, child, frame, loadedSync) =>
                      loadedSync
                      ? child
                      : AnimatedOpacity(
                          opacity: frame == null ? 0 : 1,
                          duration: const Duration(milliseconds: 200),
                          child: child,
                        ),
                  errorBuilder: (_, _, _) => placeholder,
                ),
              ),
      ),
    );
  }
}
