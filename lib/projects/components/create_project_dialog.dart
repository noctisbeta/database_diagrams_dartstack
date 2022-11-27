import 'package:database_diagrams/main/my_button.dart';
import 'package:database_diagrams/main/my_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Create project dialog.
class CreateProjectDialog extends HookWidget {
  /// Default constructor.
  const CreateProjectDialog({
    required this.onCreatePressed,
    super.key,
  });

  /// On created callback.
  final void Function(String projectName) onCreatePressed;

  @override
  Widget build(BuildContext context) {
    final textCtl = useTextEditingController();

    final isDisabled = useState(false);
    final isLoading = useState(false);

    textCtl.addListener(() {
      isDisabled.value = textCtl.text.isEmpty;
    });

    return Material(
      type: MaterialType.transparency,
      child: Center(
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
                isDisabled: isDisabled.value,
                isLoading: isLoading.value,
                onPressed: () => {
                  isLoading.value = true,
                  onCreatePressed(textCtl.text),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
