import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'interactive_card.dart';
import 'poster.dart';

/// Карточка тайтла с постером.
class PosterCard extends StatelessWidget {
  const PosterCard({
    super.key,
    required this.posterUrl,
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.action,
    required this.onTap,
    this.extra,
    this.posterBadge,
    this.posterBadgeEnd,
    this.cover,
  });

  final String? posterUrl;
  final String title;
  final String subtitle;
  final Widget meta;

  final Widget action;
  final VoidCallback onTap;

  final Widget? extra;

  final Widget? posterBadge;

  final Widget? posterBadgeEnd;

  final Widget? cover;

  static const _padding = 14.0;
  static const _titleHeight = 44.0;
  static const _lineHeight = 20.0;
  static const _actionHeight = 40.0;
  static const _extraHeight = 13.0;

  /// Высота блока под постером.
  static double bodyHeight({bool withExtra = false}) =>
      _padding +
      _titleHeight +
      4 +
      _lineHeight +
      2 +
      _lineHeight +
      (withExtra ? _extraHeight : 0) +
      12 +
      _actionHeight +
      _padding;

  @override
  Widget build(BuildContext context) {
    return InteractiveCard(
      onTap: onTap,
      semanticLabel: 'Открыть: $title',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              cover ?? Poster(url: posterUrl),
              if (posterBadge != null)
                Positioned(
                  top: 8,
                  left: 8,
                  right: posterBadgeEnd == null ? 8 : 48,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: posterBadge!,
                  ),
                ),
              if (posterBadgeEnd != null)
                Positioned(top: 8, right: 8, child: posterBadgeEnd!),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(_padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: _titleHeight,
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      color: AppColors.text,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: _lineHeight,
                  child: Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.muted,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                SizedBox(
                  height: _lineHeight,
                  child: DefaultTextStyle.merge(
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.muted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    child: Align(alignment: Alignment.centerLeft, child: meta),
                  ),
                ),
                if (extra != null)
                  SizedBox(
                    height: _extraHeight,
                    child: Align(alignment: Alignment.bottomLeft, child: extra),
                  ),
                const SizedBox(height: 12),
                SizedBox(height: _actionHeight, child: action),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.value, this.height = 5});

  final double value;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        height: height,
        child: LinearProgressIndicator(
          value: value.clamp(0, 1),
          backgroundColor: AppColors.track,
          color: AppColors.progress,
        ),
      ),
    );
  }
}
