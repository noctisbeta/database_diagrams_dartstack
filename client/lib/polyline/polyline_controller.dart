import 'package:database_diagrams/drawing/drawing_point.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Polyline controller.
class PolylineController extends ChangeNotifier {
  /// Provider.
  static final provider = ChangeNotifierProvider<PolylineController>(
    (ref) => PolylineController(),
  );

  final List<DrawingPoint?> _polylinePoints = [];
  final List<DrawingPoint?> _polylineRedoStack = [];

  double _size = 1;

  /// Size.

  double get size => _size;

  /// Polyline points.
  List<DrawingPoint?> get polylinePoints => _polylinePoints;

  /// Set size.
  void setSize(double size) {
    _size = size;
    notifyListeners();
  }

  /// Add polyline point.
  void addPolylinePoint(DrawingPoint? point) {
    _polylinePoints.add(point);

    // for the indicator
    if (point != null) {
      _polylinePoints.add(point);
    }

    notifyListeners();
  }

  /// Update indicator.
  void updatePolylineIndicator(DrawingPoint point) {
    if (_polylinePoints.last == null) {
      return;
    }
    _polylinePoints.last = point;
    notifyListeners();
  }

  /// Undo polyline.
  void undo() {
    if (_polylinePoints.isEmpty) {
      return;
    }

    bool hitFirstNull = false;
    // TODO(Janez): rework all undos, dont modify array under loop.
    for (int i = _polylinePoints.length - 1; i > -1; i--) {
      if (_polylinePoints[i] == null && hitFirstNull) {
        break;
      }
      if (_polylinePoints[i] == null) {
        hitFirstNull = true;
        _polylinePoints.removeAt(i);
        _polylineRedoStack.add(null);
        continue;
      }
      _polylineRedoStack.add(_polylinePoints[i]);
      _polylinePoints.removeAt(i);
    }

    notifyListeners();
  }

  /// Redo polyline.
  void redo() {
    if (_polylineRedoStack.isEmpty) {
      return;
    }

    for (int i = _polylineRedoStack.length - 1; i > -1; i--) {
      if (_polylineRedoStack[i] == null) {
        _polylineRedoStack.removeAt(i);
        _polylinePoints.add(null);
        break;
      }
      _polylinePoints.add(_polylineRedoStack[i]);
      _polylineRedoStack.removeAt(i);
    }

    notifyListeners();
  }
}
