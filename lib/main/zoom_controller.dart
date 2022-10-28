import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Zoom controller.
class ZoomController extends StateNotifier<double> {
  /// Default constructor.
  ZoomController() : super(1);

  /// Provides the controller.
  static final provider = StateNotifierProvider<ZoomController, double>(
    (ref) => ZoomController(),
  );

  /// Transformation controller.
  final TransformationController transformationController = TransformationController();

  /// Zoom in.
  void zoomIn() {
    state = state * 1.1;
  }

  /// Zoom out.
  void zoomOut() {
    state = state * 0.9;
  }
}
