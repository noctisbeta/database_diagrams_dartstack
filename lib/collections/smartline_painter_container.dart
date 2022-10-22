import 'package:database_diagrams/collections/smartline_controller.dart';
import 'package:database_diagrams/collections/smartline_painter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// SmartlinePainterContainer.
class SmartlinePainterContainer extends ConsumerWidget {
  /// Default constructor.
  const SmartlinePainterContainer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final smartlineController = ref.watch(SmartlineController.provider);

    return CustomPaint(
      painter: SmartlinePainter(
        anchors: smartlineController.anchors,
      ),
    );
  }
}
