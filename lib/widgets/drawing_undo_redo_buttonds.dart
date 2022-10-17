import 'dart:developer';

import 'package:database_diagrams/controllers/drawing_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Editor buttons.
class DrawingUndoRedoButtons extends HookConsumerWidget {
  /// Default constructor.
  const DrawingUndoRedoButtons({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctl = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );

    final drawingController = ref.watch(DrawingController.provider.notifier);

    // TODO(Janez): Fires on every draw input. Seperate the drawing mode toggle notifier.
    ref.listen(
      DrawingController.provider,
      (previous, next) {
        log('inside listener');
        if (next.isDrawing) {
          ctl.forward();
        } else {
          ctl.reverse();
        }
      },
    );

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 2),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: ctl, curve: Curves.easeOutBack),
      ),
      child: Row(
        children: [
          FloatingActionButton(
            backgroundColor: Colors.orange.shade700,
            hoverColor: Colors.orange.shade800,
            onPressed: drawingController.undo,
            child: const Icon(
              Icons.keyboard_double_arrow_left,
            ),
          ),
          const SizedBox(
            width: 16,
          ),
          FloatingActionButton(
            backgroundColor: Colors.orange.shade700,
            hoverColor: Colors.orange.shade800,
            onPressed: drawingController.redo,
            child: const Icon(
              Icons.keyboard_double_arrow_right,
            ),
          ),
        ],
      ),
    );
  }
}
