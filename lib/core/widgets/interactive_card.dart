import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Карточка с подсветкой при наведении.
class InteractiveCard extends StatefulWidget {
  const InteractiveCard({
    super.key,
    required this.child,
    required this.onTap,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback onTap;
  final String? semanticLabel;

  @override
  State<InteractiveCard> createState() => _InteractiveCardState();
}

class _InteractiveCardState extends State<InteractiveCard> {
  bool _hovered = false;

  /// Рамка фокуса только у самой карточки: фокус кнопки или меню внутри
  /// не считается, иначе после закрытия меню рамка остаётся.
  final _focusNode = FocusNode();

  static const _radius = BorderRadius.all(Radius.circular(14));

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocus);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocus() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final focused = _focusNode.hasPrimaryFocus;
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: _hovered ? AppColors.cardHover : AppColors.card,
          borderRadius: _radius,
          border: Border.all(
            color: focused
                ? AppColors.focus
                : _hovered
                ? AppColors.cardBorderHover
                : AppColors.cardBorder,
            width: focused ? 2 : 1,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: widget.onTap,
            focusNode: _focusNode,
            onHover: (value) => setState(() => _hovered = value),
            borderRadius: _radius,
            hoverColor: Colors.transparent,
            focusColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: ClipRRect(borderRadius: _radius, child: widget.child),
          ),
        ),
      ),
    );
  }
}
