import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Profile menu button.
class ProfileMenuButton extends HookWidget {
  /// Default constructor.
  const ProfileMenuButton({
    required this.label,
    required this.icon,
    super.key,
  });

  /// Label.
  final String label;

  /// Icon.
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    final isHovered = useState(false);

    return MouseRegion(
      onEnter: (_) => isHovered.value = true,
      onExit: (_) => isHovered.value = false,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isHovered.value ? Colors.grey[200] : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 32,
            ),
            icon,
            const SizedBox(
              width: 16,
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
