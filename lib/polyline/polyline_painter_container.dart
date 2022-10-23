import 'package:database_diagrams/drawing/drawing_point.dart';
import 'package:database_diagrams/main/mode.dart';
import 'package:database_diagrams/main/mode_controller.dart';
import 'package:database_diagrams/polyline/polyline_controller.dart';
import 'package:database_diagrams/polyline/polyline_painter.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Drawing painter container.
class PolylinePainterContainer extends ConsumerWidget {
  /// Default constructor.
  const PolylinePainterContainer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(ModeController.provider);
    final polylineController = ref.watch(PolylineController.provider);

    return Positioned.fill(
      child: AbsorbPointer(
        absorbing: mode != Mode.polyline,
        child: MouseRegion(
          onHover: (event) {
            if (mode != Mode.polyline) {
              return;
            }
            if (polylineController.polylinePoints.isEmpty) {
              return;
            }
            if (polylineController.polylinePoints.last != null) {
              polylineController.updatePolylineIndicator(
                DrawingPoint(
                  point: event.localPosition,
                  size: polylineController.size,
                ),
              );
            }
          },
          child: GestureDetector(
            onLongPress: () {
              polylineController.addPolylinePoint(null);
            },
            onTapUp: (details) {
              polylineController.addPolylinePoint(
                DrawingPoint(
                  point: details.localPosition,
                  size: polylineController.size,
                ),
              );
            },
            // TODO(Janez): Optimize. Dynamic number of painters scaled with the size of points array.
            child: RepaintBoundary(
              child: CustomPaint(
                isComplex: true,
                willChange: true,
                painter: PolylinePainter(
                  points: polylineController.polylinePoints,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
