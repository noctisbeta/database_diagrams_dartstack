import 'package:flutter/material.dart';

/// Drawing state.
class DrawingState {
  /// Default constructor.
  DrawingState({
    required this.points,
    required this.isDrawing,
  });

  /// Initial state.
  DrawingState.initial()
      : points = [],
        isDrawing = false;

  /// Points.
  final List<Offset?> points;

  /// Is drawing.
  bool isDrawing;
}
