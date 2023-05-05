import 'package:database_diagrams/collections/components/add_collection_dialog.dart';
import 'package:database_diagrams/main/mode.dart';
import 'package:database_diagrams/main/mode_controller.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Editor buttons.
class EditorButtons extends ConsumerWidget {
  /// Default constructor.
  const EditorButtons({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modeController = ref.watch(ModeController.provider.notifier);
    final mode = ref.watch(ModeController.provider);

    return Column(
      children: [
        FloatingActionButton(
          backgroundColor: mode == Mode.smartLine
              ? Colors.orange.shade900
              : Colors.orange.shade700,
          hoverColor: mode == Mode.smartLine
              ? Colors.orange.shade600
              : Colors.orange.shade800,
          splashColor: mode == Mode.smartLine
              ? Colors.orange.shade700
              : Colors.orange.shade900,
          onPressed: modeController.toogleSmartLine,
          child: const Icon(Icons.line_axis),
        ),
        const SizedBox(
          height: 16,
        ),
        FloatingActionButton(
          backgroundColor: mode == Mode.text
              ? Colors.orange.shade900
              : Colors.orange.shade700,
          hoverColor: mode == Mode.text
              ? Colors.orange.shade600
              : Colors.orange.shade800,
          splashColor: mode == Mode.text
              ? Colors.orange.shade700
              : Colors.orange.shade900,
          onPressed: modeController.toggleText,
          child: const Icon(Icons.text_fields),
        ),
        const SizedBox(
          height: 16,
        ),
        FloatingActionButton(
          backgroundColor: mode == Mode.polyline
              ? Colors.orange.shade900
              : Colors.orange.shade700,
          hoverColor: mode == Mode.polyline
              ? Colors.orange.shade600
              : Colors.orange.shade800,
          splashColor: mode == Mode.polyline
              ? Colors.orange.shade700
              : Colors.orange.shade900,
          onPressed: modeController.togglePolyline,
          child: const Icon(Icons.polyline),
        ),
        const SizedBox(
          height: 16,
        ),
        FloatingActionButton(
          backgroundColor: mode == Mode.drawing
              ? Colors.orange.shade900
              : Colors.orange.shade700,
          hoverColor: mode == Mode.drawing
              ? Colors.orange.shade600
              : Colors.orange.shade800,
          splashColor: mode == Mode.drawing
              ? Colors.orange.shade700
              : Colors.orange.shade900,
          onPressed: modeController.toggleDrawing,
          child: const Icon(Icons.edit),
        ),
        const SizedBox(
          height: 16,
        ),
        FloatingActionButton(
          backgroundColor: Colors.orange.shade700,
          hoverColor: Colors.orange.shade800,
          onPressed: () {
            showDialog(
              barrierDismissible: false,
              // barrierColor: Colors.black.withOpacity(0.3),
              barrierColor: Colors.transparent,
              context: context,
              builder: (context) {
                return const AddCollectionDialog();
              },
            );
          },
          child: const Icon(
            Icons.add,
            size: 30,
          ),
        ),
      ],
    );
  }
}
