import 'package:database_diagrams/drawing/drawing_point.dart';
import 'package:database_diagrams/drawing/drawing_state.dart';
import 'package:database_diagrams/main/mode.dart';
import 'package:database_diagrams/main/mode_controller.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Drawing controller.
class DrawingController extends ChangeNotifier {
  /// Default constructor.
  DrawingController(this._ref) : _state = DrawingState.initial();

  /// Riverpod ref.
  final Ref _ref;

  /// State.
  final DrawingState _state;

  // TODO(Janez): Must not be a getter. Change _state.drawingPoints to type DrawingPoint.
  /// Drawing points.
  List<DrawingPoint?> get drawingPoints => _state.drawingPoints;

  /// Polyline points.
  List<DrawingPoint?> get polylinePoints => _state.polylinePoints;

  double _drawingSize = 1;

  double _polylineSize = 1;

  /// Drawing size.
  double get drawingSize => _drawingSize;

  /// Polyline size.
  double get polylineSize => _polylineSize;

  /// Size.
  double get size => _ref.read(ModeController.provider) == Mode.drawing ? _drawingSize : _polylineSize;

  /// Provider.
  static final provider = ChangeNotifierProvider<DrawingController>(
    DrawingController.new,
  );

  /// Set size.
  void setSize(double newSize) {
    final mode = _ref.read(ModeController.provider);

    if (mode == Mode.drawing) {
      _drawingSize = newSize;
      notifyListeners();
    } else if (mode == Mode.polyline) {
      _polylineSize = newSize;
      notifyListeners();
    }
  }

  /// Add drawing point.
  void addDrawingPoint(DrawingPoint? point) {
    _state.drawingPoints.add(point);
    notifyListeners();
  }

  /// Add polyline point.
  void addPolylinePoint(DrawingPoint? point) {
    _state.polylinePoints.add(point);

    // for the indicator
    if (point != null) {
      _state.polylinePoints.add(point);
    }

    notifyListeners();
  }

  /// Update indicator.
  void updatePolylineIndicator(DrawingPoint point) {
    _state.polylinePoints.last = point;
    notifyListeners();
  }

  /// Undo.
  void undo() {
    final mode = _ref.read(ModeController.provider);

    if (mode == Mode.drawing) {
      _undoDraw.call();
    } else if (mode == Mode.polyline) {
      _undoPolyline.call();
    }
    notifyListeners();
  }

  /// Redo.
  void redo() {
    final mode = _ref.read(ModeController.provider);
    if (mode == Mode.drawing) {
      _redoDraw.call();
    } else if (mode == Mode.polyline) {
      _redoPolyline.call();
    }
    notifyListeners();
  }

  /// Undo polyline.
  void _undoPolyline() {
    if (_state.polylinePoints.isEmpty) {
      return;
    }

    bool hitFirstNull = false;
    // TODO(Janez): rework all todos, dont modify array under loop.
    for (int i = _state.polylinePoints.length - 1; i > -1; i--) {
      if (_state.polylinePoints[i] == null && hitFirstNull) {
        break;
      }
      if (_state.polylinePoints[i] == null) {
        hitFirstNull = true;
        _state.polylinePoints.removeAt(i);
        _state.polylinePoints.add(null);
        continue;
      }
      _state.polylineRedoStack.add(_state.polylinePoints[i]);
      _state.polylinePoints.removeAt(i);
    }

    notifyListeners();
  }

  /// Redo polyline.
  void _redoPolyline() {}

  /// Undo draw.
  void _undoDraw() {
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
  void _redoDraw() {
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
