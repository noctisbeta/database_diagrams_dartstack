import 'package:database_diagrams/drawing/drawing_controller.dart';
import 'package:database_diagrams/drawing/drawing_point.dart';
import 'package:database_diagrams/drawing/polyline_painter.dart';
import 'package:database_diagrams/main/mode.dart';
import 'package:database_diagrams/main/mode_controller.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Drawing painter container.
class PolylinePainterContainer extends ConsumerWidget {
  /// Default constructor.
  const PolylinePainterContainer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(ModeController.provider);
    final drawingController = ref.watch(DrawingController.provider);

    return Positioned.fill(
      child: AbsorbPointer(
        absorbing: mode != Mode.polyline,
        child: MouseRegion(
          onHover: (event) {
            if (mode != Mode.polyline) {
              return;
            }
            if (drawingController.polylinePoints.isEmpty) {
              return;
            }
            if (drawingController.polylinePoints.last != null) {
              drawingController.updatePolylineIndicator(
                DrawingPoint(
                  point: event.localPosition,
                  size: drawingController.polylineSize,
                ),
              );
            }
          },
          child: GestureDetector(
            onLongPress: () {
              drawingController.addPolylinePoint(null);
            },
            onTapUp: (details) {
              drawingController.addPolylinePoint(
                DrawingPoint(
                  point: details.localPosition,
                  size: drawingController.polylineSize,
                ),
              );
            },
            // TODO(Janez): Optimize. Dynamic number of painters scaled with the size of points array.
            child: RepaintBoundary(
              child: CustomPaint(
                isComplex: true,
                willChange: true,
                painter: PolylinePainter(
                  points: drawingController.polylinePoints,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
