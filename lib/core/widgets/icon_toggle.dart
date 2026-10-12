import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Кнопка-переключатель с иконкой.
class IconToggle extends StatelessWidget {
  const IconToggle({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      iconSize: 18,
      isSelected: active,
      style: IconButton.styleFrom(
        backgroundColor: active ? AppColors.navActive : Colors.transparent,
        foregroundColor: active ? Colors.white : AppColors.navIdle,
      ),
      icon: Icon(icon),
    );
  }
}
