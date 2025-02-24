import 'package:database_diagrams/projects/controllers/project_controller.dart';
import 'package:database_diagrams/projects/models/project.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Project tile.
class ProjectTile extends HookConsumerWidget {
  /// Default constructor.
  const ProjectTile({
    required this.project,
    required this.onTap,
    super.key,
  });

  /// Project.
  final Project project;

  /// On tap.
  final void Function() onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHovered = useState(false);
    final isDeleteHovered = useState(false);

    final projectCtl = ref.watch(ProjectController.provider.notifier);

    return MouseRegion(
      onEnter: (_) => isHovered.value = true,
      onExit: (_) => isHovered.value = false,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Stack(
          children: [
            Container(
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
              child: Center(
                child: Text(
                  project.title,
                  style: const TextStyle(
                    fontSize: 22,
                  ),
                ),
              ),
            ),
            if (isHovered.value)
              // button for delete in the corner
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => projectCtl.deleteProject(project.id).run(),
                  child: MouseRegion(
                    onEnter: (_) => isDeleteHovered.value = true,
                    onExit: (_) => isDeleteHovered.value = false,
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.delete,
                        color: isDeleteHovered.value
                            ? Colors.orange.shade700
                            : Colors.orange.shade900,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
