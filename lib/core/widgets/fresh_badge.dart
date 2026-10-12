import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Число новых серий на постере.
class FreshBadge extends StatelessWidget {
  const FreshBadge({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: count == 1
          ? 'Вышла непросмотренная серия'
          : 'Вышло непросмотренных серий: $count',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          '+$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
