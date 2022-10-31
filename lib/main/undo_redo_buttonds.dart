import 'package:database_diagrams/drawing/drawing_controller.dart';
import 'package:database_diagrams/main/mode.dart';
import 'package:database_diagrams/main/mode_controller.dart';
import 'package:database_diagrams/polyline/polyline_controller.dart';
import 'package:database_diagrams/text_tool/text_tool_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Editor buttons.
class UndoRedoButtons extends HookConsumerWidget {
  /// Default constructor.
  const UndoRedoButtons({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctl = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );

    final mode = ref.watch(ModeController.provider);

    ref.listen(
      ModeController.provider,
      (previous, next) {
        if (next.isUndoable && (!(previous?.isUndoable ?? false))) {
          ctl.forward();
        } else if (!next.isUndoable) {
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
            onPressed: () {
              switch (mode) {
                case Mode.polyline:
                  ref.read(PolylineController.provider.notifier).undo();
                  break;
                case Mode.drawing:
                  ref.read(DrawingController.provider.notifier).undo();
                  break;
                case Mode.text:
                  ref.read(TextToolController.provider.notifier).undo();
                  break;
                case Mode.smartLine:
                  break;
                case Mode.none:
                  break;
              }
            },
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
            onPressed: () {
              switch (mode) {
                case Mode.polyline:
                  ref.read(PolylineController.provider.notifier).redo();
                  break;
                case Mode.drawing:
                  ref.read(DrawingController.provider.notifier).redo();
                  break;

                case Mode.text:
                  ref.read(TextToolController.provider.notifier).redo();
                  break;
                case Mode.smartLine:
                  break;
                case Mode.none:
                  break;
              }
            },
            child: const Icon(
              Icons.keyboard_double_arrow_right,
            ),
          ),
        ],
      ),
    );
  }
}
