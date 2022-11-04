import 'package:database_diagrams/projects/project_controller.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Project dialog.
class ProjectDialog extends ConsumerWidget {
  /// Default constructor.
  const ProjectDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectStream = ref.watch(ProjectController.projectStreamProvider);

    return Material(
      type: MaterialType.transparency,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: projectStream.when(
          data: (data) {
            return ListView.builder(
              itemCount: data.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Add project button.
                  return ListTile(
                    leading: const Icon(Icons.add),
                    title: const Text('Add project'),
                    onTap: () {},
                  );
                }
                return ListTile(
                  title: Text(data[index].title),
                );
              },
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
    );
  }
}
