import 'package:flutter/material.dart';

/// SmartlinePainter.
class SmartlinePainter extends CustomPainter {
  /// Default constructor.
  const SmartlinePainter({
    required this.keys,
  });

  /// Keys.
  final List<List<GlobalObjectKey>> keys;

  @override
  void paint(Canvas canvas, Size size) {
    for (final pair in keys) {
      final first = pair.first.currentContext?.findRenderObject() as RenderBox?;
      final second = pair.last.currentContext?.findRenderObject() as RenderBox?;
      if (first != null && second != null) {
        // final firstOffset = first.localToGlobal(first.size.center(Offset.zero));
        // final secondOffset = second.localToGlobal(second.size.center(Offset.zero));

        final padding = 10;

        final firstRight = first.localToGlobal(first.size.center(Offset(padding + first.size.width / 2, 0)));
        final firstLeft = first.localToGlobal(first.size.center(Offset(-padding - first.size.width / 2, 0)));
        final firstTop = first.localToGlobal(first.size.center(Offset(0, -padding - first.size.height / 2)));
        final firstBottom = first.localToGlobal(first.size.center(Offset(0, padding + first.size.height / 2)));

        final secondRight = second.localToGlobal(second.size.center(Offset(padding + second.size.width / 2, 0)));
        final secondLeft = second.localToGlobal(second.size.center(Offset(-padding - second.size.width / 2, 0)));
        final secondTop = second.localToGlobal(second.size.center(Offset(0, -padding - second.size.height / 2)));
        final secondBottom = second.localToGlobal(second.size.center(Offset(0, padding + second.size.height / 2)));

        /// minimize distance between two points

        double minDist = double.infinity;
        Offset firstOffset = firstRight;
        Offset secondOffset = secondRight;
        for (final first in [firstRight, firstLeft, firstTop, firstBottom]) {
          for (final second in [secondRight, secondLeft, secondTop, secondBottom]) {
            final distance = (first.dx - second.dx).abs() + (first.dy - second.dy).abs();
            if (distance < minDist) {
              firstOffset = first;
              secondOffset = second;
              minDist = distance;
            }
          }
        }

        final paint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 2;
        final path = Path()
          ..moveTo(firstOffset.dx, firstOffset.dy)
          ..lineTo(secondOffset.dx, secondOffset.dy);
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant SmartlinePainter oldDelegate) {
    return true;
  }
}
