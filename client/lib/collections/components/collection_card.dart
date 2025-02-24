import 'dart:developer';

import 'package:database_diagrams/collections/models/collection.dart';
import 'package:database_diagrams/main/mode.dart';
import 'package:database_diagrams/main/mode_controller.dart';
import 'package:database_diagrams/smartline/smartline_anchor.dart';
import 'package:database_diagrams/smartline/smartline_controller.dart';
import 'package:database_diagrams/smartline/smartline_type.dart';
import 'package:database_diagrams/utilities/iterable_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Collection card.
class CollectionCard extends HookConsumerWidget {
  /// Default constructor.
  const CollectionCard({
    required this.collection,
    this.isPreview = false,
    super.key,
  });

  /// Collection.
  final Collection collection;

  /// isPreview.
  final bool isPreview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(ModeController.provider);

    final borderColor = useState(
      mode == Mode.smartLine ? Colors.white : Colors.grey[850]!,
    );

    final cardKey = useState(GlobalObjectKey(collection.name));

    useEffect(
      () {
        final color = mode == Mode.smartLine ? Colors.white : Colors.grey[850]!;
        borderColor.value = color;
        return;
      },
      [mode],
    );

    final smartlineController = ref.watch(SmartlineController.provider);

    log('card: ${collection.schema}');

    return GestureDetector(
      key: isPreview ? null : cardKey.value,
      onTap: () {
        if (mode == Mode.smartLine) {
          smartlineController.addCard(
            SmartlineAnchor(
              key: cardKey.value,
              type: SmartlineType.card,
            ),
          );
        }
      },
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[900],
          border: Border.all(
            color: borderColor.value,
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
                children: collection.schema
                    .map(
                      (k, v) {
                        final key = GlobalObjectKey(k + v + collection.name);

                        return MapEntry<dynamic, Widget>(
                          k,
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            key: isPreview ? null : key,
                            onTap: () {
                              if (mode == Mode.smartLine) {
                                smartlineController.addCard(
                                  SmartlineAnchor(
                                    key: key,
                                    type: SmartlineType.field,
                                  ),
                                );
                              }
                            },
                            child: Row(
                              children: [
                                Text(
                                  k,
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  v,
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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
      ),
    );
  }
}
