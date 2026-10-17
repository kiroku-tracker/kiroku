import 'package:flutter/material.dart';

/// Панель под кнопкой, закрывается кликом мимо и по Esc.
class PopupPanelRoute extends PopupRoute<void> {
  PopupPanelRoute({
    required this.anchor,
    required this.builder,
    this.width = 460,
    this.fromLeft = false,
  });

  final Rect anchor;
  final WidgetBuilder builder;
  final double width;

  /// Панель выравнивается по левому краю кнопки, а не по правому.
  final bool fromLeft;

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'Закрыть';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 120);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final size = MediaQuery.sizeOf(context);
    final left = (fromLeft ? anchor.left : anchor.right - width).clamp(
      8.0,
      size.width - width - 8,
    );
    final top = anchor.bottom + 8;
    return Stack(
      children: [
        Positioned(
          left: left,
          top: top,
          width: width,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: size.height - top - 16),
            child: builder(context),
          ),
        ),
      ],
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => FadeTransition(
    opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
    child: child,
  );
}

/// Открывает панель под виджетом [context].
void showPopupPanel(
  BuildContext context, {
  required WidgetBuilder builder,
  double width = 460,
  bool fromLeft = false,
}) {
  final box = context.findRenderObject()! as RenderBox;
  final anchor = box.localToGlobal(Offset.zero) & box.size;
  Navigator.of(context, rootNavigator: true).push(
    PopupPanelRoute(
      anchor: anchor,
      builder: builder,
      width: width,
      fromLeft: fromLeft,
    ),
  );
}
