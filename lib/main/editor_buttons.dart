import 'package:database_diagrams/collections/components/add_collection_dialog.dart';
import 'package:database_diagrams/common/my_fab.dart';
import 'package:database_diagrams/main/mode.dart';
import 'package:database_diagrams/main/mode_controller.dart';
import 'package:database_diagrams/overlay_manager/overlay_label.dart';
import 'package:database_diagrams/overlay_manager/overlay_manager.dart';
import 'package:database_diagrams/utilities/iterable_extension.dart';
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

    final overlayManager = ref.watch(OverlayManager.provider.notifier);

    return Column(
      children: <Widget>[
        MyFab(
          colorToggle: mode == Mode.smartLine,
          icon: Icons.line_axis,
          onPressed: modeController.toogleSmartLine,
        ),
        MyFab(
          colorToggle: mode == Mode.text,
          icon: Icons.text_fields,
          onPressed: modeController.toggleText,
        ),
        MyFab(
          colorToggle: mode == Mode.polyline,
          icon: Icons.polyline,
          onPressed: modeController.togglePolyline,
        ),
        MyFab(
          colorToggle: mode == Mode.drawing,
          icon: Icons.edit,
          onPressed: modeController.toggleDrawing,
        ),
        FloatingActionButton(
          backgroundColor: Colors.orange.shade700,
          hoverColor: Colors.orange.shade800,
          onPressed: () {
            overlayManager.open(
              OverlayLabel.addCollection,
              const AddCollectionDialog(),
            );
            // showDialog(
            //   barrierDismissible: false,
            //   // barrierColor: Colors.black.withOpacity(0.3),
            //   barrierColor: Colors.transparent,
            //   context: context,
            //   builder: (context) {
            //     return const AddCollectionDialog();
            //   },
            // );
            // Overlay.of(context).insert(
            //   OverlayEntry(
            //     builder: (context) {
            //       return const AddCollectionDialog();
            //     },
            //   ),
            // );
          },
          child: const Icon(
            Icons.add,
            size: 30,
          ),
        ),
      ].separatedByToList(const SizedBox(height: 16)),
    );
  }
}
