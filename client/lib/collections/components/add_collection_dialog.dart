import 'package:database_diagrams/collections/components/collection_card.dart';
import 'package:database_diagrams/collections/controllers/collection_store.dart';
import 'package:database_diagrams/collections/models/collection.dart';
import 'package:database_diagrams/common/my_dialog.dart';
import 'package:database_diagrams/main/my_button.dart';
import 'package:database_diagrams/main/my_dropdown_button.dart';
import 'package:database_diagrams/main/my_text_field.dart';
import 'package:database_diagrams/overlay_manager/overlay_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:functional/functional.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Add collection dialog.
class AddCollectionDialog extends HookConsumerWidget {
  /// Default constructor.
  const AddCollectionDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collName = useState<String?>(null);
    final fieldName = useState<String?>(null);
    final fieldType = useState<String?>(null);
    final collection = useState<Collection?>(null);
    final fieldCtl = useTextEditingController();

    // TODO(Janez): Stepper

    useEffect(
      () {
        collection.value = collection.value?.copyWith(
          name: collName.value,
        );

        return;
      },
      [collName.value],
    );

    bool verifyField() =>
        (collName.value?.isNotEmpty ?? false) &&
        (fieldName.value?.isNotEmpty ?? false) &&
        (fieldType.value?.isNotEmpty ?? false);

    void updateCollection() => verifyField().match(
          ifFalse: () {},
          ifTrue: () => collection.value = collection.value?.copyWith(
                schema: {
                  ...collection.value?.schema ?? {},
                  fieldName.value!: fieldType.value!,
                },
              ) ??
              Collection(
                name: collName.value!,
                schema: {
                  fieldName.value!: fieldType.value!,
                },
              ),
        );

    return OverlayDialog(
      heading: 'Add Collection',
      label: OverlayLabel.addCollection,
      height: 0.5,
      width: 0.5,
      actions: [
        MyButton(
          label: 'Cancel',
          onPressed: () => Navigator.of(context).pop(),
        ),
        MyButton(
          label: 'Add',
          isDisabled: collection.value == null,
          onPressed: () {
            ref.read(CollectionStore.provider.notifier).add(
                  collection.value!,
                );
            Navigator.of(context).pop();
          },
        ),
      ],
      child: Row(
        children: [
          Expanded(
            child: FocusScope(
              child: Column(
                children: [
                  MyTextField(
                    label: 'Collection name',
                    enabled: collection.value == null,
                    textInputAction: TextInputAction.next,
                    onChanged: (value) => collName.value = value,
                  ),
                  Divider(
                    color: Colors.black.withOpacity(0.3),
                  ),
                  MyTextField(
                    controller: fieldCtl,
                    label: 'Field name',
                    textInputAction: TextInputAction.next,
                    enabled:
                        collName.value != null && collName.value!.isNotEmpty,
                    onChanged: (value) => fieldName.value = value,
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  MyDropdownButton(
                    value: fieldType.value,
                    enabled:
                        collName.value != null && collName.value!.isNotEmpty,
                    onChanged: (value) => fieldType.value = value,
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: MyButton(
                      label: 'Add field',
                      isDisabled: !verifyField(),
                      onPressed: updateCollection,
                    ),
                  ),
                ],
              ),
            ),
          ),
          VerticalDivider(
            color: Colors.black.withOpacity(0.3),
          ),
          Expanded(
            child: collection.value != null
                ? CollectionCard(
                    collection: collection.value!,
                    isPreview: true,
                  )
                : const Center(
                    child: Text(
                      'No collection added',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
