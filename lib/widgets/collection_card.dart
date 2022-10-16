import 'package:database_diagrams/models/collection.dart';
import 'package:database_diagrams/utilities/iterable_extension.dart';
import 'package:flutter/material.dart';

/// Collection card.
class CollectionCard extends StatelessWidget {
  /// Default constructor.
  const CollectionCard({
    required this.collection,
    super.key,
  });

  /// Collection.
  final Collection collection;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black.withOpacity(0.2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            collection.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
            ),
          ),
          const Divider(
            color: Colors.white,
          ),
          ...collection.schema.nameToType
              .map(
                (k, v) => MapEntry<dynamic, Widget>(
                  k,
                  Text(
                    '$k: $v',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              )
              .values
              .separatedBy(
                const Divider(
                  color: Colors.white,
                ),
              ),
        ],
      ),
    );
  }
}
