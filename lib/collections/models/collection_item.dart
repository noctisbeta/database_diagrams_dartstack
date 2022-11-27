import 'dart:convert';

import 'package:database_diagrams/collections/models/collection.dart';
import 'package:database_diagrams/projects/models/saveable.dart';
import 'package:flutter/animation.dart';

/// Collection item.
class CollectionItem implements Saveable {
  /// Default constructor.
  const CollectionItem({
    required this.collection,
    required this.position,
  });

  /// Collection.
  final Collection collection;

  /// Offset.
  final Offset position;

  /// Copy with.
  CollectionItem copyWith({
    Collection? collection,
    Offset? position,
  }) {
    return CollectionItem(
      collection: collection ?? this.collection,
      position: position ?? this.position,
    );
  }

  /// To map.
  Map<String, dynamic> toMap() {
    return {
      'collection': collection.toMap(),
      'position': position,
    };
  }

  @override
  String serialize() => jsonEncode({
        'collection': collection.toMap(),
        'position_x': position.dx,
        'position_y': position.dy,
      });

  @override
  CollectionItem deserialize(String data) {
    final json = jsonDecode(data) as Map<String, dynamic>;

    return CollectionItem(
      collection: Collection.fromMap(
        json['collection'] as Map<String, dynamic>,
      ),
      position: Offset(
        json['position_x'] as double,
        json['position_y'] as double,
      ),
    );
  }
}
