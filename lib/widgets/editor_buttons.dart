import 'package:database_diagrams/controllers/drawing_controller.dart';
import 'package:database_diagrams/widgets/add_collection_dialog.dart';
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
    // final drawingController = ref.watch(DrawingController.provider.notifier);
    // final isDrawing = ref.watch(DrawingController.provider).isDrawing;

    final drawingControllerMut = ref.watch(DrawingController.provider);
    final isDrawing = drawingControllerMut.isDrawing;

    return Column(
      children: [
        FloatingActionButton(
          backgroundColor: isDrawing ? Colors.orange.shade900 : Colors.orange.shade700,
          hoverColor: isDrawing ? Colors.orange.shade600 : Colors.orange.shade800,
          splashColor: isDrawing ? Colors.orange.shade700 : Colors.orange.shade900,
          onPressed: drawingControllerMut.toggleDrawingMode,
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
              barrierColor: Colors.black.withOpacity(0.3),
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
