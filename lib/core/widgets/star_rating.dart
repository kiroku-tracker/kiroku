import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class StarRating extends StatefulWidget {
  const StarRating({
    super.key,
    required this.score,
    required this.onChanged,
    this.size = 22,
  });

  final int? score;
  final ValueChanged<int?> onChanged;
  final double size;

  @override
  State<StarRating> createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating> {
  static const _gap = 3.0;
  int? _hover;

  int _valueAt(double dx) {
    final step = widget.size + _gap;
    final star = (dx / step).floor().clamp(0, 4);
    final inside = dx - star * step;
    final half = inside < widget.size / 2;
    return star * 2 + (half ? 1 : 2);
  }

  @override
  Widget build(BuildContext context) {
    final shown = _hover ?? widget.score ?? 0;
    final label = _hover != null
        ? '$_hover из 10'
        : widget.score == null
        ? 'Без оценки'
        : '${widget.score} из 10';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          onHover: (event) =>
              setState(() => _hover = _valueAt(event.localPosition.dx)),
          onExit: (_) => setState(() => _hover = null),
          child: GestureDetector(
            onTapUp: (details) {
              final value = _valueAt(details.localPosition.dx);
              widget.onChanged(value == widget.score ? null : value);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var star = 0; star < 5; star++) ...[
                  CustomPaint(
                    size: Size.square(widget.size),
                    painter: _StarPainter(
                      fill: ((shown - star * 2) / 2).clamp(0, 1).toDouble(),
                      preview: _hover != null,
                    ),
                  ),
                  if (star < 4) const SizedBox(width: _gap),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(color: AppColors.muted, fontSize: 13),
        ),
      ],
    );
  }
}

class _StarPainter extends CustomPainter {
  _StarPainter({required this.fill, required this.preview});

  final double fill;
  final bool preview;

  static const _gold = Color(0xFFFFC857);

  @override
  void paint(Canvas canvas, Size size) {
    final path = _star(size);
    canvas.drawPath(path, Paint()..color = const Color(0xFF2F2C37));
    if (fill > 0) {
      canvas.save();
      canvas.clipRect(Rect.fromLTWH(0, 0, size.width * fill, size.height));
      canvas.drawPath(
        path,
        Paint()..color = preview ? _gold.withValues(alpha: 0.7) : _gold,
      );
      canvas.restore();
    }
  }

  Path _star(Size size) {
    final path = Path();
    final cx = size.width / 2;
    final cy = size.height / 2 + size.height * 0.04;
    final outer = size.width / 2;
    final inner = outer * 0.45;
    for (var i = 0; i < 10; i++) {
      final radius = i.isEven ? outer : inner;
      final angle = -math.pi / 2 + i * math.pi / 5;
      final x = cx + radius * math.cos(angle);
      final y = cy + radius * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    return path..close();
  }

  @override
  bool shouldRepaint(covariant _StarPainter oldDelegate) =>
      oldDelegate.fill != fill || oldDelegate.preview != preview;
}
