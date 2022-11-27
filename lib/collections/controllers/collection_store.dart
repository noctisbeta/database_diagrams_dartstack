import 'dart:convert';

import 'package:database_diagrams/collections/controllers/compiler.dart';
import 'package:database_diagrams/collections/models/collection.dart';
import 'package:database_diagrams/collections/models/collection_item.dart';
import 'package:database_diagrams/logging/log_profile.dart';
import 'package:database_diagrams/main/canvas_controller.dart';
import 'package:database_diagrams/projects/models/saveable.dart';
import 'package:flutter/material.dart';
import 'package:functional/functional.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Collection store.
class CollectionStore extends StateNotifier<List<CollectionItem>>
    implements Saveable {
  /// Default constructor.
  CollectionStore(
    this._canvasController,
    this._compiler,
  ) : super(const []);

  /// Canvas controller.
  final CanvasController _canvasController;

  /// Compiler.
  final Compiler _compiler;

  /// Provider.
  static final provider =
      StateNotifierProvider<CollectionStore, List<CollectionItem>>(
    (ref) => CollectionStore(
      ref.watch(CanvasController.provider),
      ref.watch(Compiler.provider.notifier),
    ),
  );

  /// Add collection.
  void add(Collection collection) {
    final topLeft = _canvasController.topLeft;

    final item = CollectionItem(
      collection: collection,
      position: topLeft.translate(50, 50),
    );

    state = [...state, item];

    _compiler.addCollection(collection);
  }

  /// Update collection.
  void updateCollection(Collection collection) {
    if (state
        .map((e) => e.collection)
        .any((element) => element.name == collection.name)) {
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
  void updatePosition({
    required CollectionItem collection,
    required Offset delta,
  }) {
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

  @override
  List<Map<String, dynamic>> serialize() => [
        ...state.map(
          (e) => {
            'name': e.collection.name,
            'schema_keys': e.collection.schema.keys.toList(),
            'schema_values': e.collection.schema.values.toList(),
            'x_pos': e.position.dx,
            'y_pos': e.position.dy,
          },
        )
      ];

  @override
  Unit deserialize(String data) => tap(
        unit,
        () {
          myLog.d(data);

          final json = jsonDecode(data) as Map<String, dynamic>;

          state = [
            for (final item in json['collections'] as List)
              CollectionItem(
                collection: Collection.fromDynamic(
                  (jsonDecode(item))['collection'],
                ),
                position: Offset(
                  (jsonDecode(item))['position_x'] as double,
                  (jsonDecode(item))['position_y'] as double,
                ),
              ),
          ];
        },
      );
}
