import 'package:database_diagrams/projects/components/create_project_dialog.dart';
import 'package:database_diagrams/projects/controllers/project_controller.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Create project tile.
class CreateProjectTile extends ConsumerWidget {
  /// Default constructor.
  const CreateProjectTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return Center(
              child: CreateProjectDialog(
                onCreatePressed: (name) => ref
                    .read(ProjectController.provider.notifier)
                    .createProject(
                      name,
                    )
                    .run()
                    .then(
                      (value) => Navigator.of(context).pop(),
                    ),
              ),
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
