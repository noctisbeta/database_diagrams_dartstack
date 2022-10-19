import 'package:database_diagrams/controllers/drawing_controller.dart';
import 'package:database_diagrams/widgets/drawing_painter.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Drawing painter container.
class DrawingPainterContainer extends ConsumerWidget {
  /// Default constructor.
  const DrawingPainterContainer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drawingController = ref.watch(DrawingController.provider);

    return Positioned.fill(
      child: AbsorbPointer(
        absorbing: !drawingController.isDrawing,
        child: GestureDetector(
          onPanStart: (details) {
            drawingController.addDrawingPoint(details.localPosition);
          },
          onPanUpdate: (details) {
            drawingController.addDrawingPoint(details.localPosition);
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
