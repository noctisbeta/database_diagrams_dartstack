import 'package:database_diagrams/overlay_manager/overlay_label.dart';
import 'package:database_diagrams/overlay_manager/overlay_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Dialog header.
class OverlayDialogHeader extends HookConsumerWidget {
  /// Default constructor.
  const OverlayDialogHeader({
    required this.heading,
    required this.label,
    super.key,
  });

  /// Heading
  final String heading;

  /// Overlay label.
  final OverlayLabel label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCloseButtonHovered = useState(false);

    final overlayManager = ref.watch(OverlayManager.provider.notifier);

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
              onTap: () => overlayManager.close(label),
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
