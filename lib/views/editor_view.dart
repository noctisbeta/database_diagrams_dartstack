import 'dart:developer';

import 'package:database_diagrams/controllers/collection_store.dart';
import 'package:database_diagrams/models/collection.dart';
import 'package:database_diagrams/widgets/add_collection_dialog.dart';
import 'package:database_diagrams/widgets/collection_card.dart';
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

    final offsets = useState(collections.map((_) => Offset.zero).toList());

    useEffect(
      () {
        offsets.value = collections.map((_) => Offset.zero).toList();
        return;
      },
      [collections],
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
                child: Draggable<Collection>(
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
                  data: collection,
                  childWhenDragging: const SizedBox.shrink(),
                  feedback: Material(
                    type: MaterialType.transparency,
                    child: CollectionCard(
                      collection: collection,
                    ),
                  ),
                  child: CollectionCard(
                    collection: collection,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 16,
              bottom: 32,
              child: Column(
                children: [
                  FloatingActionButton(
                    backgroundColor: Colors.orange.shade700,
                    hoverColor: Colors.orange.shade800,
                    onPressed: () {
                      showDialog(
                        barrierDismissible: false,
                        barrierColor: Colors.black.withOpacity(0.3),
                        context: context,
                        builder: (context) {
                          return const AddCollectionDialog();
                        },
                      );
                    },
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
