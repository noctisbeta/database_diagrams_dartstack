import 'package:database_diagrams/main/my_button.dart';
import 'package:database_diagrams/main/my_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Create project dialog.
class CreateProjectDialog extends HookWidget {
  /// Default constructor.
  const CreateProjectDialog({
    required this.onCreate,
    super.key,
  });

  /// On created callback.
  final void Function(String projectName) onCreate;

  @override
  Widget build(BuildContext context) {
    final textCtl = useTextEditingController();

    return Material(
      type: MaterialType.transparency,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.2,
        height: MediaQuery.of(context).size.height * 0.2,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            const Text(
              'Create project',
              style: TextStyle(
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 16),
            MyTextField(
              label: 'Title',
              controller: textCtl,
            ),
            const Spacer(),
            MyButton(
              label: 'Create',
              onPressed: () => onCreate(textCtl.text),
            ),
          ],
        ),
      ),
    );
  }
}
