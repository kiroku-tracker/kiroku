import 'dart:math';

import 'package:flutter/rendering.dart';

/// Сетка карточек с постерами.
SliverGridDelegate posterGridDelegate({
  required double width,
  required double bodyHeight,
  double minCardWidth = 230,
  double spacing = 18,
}) {
  final columns = max(
    1,
    ((width + spacing) / (minCardWidth + spacing)).floor(),
  );
  final cardWidth = (width - spacing * (columns - 1)) / columns;
  return SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: columns,
    mainAxisSpacing: spacing,
    crossAxisSpacing: spacing,
    mainAxisExtent: cardWidth * 1.5 + bodyHeight + 2,
  );
}
