import 'package:database_diagrams/projects/components/create_project_dialog.dart';
import 'package:database_diagrams/projects/controllers/project_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Create project tile.
class CreateProjectTile extends HookConsumerWidget {
  /// Default constructor.
  const CreateProjectTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHovered = useState(false);

    return GestureDetector(
      onTap: () => showDialog(
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
      ),
      child: MouseRegion(
        onEnter: (_) => isHovered.value = true,
        onExit: (_) => isHovered.value = false,
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isHovered.value ? Colors.orange.shade700 : Colors.grey,
              width: isHovered.value ? 2 : 1,
            ),
          ),
          child: Icon(
            Icons.add,
            size: 50,
            color: isHovered.value ? Colors.orange.shade700 : Colors.grey,
          ),
        ),
      ),
    );
  }
}
