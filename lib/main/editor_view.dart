import 'dart:developer';

import 'package:database_diagrams/collections/collection_card.dart';
import 'package:database_diagrams/collections/collection_store.dart';
import 'package:database_diagrams/collections/smartline_painter_container.dart';
import 'package:database_diagrams/drawing/drawing_painter_container.dart';
import 'package:database_diagrams/main/canvas_controller.dart';
import 'package:database_diagrams/main/editor_buttons.dart';
import 'package:database_diagrams/main/mode.dart';
import 'package:database_diagrams/main/mode_controller.dart';
import 'package:database_diagrams/main/size_slider.dart';
import 'package:database_diagrams/main/undo_redo_buttonds.dart';
import 'package:database_diagrams/main/zoom_buttons.dart';
import 'package:database_diagrams/main/zoom_controller.dart';
import 'package:database_diagrams/polyline/polyline_painter_container.dart';
import 'package:database_diagrams/text/my_text_painter_container.dart';
import 'package:database_diagrams/text/text_mode_buttons.dart';
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
    final collections = ref.watch(CollectionStore.provider);
    final mode = ref.watch(ModeController.provider);

    // TODO(Janez): Lift to controller.
    final offsets = useState<List<Offset>>([]);

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

    final width = useState<double>(4000);
    final height = useState<double>(4000);

    final transformController = useTransformationController();
    final screenSize = MediaQuery.of(context).size;

    ref
      ..listen(
        CollectionStore.provider,
        (previous, next) {
          if (previous != null && previous.length < next.length) {
            offsets.value = [
              ...offsets.value,
              Offset(
                ref.read(CanvasController.provider).viewport.point0.x.clamp(0, width.value),
                ref.read(CanvasController.provider).viewport.point0.y.clamp(0, height.value),
              ),
            ];
          }
        },
      )
      ..listen(
        ModeController.provider,
        (previous, next) {
          log('previous: $previous, next: $next');
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
          log('focusStackIndexes.value: ${focusStackIndexes.value}');
        },
      )
      ..listen(
        ZoomController.provider,
        (previous, next) {
          log('inside zoom listener');

          // transformController.value = transformController.value..scale(next, next);

          // transformController.value = Matrix4.identity()..scale(next);
          // transformController.value.scaled(
          //   next,
          //   next,
          // );

          // transformController.value = transformController.value..scale(1.5, 1.5, 1.5);
          // transformController.value.scale(1.5);
          // TODO(Janez): fix zooming.
        },
      );

    useEffect(
      () {
        transformController.value.setTranslation(
          Vector3(
            -width.value / 2 + screenSize.width / 2,
            -height.value / 2 + screenSize.height / 2,
            0,
          ),
        );

        return transformController.dispose;
      },
      [transformController],
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
            GestureDetector(
              onScaleUpdate: (details) => transformController.value.scale(
                details.scale,
                // details.localFocalPoint.dx,
                // details.localFocalPoint.dy,
              ),
              child: InteractiveViewer.builder(
                transformationController: transformController,
                boundaryMargin: const EdgeInsets.all(10000),
                minScale: 0.01,
                maxScale: 10,
                builder: (context, viewport) {
                  ref.read(CanvasController.provider).viewport = viewport;
                  log(viewport.point0.toString());

                  return Container(
                    key: CanvasController.canvasContainerKey,
                    width: width.value,
                    height: height.value,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(25, 25, 25, 1),
                      border: Border.all(
                        color: Colors.white,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        focusStack.value.elementAt(focusStackIndexes.value.elementAt(0)),
                        focusStack.value.elementAt(focusStackIndexes.value.elementAt(1)),
                        focusStack.value.elementAt(focusStackIndexes.value.elementAt(2)),
                        focusStack.value.elementAt(focusStackIndexes.value.elementAt(3)),
                        ...collections.map(
                          (collection) => Positioned(
                            top: 50 + offsets.value[collections.indexOf(collection)].dy,
                            left: 50 + offsets.value[collections.indexOf(collection)].dx,
                            child: GestureDetector(
                              onPanUpdate: (details) {
                                offsets.value = [
                                  ...offsets.value.sublist(0, collections.indexOf(collection)),
                                  Offset(
                                    offsets.value[collections.indexOf(collection)].dx + details.delta.dx,
                                    offsets.value[collections.indexOf(collection)].dy + details.delta.dy,
                                  ),
                                  ...offsets.value.sublist(collections.indexOf(collection) + 1),
                                ];
                              },
                              child: CollectionCard(
                                collection: collection,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const Positioned(
              top: 16,
              left: 16,
              child: ZoomButtons(),
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
          ],
        ),
      ),
    );
  }
}
