import 'package:client/diagrams/components/attribute_toggle.dart';
import 'package:client/diagrams/controllers/diagram_cubit.dart';
import 'package:client/diagrams/controllers/entity_editor_cubit.dart';
import 'package:client/diagrams/models/entity_editor_state.dart';
import 'package:common/er/attribute.dart';
import 'package:common/er/entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TabletAttributeRow extends StatefulWidget {
  const TabletAttributeRow({
    required this.attributeId,
    required this.availableEntities,
    super.key,
  });

  final List<Entity> availableEntities;
  final int attributeId;

  @override
  State<TabletAttributeRow> createState() => _TabletAttributeRowState();
}

class _TabletAttributeRowState extends State<TabletAttributeRow> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController referenceNameController = TextEditingController();
  int? selectedEntityId;

  @override
  void initState() {
    super.initState();

    final Attribute attribute = context
        .read<EntityEditorCubit>()
        .state
        .attributes
        .firstWhere((a) => a.id == widget.attributeId);

    nameController.text = attribute.name;
    typeController.text = attribute.dataType;
    selectedEntityId = attribute.referencedEntityId;
    if (attribute.isForeignKey) {
      referenceNameController.text = attribute.name;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    typeController.dispose();
    referenceNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final EntityEditorCubit entityEditorCubit =
        context.read<EntityEditorCubit>();

    return BlocBuilder<EntityEditorCubit, EntityEditorState>(
      builder: (context, state) {
        final Attribute attribute = state.attributes.firstWhere(
          (a) => a.id == widget.attributeId,
        );

        final Set<String>? types =
            attribute.isIdentity
                ? {'SMALLINT', 'INTEGER', 'BIGINT'}
                : context.read<DiagramCubit>().allowedDataTypes;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReorderableDragStartListener(
              index: attribute.order,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.drag_handle,
                  color: Theme.of(context).colorScheme.outline,
                  size: 30,
                ),
              ),
            ),
            Row(
              children: [
                AttributeToggle(
                  disabled: attribute.isForeignKey || attribute.isNullable,
                  selected: attribute.isIdentity,
                  onSelected:
                      (value) => entityEditorCubit.updateAttribute(
                        id: attribute.id,
                        isIdentity: value,
                      ),
                  tooltip: 'Identity',
                  child: const Text('🔢'),
                ),
                const SizedBox(width: 2),
                AttributeToggle(
                  disabled: attribute.isNullable,
                  selected: attribute.isPrimaryKey,
                  onSelected:
                      (value) => entityEditorCubit.updateAttribute(
                        id: attribute.id,
                        isPrimaryKey: value,
                      ),
                  tooltip: 'Primary Key',
                  child: const Text('🔑'),
                ),
                const SizedBox(width: 2),
                AttributeToggle(
                  disabled: attribute.isIdentity,
                  selected: attribute.isForeignKey,
                  onSelected: (value) {
                    if (!value) {
                      nameController.clear();
                      typeController.clear();
                      selectedEntityId = null;
                    }
                    entityEditorCubit.updateAttribute(
                      id: attribute.id,
                      name: '',
                      dataType: '',
                      isForeignKey: value,
                      referencedEntityId: value ? selectedEntityId : null,
                    );
                  },
                  tooltip: 'Foreign Key',
                  child: const Text('🔗'),
                ),
                const SizedBox(width: 2),
                AttributeToggle(
                  disabled: attribute.isPrimaryKey || attribute.isIdentity,
                  selected: attribute.isNullable,
                  onSelected:
                      (value) => entityEditorCubit.updateAttribute(
                        id: attribute.id,
                        isNullable: value,
                      ),
                  tooltip: 'Nullable',
                  child: const Icon(Icons.question_mark),
                ),
              ],
            ),
            const SizedBox(width: 8),

            if (attribute.isForeignKey && selectedEntityId != null)
              Expanded(
                child: TextField(
                  controller: referenceNameController,
                  enabled: selectedEntityId != null,
                  decoration: const InputDecoration(
                    hintText: 'Name',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (value) {
                    entityEditorCubit.updateAttribute(
                      id: attribute.id,
                      name: value,
                    );
                  },
                ),
              ),
            if (attribute.isForeignKey && selectedEntityId != null)
              const SizedBox(width: 8),
            // Entity selector (shown when FK is checked)
            if (attribute.isForeignKey)
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: selectedEntityId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    hintText: 'Select referenced entity',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items:
                      widget.availableEntities
                          .where((e) => e.attributes.any((a) => a.isPrimaryKey))
                          .map(
                            (e) => DropdownMenuItem(
                              value: e.id,
                              child: Text(e.name),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      selectedEntityId = value;
                      final Entity referencedEntity = widget.availableEntities
                          .firstWhere((e) => e.id == value);
                      final Attribute pk = referencedEntity.attributes
                          .firstWhere((a) => a.isPrimaryKey);

                      referenceNameController.text =
                          '${referencedEntity.name.toLowerCase()}_${pk.name}';
                      typeController.text = pk.dataType;

                      entityEditorCubit.updateAttribute(
                        id: attribute.id,
                        name: referenceNameController.text,
                        dataType: typeController.text,
                        referencedEntityId: value,
                      );
                    }
                  },
                ),
              ),

            if (!attribute.isForeignKey)
              Expanded(
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    errorText:
                        state.attributesErrors
                            .where((e) => e.order == attribute.order)
                            .firstOrNull
                            ?.nameError,
                    hintText: 'Name',
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged:
                      (value) => entityEditorCubit.updateAttribute(
                        id: attribute.id,
                        name: value,
                      ),
                ),
              ),
            const SizedBox(width: 8),

            if (!attribute.isForeignKey)
              Expanded(
                child: Autocomplete<String>(
                  key: ValueKey('${attribute.id}_${attribute.isIdentity}'),
                  optionsBuilder: (textEditingValue) {
                    if (types == null) {
                      return const Iterable<String>.empty();
                    }

                    final Set<String> options = types;

                    return options.where(
                      (String option) => option.toLowerCase().contains(
                        textEditingValue.text.toLowerCase(),
                      ),
                    );
                  },
                  onSelected: (String selection) {
                    typeController.text = selection;
                    entityEditorCubit.updateAttribute(
                      id: attribute.id,
                      dataType: selection,
                    );
                  },
                  initialValue: TextEditingValue(text: typeController.text),
                  fieldViewBuilder:
                      (
                        context,
                        textEditingController,
                        focusNode,
                        onFieldSubmitted,
                      ) => TextField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          hintText: 'Type',
                          errorText:
                              state.attributesErrors
                                  .where((e) => e.order == attribute.order)
                                  .firstOrNull
                                  ?.typeError,

                          isDense: true,
                          border: const OutlineInputBorder(),
                        ),
                        onChanged:
                            (value) => entityEditorCubit.updateAttribute(
                              id: attribute.id,
                              dataType: value,
                            ),
                      ),
                  optionsViewBuilder:
                      (
                        BuildContext context,
                        AutocompleteOnSelected<String> onSelected,
                        Iterable<String> options,
                      ) => Align(
                        alignment: Alignment.topLeft,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 350),
                          child: Material(
                            elevation: 4,
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (BuildContext context, int index) {
                                final String option = options.elementAt(index);

                                return InkWell(
                                  onTap: () {
                                    onSelected(option);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    child: Text(option),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                ),
              ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              onPressed: () {
                entityEditorCubit.removeAttribute(attribute.order);
              },
              tooltip: 'Remove attribute',
              color: Theme.of(context).colorScheme.error,
            ),
          ],
        );
      },
    );
  }
}
