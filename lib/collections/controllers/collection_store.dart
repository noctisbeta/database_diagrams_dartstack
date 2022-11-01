import 'package:database_diagrams/collections/controllers/compiler.dart';
import 'package:database_diagrams/collections/models/collection.dart';
import 'package:database_diagrams/collections/models/collection_item.dart';
import 'package:database_diagrams/main/canvas_controller.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Collection store.
class CollectionStore extends StateNotifier<List<CollectionItem>> {
  /// Default constructor.
  CollectionStore(
    this.ref,
  ) : super(const []);

  /// Riverpod reference.
  final Ref ref;

  /// Provider.
  static final provider = StateNotifierProvider<CollectionStore, List<CollectionItem>>(
    (ref) {
      return CollectionStore(ref);
    },
  );

  /// Add collection.
  void add(Collection collection) {
    final topLeft = ref.read(CanvasController.provider).topLeft;

    final item = CollectionItem(
      collection: collection,
      position: topLeft.translate(50, 50),
    );

    state = [...state, item];

    ref.read(Compiler.provider.notifier).addCollection(collection);
  }

  /// Update collection.
  void updateCollection(Collection collection) {
    if (state.map((e) => e.collection).any((element) => element.name == collection.name)) {
      state = state.map(
        (e) {
          if (e.collection == collection) {
            return e.copyWith(collection: collection);
          }
          return e;
        },
      ).toList();
    }
  }

  /// Update position.
  void updatePosition({required CollectionItem collection, required Offset delta}) {
    state = [
      for (final item in state)
        // TODO(Janez): item == collection too slow, item.collection == collection faster??
        // TODO(Janez): Multiple onPanUpdate calls for a single build.
        if (item.collection == collection.collection)
          item.copyWith(
            position: item.position + delta,
          )
        else
          item
    ];
  }
}
