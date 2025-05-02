import 'package:client/diagrams/components/attribute_toggle.dart';
import 'package:client/diagrams/controllers/diagram_cubit.dart';
import 'package:client/diagrams/controllers/entity_editor_cubit.dart';
import 'package:client/diagrams/models/entity_editor_state.dart';
import 'package:common/er/attribute.dart';
import 'package:common/er/entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AttributeRow extends StatefulWidget {
  const AttributeRow({
    required this.availableEntities,
    required this.attribute,
    super.key,
  });

  final Attribute attribute;

  final List<Entity> availableEntities;

  @override
  State<AttributeRow> createState() => _AttributeRowState();
}

class _AttributeRowState extends State<AttributeRow> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController referenceNameController = TextEditingController();
  int? selectedEntityId;

  Set<String>? get allowedDataTypes =>
      context.read<DiagramCubit>().allowedDataTypes;

  @override
  void initState() {
    super.initState();

    nameController.text = widget.attribute.name;
    typeController.text = widget.attribute.dataType;
    selectedEntityId = widget.attribute.referencedEntityId;
    if (widget.attribute.isForeignKey) {
      referenceNameController.text = widget.attribute.name;
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
      builder:
          (context, state) => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ReorderableDragStartListener(
                index: widget.attribute.order,
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
                    selected: widget.attribute.isPrimaryKey,
                    onSelected:
                        (value) => entityEditorCubit.updateAttribute(
                          order: widget.attribute.order,
                          isPrimaryKey: value,
                        ),
                    tooltip: 'Primary Key',
                    child: const Text('🔑'),
                  ),
                  const SizedBox(width: 2),
                  AttributeToggle(
                    selected: widget.attribute.isForeignKey,
                    onSelected: (value) {
                      if (!value) {
                        // Clear FK-related fields when unchecking
                        nameController.clear();
                        typeController.clear();
                        selectedEntityId = null;
                      }
                      entityEditorCubit.updateAttribute(
                        order: widget.attribute.order,
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
                    selected: widget.attribute.isNullable,
                    onSelected:
                        (value) => entityEditorCubit.updateAttribute(
                          order: widget.attribute.order,
                          isNullable: value,
                        ),
                    tooltip: 'Nullable',
                    child: const Icon(Icons.question_mark),
                  ),
                ],
              ),
              const SizedBox(width: 8),

              if (widget.attribute.isForeignKey && selectedEntityId != null)
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
                        order: widget.attribute.order,
                        name: value,
                      );
                    },
                  ),
                ),
              if (widget.attribute.isForeignKey && selectedEntityId != null)
                const SizedBox(width: 8),
              // Entity selector (shown when FK is checked)
              if (widget.attribute.isForeignKey)
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
                            .where(
                              (e) => e.attributes.any((a) => a.isPrimaryKey),
                            )
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
                          order: widget.attribute.order,
                          name: referenceNameController.text,
                          dataType: typeController.text,
                          referencedEntityId: value,
                        );
                      }
                    },
                  ),
                ),

              if (!widget.attribute.isForeignKey)
                Expanded(
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      errorText:
                          state.attributesErrors
                              .where((e) => e.order == widget.attribute.order)
                              .firstOrNull
                              ?.nameError,
                      hintText: 'Name',
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged:
                        (value) => entityEditorCubit.updateAttribute(
                          order: widget.attribute.order,
                          name: value,
                        ),
                  ),
                ),
              const SizedBox(width: 8),

              if (!widget.attribute.isForeignKey)
                Expanded(
                  child: Autocomplete<String>(
                    optionsBuilder: (textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }

                      final Set<String>? types = allowedDataTypes;
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
                        order: widget.attribute.order,
                        dataType: selection,
                      );
                    },
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
                                    .where(
                                      (e) => e.order == widget.attribute.order,
                                    )
                                    .firstOrNull
                                    ?.typeError,

                            isDense: true,
                            border: const OutlineInputBorder(),
                          ),
                          onChanged:
                              (value) => entityEditorCubit.updateAttribute(
                                order: widget.attribute.order,
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
                                  final String option = options.elementAt(
                                    index,
                                  );

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
                  entityEditorCubit.removeAttribute(widget.attribute.order);
                },
                tooltip: 'Remove attribute',
                color: Theme.of(context).colorScheme.error,
              ),
            ],
          ),
    );
  }
}
