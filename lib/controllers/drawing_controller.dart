import 'package:database_diagrams/models/drawing_state.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Drawing controller.
class DrawingController extends ChangeNotifier {
  /// Default constructor.
  DrawingController() : _state = DrawingState.initial();

  /// State.
  final DrawingState _state;

  /// Drawing.
  bool get isDrawing => _state.isDrawing;

  /// Polyline.
  bool get isPolyline => _state.isPolyline;

  /// Drawing points.
  List<Offset?> get drawingPoints => _state.drawingPoints;

  /// Polyline points.
  List<Offset?> get polylinePoints => _state.polylinePoints;

  /// Provider.
  static final provider = ChangeNotifierProvider<DrawingController>(
    (ref) => DrawingController(),
  );

  /// Add drawing point.
  void addDrawingPoint(Offset? point) {
    _state.drawingPoints.add(point);
    notifyListeners();
  }

  /// Add polyline point.
  void addPolylinePoint(Offset? point) {
    _state.polylinePoints.add(point);
    if (_state.polylinePoints.length > 1 &&
        _state.polylinePoints.last != null &&
        _state.polylinePoints[_state.polylinePoints.length - 2] != null) {
      _state.polylinePoints.add(null);
    }
    notifyListeners();
  }

  /// Toggle drawing.
  void toggleDrawingMode() {
    _state.isDrawing = !_state.isDrawing;
    notifyListeners();
  }

  /// Toggle polyline.
  void togglePolylineMode() {
    _state.isPolyline = !_state.isPolyline;
    notifyListeners();
  }

  /// Undo.
  void undoDraw() {
    if (_state.drawingPoints.isEmpty) {
      return;
    }

    bool hitFirstNull = false;
    for (int i = _state.drawingPoints.length - 1; i > -1; i--) {
      if (_state.drawingPoints[i] == null && hitFirstNull) {
        break;
      }
      if (_state.drawingPoints[i] == null) {
        hitFirstNull = true;
        _state.drawingPoints.removeAt(i);
        _state.drawingRedoStack.add(null);
        continue;
      }
      _state.drawingRedoStack.add(_state.drawingPoints[i]);
      _state.drawingPoints.removeAt(i);
    }

    notifyListeners();
  }

  /// Redo.
  void redoDraw() {
    if (_state.drawingRedoStack.isEmpty) {
      return;
    }

    for (int i = _state.drawingRedoStack.length - 1; i > -1; i--) {
      if (_state.drawingRedoStack[i] == null) {
        _state.drawingRedoStack.removeAt(i);
        _state.drawingPoints.add(null);
        break;
      }
      _state.drawingPoints.add(_state.drawingRedoStack[i]);
      _state.drawingRedoStack.removeAt(i);
    }

    notifyListeners();
  }
}
