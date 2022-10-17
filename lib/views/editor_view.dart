import 'dart:developer';

import 'package:database_diagrams/controllers/collection_store.dart';
import 'package:database_diagrams/widgets/draggable_collection_card.dart';
import 'package:database_diagrams/widgets/editor_buttons.dart';
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

    final offsets = useState<List<Offset>>([]);

    ref.listen(
      CollectionStore.provider,
      (previous, next) {
        if (previous != null && previous.length < next.length) {
          offsets.value = [...offsets.value, Offset.zero];
        }
        offsets.value = [...offsets.value, Offset.zero];
      },
    );

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      body: GestureDetector(
        child: Stack(
          children: [
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
          ],
        ),
      ),
    );
  }
}
