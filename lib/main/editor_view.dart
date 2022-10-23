import 'dart:developer';

import 'package:database_diagrams/collections/collection_store.dart';
import 'package:database_diagrams/collections/draggable_collection_card.dart';
import 'package:database_diagrams/collections/smartline_painter_container.dart';
import 'package:database_diagrams/drawing/drawing_painter_container.dart';
import 'package:database_diagrams/main/editor_buttons.dart';
import 'package:database_diagrams/main/mode.dart';
import 'package:database_diagrams/main/mode_controller.dart';
import 'package:database_diagrams/main/size_slider.dart';
import 'package:database_diagrams/main/undo_redo_buttonds.dart';
import 'package:database_diagrams/polyline/polyline_painter_container.dart';
import 'package:database_diagrams/text/my_text_painter_container.dart';
import 'package:database_diagrams/text/text_mode_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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

    ref
      ..listen(
        CollectionStore.provider,
        (previous, next) {
          if (previous != null && previous.length < next.length) {
            offsets.value = [...offsets.value, Offset.zero];
          }
          offsets.value = [...offsets.value, Offset.zero];
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
      );

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      body: MouseRegion(
        cursor: mode == Mode.drawing
            ? SystemMouseCursors.precise
            : mode == Mode.polyline
                ? SystemMouseCursors.cell
                : SystemMouseCursors.basic,
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
                child: DraggableCollectionCard(
                  collection: collection,
                  onDragUpdate: (details) {
                    offsets.value = [
                      ...offsets.value.sublist(0, collections.indexOf(collection)),
                      Offset(
                        offsets.value[collections.indexOf(collection)].dx + details.delta.dx,
                        offsets.value[collections.indexOf(collection)].dy + details.delta.dy,
                      ),
                      ...offsets.value.sublist(collections.indexOf(collection) + 1),
                    ];
                  },
                ),
              ),
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
