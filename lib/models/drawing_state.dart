import 'package:database_diagrams/models/drawing_mode.dart';
import 'package:flutter/material.dart';

/// Drawing state.
class DrawingState {
  /// Default constructor.
  DrawingState({
    required this.drawingPoints,
    required this.drawingRedoStack,
    required this.polylinePoints,
    required this.polylineRedoStack,
    required this.drawingMode,
  });

  /// Initial state.
  DrawingState.initial()
      : drawingPoints = [],
        drawingRedoStack = [],
        polylinePoints = [],
        polylineRedoStack = [],
        drawingMode = DrawingMode.none;

  /// Drawing points.
  final List<Offset?> drawingPoints;

  /// Redo stack.
  final List<Offset?> drawingRedoStack;

  /// Polyline points.
  final List<Offset?> polylinePoints;

  /// Redo stack.
  final List<Offset?> polylineRedoStack;

  /// Drawing mode.
  DrawingMode drawingMode;
}
