import 'package:database_diagrams/models/drawing_mode.dart';
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
  bool get isDrawing => _state.drawingMode == DrawingMode.draw;

  /// Polyline.
  bool get isPolyline => _state.drawingMode == DrawingMode.polyline;

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

    // for the indicator
    _state.polylinePoints.add(point);

    notifyListeners();
  }

  void updatePolylineIndicator(Offset point) {
    _state.polylinePoints.last = point;
    notifyListeners();
  }

  /// Toggle drawing.
  void toggleDrawingMode() {
    if (_state.drawingMode == DrawingMode.draw) {
      _state.drawingMode = DrawingMode.none;
    } else {
      _state.drawingMode = DrawingMode.draw;
    }
    notifyListeners();
  }

  /// Toggle polyline.
  void togglePolylineMode() {
    if (_state.drawingMode == DrawingMode.polyline) {
      _state.drawingMode = DrawingMode.none;
    } else {
      _state.drawingMode = DrawingMode.polyline;
    }
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
