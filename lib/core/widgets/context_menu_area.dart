import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_menu_anchor.dart';

/// Меню по правому клику по области.
class ContextMenuArea extends StatefulWidget {
  const ContextMenuArea({super.key, required this.items, required this.child});

  final List<Widget> Function() items;
  final Widget child;

  @override
  State<ContextMenuArea> createState() => _ContextMenuAreaState();
}

class _ContextMenuAreaState extends State<ContextMenuArea> {
  final _controller = MenuController();
  List<Widget> _items = const [];

  @override
  Widget build(BuildContext context) {
    return AppMenuAnchor(
      controller: _controller,
      style: AppTheme.menuStyle,
      menuChildren: _items,
      child: GestureDetector(
        onSecondaryTapDown: (details) {
          final items = widget.items();
          if (items.isEmpty) return;
          setState(() => _items = items);
          _controller.open(position: details.localPosition);
        },
        child: widget.child,
      ),
    );
  }
}
