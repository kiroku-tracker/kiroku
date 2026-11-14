import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import 'import_dialog.dart';

/// Карточки всех источников импорта.
class ImportSources extends StatelessWidget {
  const ImportSources({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final source in ImportSource.values)
          ImportSourceCard(source: source),
      ],
    );
  }
}

/// Карточка источника: название, что переносится и вход в окно импорта.
class ImportSourceCard extends StatelessWidget {
  const ImportSourceCard({super.key, required this.source});

  final ImportSource source;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Material(
        color: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.panelBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => showImportDialog(context, source),
          hoverColor: AppColors.cardHover,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  LucideIcons.download,
                  size: 20,
                  color: AppColors.accentText,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        source.label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        source.description,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
