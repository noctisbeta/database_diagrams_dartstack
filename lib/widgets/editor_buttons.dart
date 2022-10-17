import 'package:database_diagrams/widgets/add_collection_dialog.dart';
import 'package:flutter/material.dart';

/// Editor buttons.
class EditorButtons extends StatelessWidget {
  /// Default constructor.
  const EditorButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
          child: const Icon(Icons.add),
        ),
      ],
    );
  }
}
