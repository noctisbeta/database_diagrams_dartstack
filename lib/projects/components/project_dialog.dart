import 'package:database_diagrams/common/dialog_header.dart';
import 'package:database_diagrams/projects/components/create_project_tile.dart';
import 'package:database_diagrams/projects/components/project_tile.dart';
import 'package:database_diagrams/projects/controllers/project_controller.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Project dialog.
class ProjectDialog extends ConsumerWidget {
  /// Default constructor.
  const ProjectDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectStream = ref.watch(ProjectController.projectStreamProvider);
    final projectCtl = ref.watch(ProjectController.provider.notifier);

    return Material(
      type: MaterialType.transparency,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const OverlayDialogHeader(heading: 'Projects'),
            Padding(
              padding: const EdgeInsets.all(16),
              child: projectStream.when(
                data: (data) {
                  return Wrap(
                    runSpacing: 16,
                    spacing: 16,
                    children: [
                      const CreateProjectTile(),
                      for (final project in data)
                        ProjectTile(
                          project: project,
                          onTap: () {
                            projectCtl.openProject(project).run();
                            Navigator.of(context).pop();
                          },
                        ),
                    ],
                  );
                },
                error: (error, stackTrace) {
                  return Center(
                    child: Text(error.toString()),
                  );
                },
                loading: () {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
