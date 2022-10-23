import 'package:database_diagrams/drawing/drawing_point.dart';

/// Drawing state.
class DrawingState {
  /// Default constructor.
  DrawingState({
    required this.drawingPoints,
    required this.drawingRedoStack,
    required this.polylinePoints,
    required this.polylineRedoStack,
  });

  /// Initial state.
  DrawingState.initial()
      : drawingPoints = [],
        drawingRedoStack = [],
        polylinePoints = [],
        polylineRedoStack = [];

  /// Drawing points.
  final List<DrawingPoint?> drawingPoints;

  /// Redo stack.
  final List<DrawingPoint?> drawingRedoStack;

  /// Polyline points.
  final List<DrawingPoint?> polylinePoints;

  /// Redo stack.
  final List<DrawingPoint?> polylineRedoStack;
}
