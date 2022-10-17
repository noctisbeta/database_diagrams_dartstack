import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

/// DrawingPainter.
class DrawingPainter extends CustomPainter {
  /// Default constructor.
  DrawingPainter({
    required this.points,
  });

  /// Points.
  final List<Offset?> points;

  List<Point?> get _points => points
      .map(
        (e) => e != null ? Point(e.dx, e.dy) : null,
      )
      .toList();

  /// Splits the list on nulls.
  List<List<Point>> splitByNulls(List<Point?> list) {
    final result = <List<Point>>[];
    var current = <Point>[];
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

    // for (var i = 0; i < points.length - 1; i++) {
    //   if (points[i] != null && points[i + 1] != null) {
    //     canvas.drawLine(points[i]!, points[i + 1]!, paint);
    //   } else if (points[i] != null) {
    //     canvas.drawPoints(PointMode.points, [points[i]!], paint);
    //   }
    // }

    for (final sublist in splitByNulls(_points)) {
      // 1. Get the outline points from the input points
      final outlinePoints = getStroke(
        sublist,
        size: 2,
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
