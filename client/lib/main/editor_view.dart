import 'package:database_diagrams/collections/components/collection_card.dart';
import 'package:database_diagrams/collections/controllers/collection_store.dart';
import 'package:database_diagrams/drawing/drawing_painter_container.dart';
import 'package:database_diagrams/main/canvas_controller.dart';
import 'package:database_diagrams/main/editor_buttons.dart';
import 'package:database_diagrams/main/mode.dart';
import 'package:database_diagrams/main/mode_controller.dart';
import 'package:database_diagrams/main/size_slider.dart';
import 'package:database_diagrams/main/undo_redo_buttonds.dart';
import 'package:database_diagrams/overlay_manager/overlay_manager.dart';
import 'package:database_diagrams/polyline/polyline_painter_container.dart';
import 'package:database_diagrams/smartline/smartline_painter_container.dart';
import 'package:database_diagrams/text_tool/components/my_text_painter_container.dart';
import 'package:database_diagrams/text_tool/components/text_mode_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

/// Editor view.
class EditorView extends HookConsumerWidget {
  /// Default constructor.
  const EditorView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(ModeController.provider);

    final overlays = ref.watch(OverlayManager.provider);

    final focusStack = useState<List<Widget>>(
      [
        const DrawingPainterContainer(),
        const PolylinePainterContainer(),
        const MyTextPainterContainer(),
        const SmartlinePainterContainer(),
      ],
    );

    final focusStackIndexes = useState<List<int>>(
      List.generate(focusStack.value.length, (index) => index),
    );

    final transformationController = useTransformationController();
    final screenSize = MediaQuery.of(context).size;

    ref.listen(
      ModeController.provider,
      (previous, next) {
        switch (next) {
          case Mode.drawing:
            focusStackIndexes.value = [1, 2, 3, 0];
            break;
          case Mode.polyline:
            focusStackIndexes.value = [2, 3, 0, 1];
            break;
          case Mode.text:
            focusStackIndexes.value = [3, 0, 1, 2];
            break;
          case Mode.smartLine:
            focusStackIndexes.value = [0, 1, 2, 3];
            break;
          case Mode.none:
            break;
        }
      },
    );

    useEffect(
      () {
        transformationController.value.setTranslation(
          Vector3(
            -CanvasController.width / 2 + screenSize.width / 2,
            -CanvasController.height / 2 + screenSize.height / 2,
            0,
          ),
        );

        return transformationController.dispose;
      },
      const [],
    );

    return Scaffold(
      backgroundColor: const Color.fromRGBO(20, 20, 20, 1),
      body: MouseRegion(
        cursor: mode == Mode.drawing
            ? SystemMouseCursors.precise
            : mode == Mode.polyline
                ? SystemMouseCursors.cell
                : SystemMouseCursors.basic,
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer.builder(
              transformationController: transformationController,
              boundaryMargin: const EdgeInsets.all(10000),
              minScale: 0.01,
              maxScale: 10,
              scaleFactor: 400,
              builder: (context, viewport) {
                ref.read(CanvasController.provider).viewport = viewport;

                return Container(
                  key: CanvasController.canvasContainerKey,
                  width: CanvasController.width,
                  height: CanvasController.height,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(25, 25, 25, 1),
                    border: Border.all(
                      color: Colors.white,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      focusStack.value
                          .elementAt(focusStackIndexes.value.elementAt(0)),
                      focusStack.value
                          .elementAt(focusStackIndexes.value.elementAt(1)),
                      focusStack.value
                          .elementAt(focusStackIndexes.value.elementAt(2)),
                      focusStack.value
                          .elementAt(focusStackIndexes.value.elementAt(3)),
                      Consumer(
                        builder: (context, ref, child) {
                          final cItems = ref.watch(CollectionStore.provider);
                          final collItemsCtl =
                              ref.watch(CollectionStore.provider.notifier);

                          return Stack(
                            children: cItems
                                .map(
                                  (cItem) => Positioned(
                                    top: cItem.position.dy,
                                    left: cItem.position.dx,
                                    child: GestureDetector(
                                      onPanUpdate: (details) {
                                        collItemsCtl.updatePosition(
                                          collection: cItem,
                                          delta: details.delta,
                                        );
                                      },
                                      child: CollectionCard(
                                        collection: cItem.collection,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            const Positioned(
              right: 16,
              bottom: 32,
              child: EditorButtons(),
            ),
            const Positioned(
              left: 16,
              bottom: 16,
              child: UndoRedoButtons(),
            ),
            const Positioned(
              bottom: 16,
              child: SizeSlider(),
            ),
            const Positioned(
              bottom: 16,
              right: 256,
              child: TextModeButtons(),
            ),
            ...overlays.map((e) => e.widget),
          ],
        ),
      ),
    );
  }
}
