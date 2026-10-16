import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'app_menu_anchor.dart';

import '../../data/database/status_action.dart';
import '../../data/database/watch_status.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../theme/status_style.dart';

/// Меню выбора статуса.
class StatusMenu extends StatelessWidget {
  const StatusMenu({
    super.key,
    required this.actions,
    required this.onSelected,
    required this.builder,
    this.current,
    this.caughtUp = false,
    this.onRemove,
  });

  final List<StatusAction> actions;

  final bool caughtUp;
  final ValueChanged<StatusAction> onSelected;
  final MenuAnchorChildBuilder builder;
  final WatchStatus? current;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final items = [...actions];
    final currentAction = current == null
        ? null
        : caughtUp
        ? StatusAction.caughtUp
        : StatusAction.forStatus(current!);
    if (currentAction != null && !items.contains(currentAction)) {
      items.insert(
        StatusAction.values.indexOf(currentAction).clamp(0, items.length),
        currentAction,
      );
    }

    return AppMenuAnchor(
      style: AppTheme.menuStyle,
      alignmentOffset: const Offset(0, 8),
      menuChildren: [
        for (final action in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: _StatusMenuItem(
              action: action,
              checked: action == currentAction,
              onPressed: () => onSelected(action),
            ),
          ),
        if (onRemove != null) ...[
          const Divider(height: 9, thickness: 1, color: Color(0xFF35323C)),
          AppMenuItem(
            label: 'Убрать из библиотеки',
            icon: LucideIcons.trash2,
            color: AppColors.dangerText,
            onPressed: onRemove!,
          ),
        ],
      ],
      builder: builder,
    );
  }
}

class _StatusMenuItem extends StatelessWidget {
  const _StatusMenuItem({
    required this.action,
    required this.checked,
    required this.onPressed,
  });

  final StatusAction action;
  final bool checked;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final style = StatusStyle.ofAction(action);
    return AppMenuItem(
      label: action.label,
      icon: style.icon,
      color: style.foreground,
      checked: checked,
      onPressed: onPressed,
    );
  }
}

class AppMenuItem extends StatelessWidget {
  const AppMenuItem({
    super.key,
    required this.label,
    this.icon,
    required this.color,
    required this.onPressed,
    this.checked = false,
  });

  final String label;

  final IconData? icon;
  final Color color;
  final VoidCallback onPressed;
  final bool checked;

  @override
  Widget build(BuildContext context) {
    final highlighted = Color.alphaBlend(
      color.withValues(alpha: 0.13),
      const Color(0xFF24212A),
    );
    bool active(Set<WidgetState> states) =>
        checked ||
        states.contains(WidgetState.hovered) ||
        states.contains(WidgetState.focused);

    final button = MenuItemButton(
      onPressed: onPressed,
      leadingIcon: icon == null ? null : Icon(icon, size: 18),
      trailingIcon: Icon(
        LucideIcons.check,
        size: 16,
        color: checked ? color : Colors.transparent,
      ),
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(220, 40)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 14),
        ),
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        foregroundColor: WidgetStatePropertyAll(color),
        iconColor: WidgetStatePropertyAll(color),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => active(states) ? highlighted : Colors.transparent,
        ),
        side: WidgetStateProperty.resolveWith(
          (states) => BorderSide(
            color: active(states)
                ? color.withValues(alpha: 0.45)
                : Colors.transparent,
          ),
        ),
      ),
      child: Text(label),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: button,
    );
  }
}

class StatusButton extends StatefulWidget {
  const StatusButton({
    super.key,
    required this.status,
    required this.onPressed,
    this.compact = false,
    this.caughtUp = false,
  });

  final WatchStatus status;
  final VoidCallback onPressed;

  final bool caughtUp;

  final bool compact;

  @override
  State<StatusButton> createState() => _StatusButtonState();
}

class _StatusButtonState extends State<StatusButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final style = widget.caughtUp
        ? StatusStyle.ofAction(StatusAction.caughtUp)
        : StatusStyle.of(widget.status);
    final label = widget.caughtUp
        ? StatusAction.caughtUp.label
        : widget.status.label;
    final compact = widget.compact;
    final radius = BorderRadius.circular(compact ? 999 : 9);
    return Semantics(
      button: true,
      label: 'Статус: $label. Изменить',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Material(
          color: _hovered
              ? Color.alphaBlend(
                  Colors.white.withValues(alpha: 0.06),
                  style.background,
                )
              : style.background,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(
              color: _hovered
                  ? style.foreground.withValues(alpha: 0.7)
                  : Colors.transparent,
            ),
          ),
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: radius,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: Padding(
              padding: compact
                  ? const EdgeInsets.symmetric(horizontal: 9, vertical: 4)
                  : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
                children: [
                  Icon(
                    style.icon,
                    size: compact ? 13 : 16,
                    color: style.foreground,
                  ),
                  SizedBox(width: compact ? 5 : 8),
                  Flexible(
                    fit: compact ? FlexFit.loose : FlexFit.tight,
                    child: _FittingLabel(
                      label: label,
                      short: widget.caughtUp ? 'Всё вышедшее' : label,
                      style: TextStyle(
                        color: style.foreground,
                        fontSize: compact ? 12 : 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(width: compact ? 3 : 6),
                  Icon(
                    LucideIcons.chevronDown,
                    size: compact ? 12 : 16,
                    color: style.foreground,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Подпись, которая сокращается, если не помещается.
class _FittingLabel extends StatelessWidget {
  const _FittingLabel({
    required this.label,
    required this.short,
    required this.style,
  });

  final String label;
  final String short;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: label, style: style),
          textDirection: TextDirection.ltr,
          textScaler: MediaQuery.textScalerOf(context),
          maxLines: 1,
        )..layout();
        final fits = painter.width <= constraints.maxWidth;
        painter.dispose();
        return Text(
          fits ? label : short,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: style,
        );
      },
    );
  }
}
