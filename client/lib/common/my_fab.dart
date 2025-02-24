import 'package:flutter/material.dart';

/// My fab.
class MyFab extends StatelessWidget {
  /// Default constructor.
  const MyFab({
    required this.onPressed,
    required this.colorToggle,
    required this.icon,
    super.key,
  });

  /// On pressed.
  final VoidCallback onPressed;

  /// Color toggle.
  final bool colorToggle;

  /// Icon.
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor:
          colorToggle ? Colors.orange.shade900 : Colors.orange.shade700,
      hoverColor: colorToggle ? Colors.orange.shade600 : Colors.orange.shade800,
      splashColor:
          colorToggle ? Colors.orange.shade700 : Colors.orange.shade900,
      onPressed: onPressed,
      child: Icon(icon),
    );
  }
}
