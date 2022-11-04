import 'package:database_diagrams/projects/project.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

/// Project tile.
class ProjectTile extends StatelessWidget {
  /// Default constructor.
  const ProjectTile({
    required this.project,
    super.key,
  });

  /// Project.
  final Project project;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.add),
    );
  }
}
