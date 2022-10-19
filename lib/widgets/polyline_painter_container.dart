import 'dart:developer';

import 'package:database_diagrams/controllers/drawing_controller.dart';
import 'package:database_diagrams/widgets/polyline_painter.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Drawing painter container.
class PolylinePainterContainer extends ConsumerWidget {
  /// Default constructor.
  const PolylinePainterContainer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drawingController = ref.watch(DrawingController.provider);

    return Positioned.fill(
      child: AbsorbPointer(
        absorbing: !drawingController.isPolyline,
        child: MouseRegion(
          onHover: (event) {
            if (!drawingController.isPolyline) {
              return;
            }
            if (drawingController.polylinePoints.isEmpty) {
              return;
            }
            if (drawingController.polylinePoints.last != null) {
              drawingController.updatePolylineIndicator(event.localPosition);
            }
          },
          child: GestureDetector(
            onLongPressDown: (_) {
              drawingController.addPolylinePoint(null);
            },
            onTapUp: (details) {
              drawingController.addPolylinePoint(details.localPosition);
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
