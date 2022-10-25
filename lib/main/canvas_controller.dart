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

  Quad viewport = Quad();

  static const canvasContainerKey = GlobalObjectKey('canvasContainerKey');
}
