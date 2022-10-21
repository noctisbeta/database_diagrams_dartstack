import 'package:database_diagrams/models/drawing_point.dart';
import 'package:flutter/material.dart';

/// PolylinePainter.
class PolylinePainter extends CustomPainter {
  /// Default constructor.
  PolylinePainter({
    required this.points,
  });

  /// Points.
  final List<DrawingPoint?> points;

  /// Splits the list on nulls.
  List<List<DrawingPoint>> splitByNulls(List<DrawingPoint?> list) {
    final result = <List<DrawingPoint>>[];
    var current = <DrawingPoint>[];
    for (final point in list) {
      if (point == null) {
        if (current.isNotEmpty) {
          result.add(current);
          current = [];
        }
      } else {
        current.add(point);
      }
    }
    if (current.isNotEmpty) {
      result.add(current);
    }
    return result;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final split = splitByNulls(points);

    for (final line in split) {
      final path = Path()..moveTo(line.first.point.dx, line.first.point.dy);

      for (final point in line.sublist(1)) {
        path
          ..lineTo(point.point.dx, point.point.dy)
          ..moveTo(point.point.dx, point.point.dy);

        paint.strokeWidth = point.size;
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant PolylinePainter oldDelegate) {
    return true;
  }
}
