import 'package:database_diagrams/drawing/drawing_controller.dart';
import 'package:database_diagrams/main/mode.dart';
import 'package:database_diagrams/main/mode_controller.dart';
import 'package:database_diagrams/polyline/polyline_controller.dart';
import 'package:database_diagrams/text/my_text_controller.dart';
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

    final mode = ref.watch(ModeController.provider);

    ref.listen(
      ModeController.provider,
      (previous, next) {
        if (next.isUndoable && (!(previous?.isUndoable ?? false))) {
          ctl.forward();
        } else if (!next.isUndoable) {
          ctl.reverse();
        }
      },
    );

    double size() {
      switch (mode) {
        case Mode.polyline:
          return ref.watch(PolylineController.provider).size;
        case Mode.drawing:
          return ref.watch(DrawingController.provider).size;
        case Mode.smartLine:
          return 1;
        case Mode.none:
          return 1;
        case Mode.text:
          return ref.watch(MyTextController.provider).size;
      }
    }

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 3),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: ctl, curve: Curves.easeOutBack),
      ),
      child: SliderTheme(
        data: SliderThemeData(overlayShape: SliderComponentShape.noOverlay),
        child: Slider(
          value: size(),
          min: 1,
          max: 100,
          onChanged: (value) {
            switch (mode) {
              case Mode.smartLine:
                break;
              case Mode.drawing:
                ref.read(DrawingController.provider).setSize(value);
                break;
              case Mode.polyline:
                ref.read(PolylineController.provider).setSize(value);
                break;
              case Mode.text:
                ref.read(MyTextController.provider).setSize(value);
                break;
              case Mode.none:
                break;
            }
          },
          thumbColor: Colors.orange.shade700,
          activeColor: Colors.orange.shade900,
          inactiveColor: Colors.orange.shade900.withOpacity(0.5),
        ),
      ),
    );
  }
}
