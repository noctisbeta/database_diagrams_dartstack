import 'package:database_diagrams/drawing/drawing_point.dart';
import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

/// DrawingPainter.
class DrawingPainter extends CustomPainter {
  /// Default constructor.
  DrawingPainter({
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
    final paint = Paint()..color = Colors.white;

    if (points.isEmpty) {
      return;
    }

    for (final sublist in splitByNulls(points)) {
      // 1. Get the outline points from the input points
      final outlinePoints = getStroke(
        sublist.map((e) => Point(e.point.dx, e.point.dy)).toList(),
        size: sublist.first.size,
        smoothing: 1,
        streamline: 1,
        thinning: 0,
      );

      // 2. Render the points as a path
      final path = Path();

      if (outlinePoints.isEmpty) {
        // If the list is empty, don't do anything.
        return;
      } else if (outlinePoints.length < 2) {
        // If the list only has one point, draw a dot.
        path.addOval(Rect.fromCircle(center: Offset(outlinePoints[0].x, outlinePoints[0].y), radius: 1));
      } else {
        // Otherwise, draw a line that connects each point with a bezier curve segment.
        path.moveTo(outlinePoints[0].x, outlinePoints[0].y);

        for (int i = 1; i < outlinePoints.length - 1; ++i) {
          final p0 = outlinePoints[i];
          final p1 = outlinePoints[i + 1];
          path.quadraticBezierTo(p0.x, p0.y, (p0.x + p1.x) / 2, (p0.y + p1.y) / 2);
        }
      }

      // 3. Draw the path to the canvas
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) {
    return true;
  }
}
