import 'package:flutter/material.dart';

/// Открытые меню окна.
abstract final class OpenMenus {
  static final _open = <MenuController>{};

  static bool get any => _open.isNotEmpty;

  static void closeAll() {
    for (final controller in [..._open]) {
      controller.close();
    }
    _open.clear();
  }
}

/// Меню, которое закрывается по Esc.
class AppMenuAnchor extends StatefulWidget {
  const AppMenuAnchor({
    super.key,
    this.controller,
    this.style,
    this.alignmentOffset,
    required this.menuChildren,
    this.builder,
    this.child,
  });

  final MenuController? controller;
  final MenuStyle? style;
  final Offset? alignmentOffset;
  final List<Widget> menuChildren;
  final MenuAnchorChildBuilder? builder;
  final Widget? child;

  @override
  State<AppMenuAnchor> createState() => _AppMenuAnchorState();
}

class _AppMenuAnchorState extends State<AppMenuAnchor> {
  final _own = MenuController();

  MenuController get _controller => widget.controller ?? _own;

  @override
  void dispose() {
    OpenMenus._open.remove(_controller);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      controller: _controller,
      style: widget.style,
      alignmentOffset: widget.alignmentOffset,
      onOpen: () => OpenMenus._open.add(_controller),
      onClose: () => OpenMenus._open.remove(_controller),
      menuChildren: widget.menuChildren,
      builder: widget.builder,
      child: widget.child,
    );
  }
}
