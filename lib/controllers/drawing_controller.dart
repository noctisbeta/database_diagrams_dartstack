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

  /// Points.
  List<Offset?> get points => _state.points;

  /// Provider.
  static final provider = ChangeNotifierProvider<DrawingController>(
    (ref) => DrawingController(),
  );

  /// Add point.
  void addPoint(Offset? point) {
    _state.points.add(point);
    notifyListeners();
  }

  /// Toggle drawing.
  void toggleDrawingMode() {
    _state.isDrawing = !_state.isDrawing;
    notifyListeners();
  }

  /// Undo.
  void undo() {
    if (_state.points.isEmpty) {
      return;
    }

    bool hitFirstNull = false;
    for (int i = _state.points.length - 1; i > -1; i--) {
      if (_state.points[i] == null && hitFirstNull) {
        break;
      }
      if (_state.points[i] == null) {
        hitFirstNull = true;
        _state.points.removeAt(i);
        _state.redoStack.add(null);
        continue;
      }
      _state.redoStack.add(_state.points[i]);
      _state.points.removeAt(i);
    }

    notifyListeners();
  }

  /// Redo.
  void redo() {
    if (_state.redoStack.isEmpty) {
      return;
    }

    for (int i = _state.redoStack.length - 1; i > -1; i--) {
      if (_state.redoStack[i] == null) {
        _state.redoStack.removeAt(i);
        _state.points.add(null);
        break;
      }
      _state.points.add(_state.redoStack[i]);
      _state.redoStack.removeAt(i);
    }

    notifyListeners();
  }
}
