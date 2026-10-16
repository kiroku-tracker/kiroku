import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/widgets/app_menu_anchor.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/status_menu.dart';
import '../../data/database/app_database.dart';
import '../../data/providers.dart';
import 'watch_actions.dart';

class WatchButton extends ConsumerStatefulWidget {
  const WatchButton({super.key, required this.anime, this.primary = true});

  final Anime anime;

  final bool primary;

  @override
  ConsumerState<WatchButton> createState() => _WatchButtonState();
}

class _WatchButtonState extends ConsumerState<WatchButton> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final anime = widget.anime;
    final links = ref.watch(watchLinksProvider(anime.id)).value ?? const [];
    final source = ref.watch(watchSourceProvider);
    final primary = widget.primary;
    final tooltip = links.isEmpty
        ? 'Открыть на ${source.name}'
        : 'Открыть свою ссылку «${links.first.label}»';

    const leftRadius = BorderRadius.horizontal(left: Radius.circular(9));
    const rightRadius = BorderRadius.horizontal(right: Radius.circular(9));
    ButtonStyle half(BorderRadius radius) => primary
        ? FilledButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: radius),
          )
        : OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: radius),
          );

    final icon = _busy
        ? SizedBox.square(
            dimension: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: primary ? Colors.white : AppColors.accentText,
            ),
          )
        : const Icon(LucideIcons.play);
    final main = Tooltip(
      message: tooltip,
      child: primary
          ? FilledButton.icon(
              onPressed: _busy
                  ? null
                  : () => _run(() => watchTitle(ref, anime)),
              style: half(leftRadius),
              icon: icon,
              label: const Text('Смотреть'),
            )
          : OutlinedButton.icon(
              onPressed: _busy
                  ? null
                  : () => _run(() => watchTitle(ref, anime)),
              style: half(leftRadius),
              icon: icon,
              label: const Text('Смотреть'),
            ),
    );

    final menu = AppMenuAnchor(
      style: AppTheme.menuStyle,
      alignmentOffset: const Offset(0, 8),
      menuChildren: [
        AppMenuItem(
          label: 'Смотреть в Kiroku',
          icon: LucideIcons.monitorPlay,
          color: AppColors.menuItemText,
          onPressed: () => _run(() => watchOnSite(ref, anime, inApp: true)),
        ),
        AppMenuItem(
          label: 'Открыть в браузере',
          icon: LucideIcons.globe,
          color: AppColors.menuItemText,
          onPressed: () => _run(() => watchOnSite(ref, anime, inApp: false)),
        ),
        for (final link in links)
          AppMenuItem(
            label: link.label,
            icon: watchLinkIcon,
            color: AppColors.menuItemText,
            onPressed: () => openWatchLink(ref, link),
          ),
        const Divider(height: 9, thickness: 1, color: Color(0xFF35323C)),
        AppMenuItem(
          label: 'Добавить свою ссылку…',
          icon: LucideIcons.plus,
          color: AppColors.menuItemText,
          onPressed: () => addWatchLink(context, ref, anime),
        ),
        if (links.isNotEmpty)
          AppMenuItem(
            label: 'Свои ссылки…',
            icon: LucideIcons.pencil,
            color: AppColors.menuItemText,
            onPressed: () => _manageLinks(context),
          ),
      ],
      builder: (context, controller, _) {
        void toggle() =>
            controller.isOpen ? controller.close() : controller.open();
        const arrow = Icon(LucideIcons.chevronDown, size: 16);
        final style = half(rightRadius).copyWith(
          minimumSize: const WidgetStatePropertyAll(Size(36, 40)),
          padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        );
        return Tooltip(
          message: 'Где смотреть',
          child: primary
              ? FilledButton(onPressed: toggle, style: style, child: arrow)
              : OutlinedButton(onPressed: toggle, style: style, child: arrow),
        );
      },
    );

    final row = Row(mainAxisSize: MainAxisSize.min, children: [main, menu]);
    if (!primary) return row;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(9),
      ),
      child: row,
    );
  }

  /// Окно своих ссылок.
  Future<void> _manageLinks(BuildContext context) => showDialog<void>(
    context: context,
    builder: (context) => _LinksDialog(anime: widget.anime),
  );
}

class _LinksDialog extends ConsumerWidget {
  const _LinksDialog({required this.anime});

  final Anime anime;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final links = ref.watch(watchLinksProvider(anime.id)).value ?? const [];
    return AlertDialog(
      title: const Text('Свои ссылки'),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (links.isEmpty)
              const Text(
                'Ссылок нет, «Смотреть» открывает сайт по умолчанию.',
                style: TextStyle(color: AppColors.muted),
              ),
            for (final (index, link) in links.indexed)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(watchLinkIcon, size: 16, color: AppColors.muted),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            index == 0
                                ? '${link.label} · основная'
                                : link.label,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            link.url,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Изменить',
                      onPressed: () => editWatchLink(context, ref, link),
                      icon: const Icon(LucideIcons.pencil, size: 16),
                    ),
                    IconButton(
                      tooltip: 'Удалить',
                      onPressed: () => removeWatchLink(ref, link),
                      icon: const Icon(LucideIcons.trash2, size: 16),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => addWatchLink(context, ref, anime),
              icon: const Icon(LucideIcons.plus),
              label: const Text('Добавить ссылку…'),
            ),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Готово'),
        ),
      ],
    );
  }
}
