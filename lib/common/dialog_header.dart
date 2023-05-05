import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Dialog header.
class DialogHeader extends HookWidget {
  /// Default constructor.
  const DialogHeader({
    required this.heading,
    super.key,
  });

  /// Heading
  final String heading;

  @override
  Widget build(BuildContext context) {
    final isCloseButtonHovered = useState(false);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.orange[700],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            const Spacer(),
            Text(
              heading,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: Navigator.of(context).pop,
              child: MouseRegion(
                onEnter: (_) => isCloseButtonHovered.value = true,
                onExit: (_) => isCloseButtonHovered.value = false,
                cursor: SystemMouseCursors.click,
                child: AnimatedRotation(
                  duration: const Duration(milliseconds: 150),
                  turns: isCloseButtonHovered.value ? -0.25 : 0,
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
