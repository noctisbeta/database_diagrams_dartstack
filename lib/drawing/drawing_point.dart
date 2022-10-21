import 'package:flutter/animation.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

/// Drawing point.
class DrawingPoint extends Point {
  /// Default constructor.
  DrawingPoint({
    required this.point,
    required this.size,
  }) : super(point.dx, point.dy);

  /// Offset.
  final Offset point;

  /// Size.
  final double size;
}
