import 'package:database_diagrams/collections/models/collection.dart';
import 'package:flutter/animation.dart';

/// Collection item.
class CollectionItem {
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
}
