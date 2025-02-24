import 'package:flutter/material.dart';

/// MyButton.
class MyButton extends StatelessWidget {
  /// Default constructor.
  const MyButton({
    required this.label,
    required this.onPressed,
    this.isDisabled = false,
    this.isLoading = false,
    super.key,
  });

  /// Label.
  final String label;

  /// On pressed.
  final void Function() onPressed;

  /// Is loading.
  final bool isLoading;

  /// Is disabled.
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: isDisabled || isLoading,
      child: isLoading
          ? CircularProgressIndicator(
              color: Colors.orange.shade700,
            )
          : ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  isDisabled ? Colors.grey : Colors.orange.shade700,
                ),
              ),
              onPressed: onPressed,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
    );
  }
}
