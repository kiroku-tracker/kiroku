import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'app_menu_anchor.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'status_menu.dart';

/// Кнопка выбора из списка.
class SelectButton<T> extends StatelessWidget {
  const SelectButton({
    super.key,
    required this.icon,
    required this.value,
    required this.options,
    required this.labelOf,
    required this.onChanged,
    this.tooltip,
  });

  final IconData icon;
  final T value;
  final List<T> options;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return AppMenuAnchor(
      style: AppTheme.menuStyle,
      alignmentOffset: const Offset(0, 6),
      menuChildren: [
        for (final option in options)
          AppMenuItem(
            label: labelOf(option),
            color: option == value ? Colors.white : AppColors.menuItemText,
            checked: option == value,
            onPressed: () => onChanged(option),
          ),
      ],
      builder: (context, controller, _) => Tooltip(
        message: tooltip ?? '',
        child: OutlinedButton(
          onPressed: () =>
              controller.isOpen ? controller.close() : controller.open(),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: AppColors.navIdle),
              const SizedBox(width: 8),
              Text(labelOf(value)),
              const SizedBox(width: 6),
              const Icon(
                LucideIcons.chevronDown,
                size: 15,
                color: AppColors.navIdle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
