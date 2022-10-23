import 'package:database_diagrams/drawing/drawing_point.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Drawing controller.
class DrawingController extends ChangeNotifier {
  final List<DrawingPoint?> _drawingPoints = [];

  final List<DrawingPoint?> _drawingRedoStack = [];

  /// Drawing points.
  List<DrawingPoint?> get drawingPoints => _drawingPoints;

  double _size = 1;

  /// Size.
  double get size => _size;

  /// Provider.
  static final provider = ChangeNotifierProvider<DrawingController>(
    (ref) => DrawingController(),
  );

  /// Add drawing point.
  void addDrawingPoint(DrawingPoint? point) {
    _drawingPoints.add(point);
    notifyListeners();
  }

  /// Undo draw.
  void undo() {
    if (_drawingPoints.isEmpty) {
      return;
    }

    bool hitFirstNull = false;
    for (int i = _drawingPoints.length - 1; i > -1; i--) {
      if (_drawingPoints[i] == null && hitFirstNull) {
        break;
      }
      if (_drawingPoints[i] == null) {
        hitFirstNull = true;
        _drawingPoints.removeAt(i);
        _drawingRedoStack.add(null);
        continue;
      }
      _drawingRedoStack.add(_drawingPoints[i]);
      _drawingPoints.removeAt(i);
    }

    notifyListeners();
  }

  /// Redo.
  void redo() {
    if (_drawingRedoStack.isEmpty) {
      return;
    }

    for (int i = _drawingRedoStack.length - 1; i > -1; i--) {
      if (_drawingRedoStack[i] == null) {
        _drawingRedoStack.removeAt(i);
        _drawingPoints.add(null);
        break;
      }
      _drawingPoints.add(_drawingRedoStack[i]);
      _drawingRedoStack.removeAt(i);
    }

    notifyListeners();
  }

  /// Set size.
  void setSize(double size) {
    _size = size;
    notifyListeners();
  }
}
