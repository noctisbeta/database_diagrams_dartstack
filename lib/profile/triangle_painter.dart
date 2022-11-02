import 'package:flutter/material.dart';

/// Triangle painter.
class TrianglePainter extends CustomPainter {
  /// Default constructor.
  TrianglePainter({
    this.strokeColor = Colors.white,
    this.strokeWidth = 3,
    this.paintingStyle = PaintingStyle.stroke,
  });

  /// Stroke color.
  final Color strokeColor;

  /// Painting style.
  final PaintingStyle paintingStyle;

  /// Stroke width.
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..style = paintingStyle;

    canvas.drawPath(getTrianglePath(size.width, size.height), paint);
  }

  /// Path
  Path getTrianglePath(double x, double y) {
    return Path()
      ..moveTo(0, y + 3)
      ..lineTo(x / 2, 0 + 3)
      ..lineTo(x, y + 3)
      ..lineTo(0, y + 3);
  }

  @override
  bool shouldRepaint(TrianglePainter oldDelegate) {
    return oldDelegate.strokeColor != strokeColor || oldDelegate.paintingStyle != paintingStyle || oldDelegate.strokeWidth != strokeWidth;
  }
}
