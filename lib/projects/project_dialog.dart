import 'package:flutter/material.dart';

/// Project dialog.
class ProjectDialog extends StatelessWidget {
  /// Default constructor.
  const ProjectDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
