import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vector_math/vector_math_64.dart';

/// Canvas controller.
class CanvasController {
  /// Default constructor.
  CanvasController();

  /// Provider.
  static final provider = Provider(
    (ref) => CanvasController(),
  );

  /// Viewport.
  Quad viewport = Quad();

  /// Container key.
  static const canvasContainerKey = GlobalObjectKey('canvasContainerKey');

  /// Canvas height.
  static const height = 4000.0;

  /// Canvas width.
  static const width = 4000.0;

  /// Top left point of the viewport clamped to canvas.
  Offset get topLeft => Offset(
        viewport.point0.x.clamp(0, width),
        viewport.point0.y.clamp(0, height),
      );
}
