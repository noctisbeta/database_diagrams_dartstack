import 'package:flutter/animation.dart';

/// Drawing point.
class DrawingPoint {
  /// Default constructor.
  const DrawingPoint({
    required this.point,
    required this.size,
  });

  /// Offset.
  final Offset point;

  /// Size.
  final double size;
}
