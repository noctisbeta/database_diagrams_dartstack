import 'package:database_diagrams/collections/collection.dart';
import 'package:database_diagrams/collections/collection_card.dart';
import 'package:flutter/material.dart';

/// DraggableCollectionCard.
class DraggableCollectionCard extends StatelessWidget {
  /// Default constructor.
  const DraggableCollectionCard({
    required this.collection,
    required this.onDragUpdate,
    required this.scale,
    super.key,
  });

  /// On drag update.
  final void Function(DragUpdateDetails) onDragUpdate;

  /// Collection.
  final Collection collection;

  /// Scale.
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Draggable<Collection>(
      onDragUpdate: onDragUpdate,
      data: collection,
      childWhenDragging: const SizedBox.shrink(),
      feedback: Material(
        type: MaterialType.transparency,
        child: Transform.scale(
          scale: scale,
          child: CollectionCard(
            collection: collection,
          ),
        ),
      ),
      child: CollectionCard(
        collection: collection,
      ),
    );
  }
}
