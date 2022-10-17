import 'package:database_diagrams/models/drawing_state.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Drawing controller.
class DrawingController extends ChangeNotifier {
  /// Default constructor.
  DrawingController() : _state = DrawingState.initial();

  /// State.
  final DrawingState _state;

  // Getters

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

  void undo() {
    if (_state.points.isEmpty) {
      return;
    }

    // for(int i = _state.points.length; i > -1; i--) {
    //   if(_state.points[i] != null) {
    //     _state.points.removeAt(i);
    //     break;
    //   }
    // }

    // _state.points.removeRange()
    notifyListeners();
  }
}
