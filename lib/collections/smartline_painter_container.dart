import 'dart:developer';

import 'package:database_diagrams/collections/smartline_controller.dart';
import 'package:database_diagrams/collections/smartline_painter.dart';
import 'package:database_diagrams/main/canvas_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// SmartlinePainterContainer.
class SmartlinePainterContainer extends HookConsumerWidget {
  /// Default constructor.
  const SmartlinePainterContainer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final smartlineController = ref.watch(SmartlineController.provider);

    return Positioned.fill(
      child: CustomPaint(
        painter: SmartlinePainter(
          anchors: smartlineController.anchors,
        ),
      ),
    );
  }
}
