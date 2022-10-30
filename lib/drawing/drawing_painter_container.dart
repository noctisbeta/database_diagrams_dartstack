import 'package:database_diagrams/drawing/drawing_controller.dart';
import 'package:database_diagrams/drawing/drawing_painter.dart';
import 'package:database_diagrams/drawing/drawing_point.dart';
import 'package:database_diagrams/main/mode.dart';
import 'package:database_diagrams/main/mode_controller.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Drawing painter container.
class DrawingPainterContainer extends ConsumerWidget {
  /// Default constructor.
  const DrawingPainterContainer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(ModeController.provider);
    final drawingController = ref.watch(DrawingController.provider);

    return Positioned.fill(
      child: AbsorbPointer(
        absorbing: mode != Mode.drawing,
        child: GestureDetector(
          onPanStart: (details) {
            drawingController.addDrawingPoint(
              DrawingPoint(
                point: details.localPosition,
                size: drawingController.size,
              ),
            );
          },
          onPanUpdate: (details) {
            drawingController.addDrawingPoint(
              DrawingPoint(
                point: details.localPosition,
                size: drawingController.size,
              ),
            );
          },
          onPanEnd: (details) {
            drawingController.addDrawingPoint(null);
          },
          // TODO(Janez): Optimize. Dynamic number of painters scaled with the size of points array.
          child: RepaintBoundary(
            child: CustomPaint(
              isComplex: true,
              willChange: true,
              painter: DrawingPainter(
                points: drawingController.drawingPoints,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
