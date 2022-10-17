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
      width: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[900],
        border: Border.all(
          color: Colors.grey[850]!,
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.orange.shade700,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                  ),
                  child: Text(
                    collection.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: collection.schema.nameToType
                  .map(
                    (k, v) => MapEntry<dynamic, Widget>(
                      k,
                      Row(
                        children: [
                          Text(
                            k,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '$v',
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .values
                  .separatedBy(
                    const Divider(
                      color: Colors.white,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
