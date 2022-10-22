import 'package:flutter/material.dart';

/// MyButton.
class MyButton extends StatelessWidget {
  /// Default constructor.
  const MyButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  /// Label.
  final String label;

  /// On pressed.
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          Colors.orange.shade700,
        ),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
    );
  }
}
