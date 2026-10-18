import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_colors.dart';

/// Кнопка «В избранное» с сердечком.
class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    super.key,
    required this.active,
    required this.onPressed,
  });

  final bool active;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: active ? 'Убрать из избранного' : 'В избранное',
      onPressed: onPressed,
      style: active
          ? IconButton.styleFrom(
              backgroundColor: AppColors.favorite.withValues(alpha: 0.14),
            )
          : null,
      icon: Icon(
        LucideIcons.heart,
        size: 19,
        color: active ? AppColors.favorite : AppColors.navIdle,
      ),
    );
  }
}
