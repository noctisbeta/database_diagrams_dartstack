import 'package:flutter/material.dart';

/// Drawing state.
class DrawingState {
  /// Default constructor.
  DrawingState({
    required this.drawingPoints,
    required this.drawingRedoStack,
    required this.isDrawing,
    required this.isPolyline,
    required this.polylinePoints,
    required this.polylineRedoStack,
  });

  /// Initial state.
  DrawingState.initial()
      : drawingPoints = [],
        drawingRedoStack = [],
        isDrawing = false,
        isPolyline = false,
        polylinePoints = [],
        polylineRedoStack = [];

  /// Drawing points.
  final List<Offset?> drawingPoints;

  /// Redo stack.
  final List<Offset?> drawingRedoStack;

  /// Polyline points.
  final List<Offset?> polylinePoints;

  /// Redo stack.
  final List<Offset?> polylineRedoStack;

  /// Is drawing.
  bool isDrawing;

  /// Is polyline.
  bool isPolyline;
}
