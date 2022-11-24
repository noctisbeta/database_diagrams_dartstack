import 'package:database_diagrams/projects/components/add_project_dialog.dart';
import 'package:flutter/material.dart';

/// Add project tile.
class AddProjectTile extends StatelessWidget {
  /// Default constructor.
  const AddProjectTile({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return const Center(
              child: AddProjectDialog(),
            );
          },
        );
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey,
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
