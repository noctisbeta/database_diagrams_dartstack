import 'dart:developer';

import 'package:database_diagrams/main/mode.dart';
import 'package:database_diagrams/main/mode_controller.dart';
import 'package:database_diagrams/text/my_text_controller.dart';
import 'package:database_diagrams/text/my_text_item.dart';
import 'package:database_diagrams/text/my_text_painter.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Text painter.
class MyTextPainterContainer extends ConsumerWidget {
  /// Default constructor.
  const MyTextPainterContainer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(ModeController.provider);
    final textController = ref.watch(MyTextController.provider);

    return Positioned.fill(
      child: AbsorbPointer(
        absorbing: mode != Mode.text,
        child: GestureDetector(
          onTapUp: (details) {
            log('on tap up');
            textController.addTextItem(
              MyTextItem(
                offset: details.localPosition,
                size: textController.size,
                text: 'text',
              ),
            );
          },
          child: CustomPaint(
            painter: MyTextPainter(
              textItems: textController.textItems,
            ),
          ),
        ),
      ),
    );
  }
}
