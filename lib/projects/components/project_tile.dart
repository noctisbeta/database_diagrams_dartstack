import 'package:database_diagrams/projects/models/project.dart';
import 'package:flutter/material.dart';

/// Project tile.
class ProjectTile extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
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
        child: Center(
          child: Text(
            project.title,
          ),
        ),
      ),
    );
  }
}
