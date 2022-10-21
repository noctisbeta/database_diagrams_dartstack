import 'package:database_diagrams/drawing/drawing_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Size slider.
class SizeSlider extends HookConsumerWidget {
  /// Default constructor.
  const SizeSlider({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctl = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );

    final drawingController = ref.watch(DrawingController.provider);

    // TODO(Janez): Fires on every draw input. Seperate the drawing mode toggle notifier.
    ref.listen(
      DrawingController.provider,
      (previous, next) {
        if (next.isUndoable) {
          ctl.forward();
        } else {
          ctl.reverse();
        }
      },
    );

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 2),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: ctl, curve: Curves.easeOutBack),
      ),
      child: SliderTheme(
        data: SliderThemeData(overlayShape: SliderComponentShape.noOverlay),
        child: Slider(
          value: drawingController.size,
          min: 1,
          max: 100,
          onChanged: drawingController.setSize,
          thumbColor: Colors.orange.shade700,
          activeColor: Colors.orange.shade900,
          inactiveColor: Colors.orange.shade900.withOpacity(0.5),
        ),
      ),
    );
  }
}
