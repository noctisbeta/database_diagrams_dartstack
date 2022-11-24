import 'package:database_diagrams/main/my_button.dart';
import 'package:database_diagrams/main/my_text_field.dart';
import 'package:database_diagrams/projects/controllers/project_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Add project dialog.
class AddProjectDialog extends HookConsumerWidget {
  /// Default constructor.
  const AddProjectDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textCtl = useTextEditingController();

    return Material(
      type: MaterialType.transparency,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5,
        height: MediaQuery.of(context).size.height * 0.5,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            SizedBox(
              width: 400,
              child: Column(
                children: [
                  MyTextField(
                    label: 'Title',
                    controller: textCtl,
                  ),
                ],
              ),
            ),
            const Spacer(),
            MyButton(
              label: 'Add',
              onPressed: () {
                ref.read(ProjectController.provider.notifier).createProject(
                      textCtl.text,
                    );
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
