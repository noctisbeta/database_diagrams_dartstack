import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Hoverable button.
class ToolbarButton extends HookWidget {
  /// Default constructor.
  const ToolbarButton({
    required this.label,
    this.onTap,
    this.onTapUp,
    super.key,
  });

  /// Label.
  final String label;

  /// On tap.
  final void Function()? onTap;

  /// On tap up.
  final void Function(TapUpDetails)? onTapUp;

  @override
  Widget build(BuildContext context) {
    final isHovering = useState(false);

    return GestureDetector(
      onTap: onTap,
      onTapUp: onTapUp,
      child: MouseRegion(
        onEnter: (event) {
          isHovering.value = true;
        },
        onExit: (event) {
          isHovering.value = false;
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: isHovering.value
                ? Colors.orange.shade900
                : Colors.orange.shade700,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}
