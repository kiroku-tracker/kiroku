import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_colors.dart';
import 'context_menu_area.dart';
import 'interactive_card.dart';
import 'poster.dart';

/// Карточка тайтла с постером.
class PosterCard extends StatefulWidget {
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
    this.menu,
    this.favorite = false,
    this.onFavorite,
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

  final List<Widget> Function()? menu;

  /// В избранном: сердечко в углу видно всегда, иначе при наведении.
  final bool favorite;
  final VoidCallback? onFavorite;

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
  State<PosterCard> createState() => _PosterCardState();
}

class _PosterCardState extends State<PosterCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final menu = widget.menu;
    final card = MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: _card(),
    );
    return menu == null ? card : ContextMenuArea(items: menu, child: card);
  }

  Widget _card() {
    final PosterCard(
      :posterUrl,
      :title,
      :subtitle,
      :meta,
      :action,
      :onTap,
      :extra,
      :posterBadge,
      :posterBadgeEnd,
      :cover,
      :onFavorite,
    ) = widget;
    final corner = onFavorite == null ? 0.0 : 32.0;
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
                  right: (posterBadgeEnd == null ? 8 : 48) + corner,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: posterBadge,
                  ),
                ),
              if (posterBadgeEnd != null)
                Positioned(top: 8, right: 8 + corner, child: posterBadgeEnd),
              if (onFavorite != null)
                Positioned(
                  top: 6,
                  right: 6,
                  child: _FavoriteCorner(
                    active: widget.favorite,
                    visible: widget.favorite || _hovered,
                    onPressed: onFavorite,
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(PosterCard._padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: PosterCard._titleHeight,
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
                  height: PosterCard._lineHeight,
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
                  height: PosterCard._lineHeight,
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
                    height: PosterCard._extraHeight,
                    child: Align(alignment: Alignment.bottomLeft, child: extra),
                  ),
                const SizedBox(height: 12),
                SizedBox(height: PosterCard._actionHeight, child: action),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Сердечко «В избранное» в углу постера.
class _FavoriteCorner extends StatelessWidget {
  const _FavoriteCorner({
    required this.active,
    required this.visible,
    required this.onPressed,
  });

  final bool active;
  final bool visible;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: const Duration(milliseconds: 120),
      child: IgnorePointer(
        ignoring: !visible,
        child: Tooltip(
          message: active ? 'Убрать из избранного' : 'В избранное',
          child: Material(
            color: const Color(0x66000000),
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              child: SizedBox.square(
                dimension: 26,
                child: Icon(
                  LucideIcons.heart,
                  size: 13,
                  color: active
                      ? AppColors.favorite.withValues(alpha: 0.9)
                      : const Color(0xD9FFFFFF),
                ),
              ),
            ),
          ),
        ),
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
