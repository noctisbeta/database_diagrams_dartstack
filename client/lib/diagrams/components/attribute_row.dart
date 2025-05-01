import 'package:client/constants/data_types.dart';
import 'package:client/diagrams/components/attribute_toggle.dart';
import 'package:client/diagrams/controllers/diagram_cubit.dart';
import 'package:client/diagrams/models/diagram_state.dart';
import 'package:common/er/attribute.dart';
import 'package:common/er/diagrams/diagram_type.dart';
import 'package:common/er/entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AttributeRow extends StatefulWidget {
  const AttributeRow({
    required this.index,
    required this.isPrimaryKey,
    required this.isForeignKey,
    required this.isNullable,
    required this.onRemove,
    required this.onUpdate,
    required this.availableEntities,
    this.attribute,
    super.key,
  });

  final Attribute? attribute;
  final int index;
  final bool isPrimaryKey;
  final bool isForeignKey;
  final bool isNullable;
  final List<Entity> availableEntities;
  final void Function(int index) onRemove;
  final void Function(
    int index, {
    bool? isPrimaryKey,
    bool? isForeignKey,
    bool? isNullable,
    String? name,
    String? dataType,
    int? referencedEntityId,
  })
  onUpdate;

  @override
  State<AttributeRow> createState() => _AttributeRowState();
}

class _AttributeRowState extends State<AttributeRow> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController referenceNameController = TextEditingController();
  int? selectedEntityId;

  @override
  void initState() {
    super.initState();
    if (widget.attribute != null) {
      nameController.text = widget.attribute!.name;
      typeController.text = widget.attribute!.dataType;
      selectedEntityId = widget.attribute!.referencedEntityId;
      if (widget.isForeignKey) {
        referenceNameController.text = widget.attribute!.name;
      }
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
  Widget build(BuildContext context) => BlocBuilder<DiagramCubit, DiagramState>(
    builder: (context, state) {
      final DiagramType diagramType = state.diagramType;

      return Row(
        children: [
          ReorderableDragStartListener(
            index: widget.index,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Icon(
                Icons.drag_handle,
                color: Theme.of(context).colorScheme.outline,
                size: 30,
              ),
            ),
          ),
          // Flags column
          Row(
            children: [
              AttributeToggle(
                selected: widget.isPrimaryKey,
                onSelected:
                    (value) =>
                        widget.onUpdate.call(widget.index, isPrimaryKey: value),
                tooltip: 'Primary Key',
                child: const Text('🔑'),
              ),
              const SizedBox(width: 2),
              AttributeToggle(
                selected: widget.isForeignKey,
                onSelected: (value) {
                  if (!value) {
                    // Clear FK-related fields when unchecking
                    nameController.clear();
                    typeController.clear();
                    selectedEntityId = null;
                  }
                  widget.onUpdate(
                    widget.index,
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
                selected: widget.isNullable,
                onSelected:
                    (value) => widget.onUpdate(widget.index, isNullable: value),
                tooltip: 'Nullable',
                child: const Icon(Icons.question_mark),
              ),
            ],
          ),
          const SizedBox(width: 8),

          if (widget.isForeignKey && selectedEntityId != null)
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
                  widget.onUpdate(
                    widget.index,
                    name: value,
                    dataType: typeController.text,
                    referencedEntityId: selectedEntityId,
                  );
                },
              ),
            ),
          if (widget.isForeignKey && selectedEntityId != null)
            const SizedBox(width: 8),
          // Entity selector (shown when FK is checked)
          if (widget.isForeignKey)
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
                    final Attribute pk = referencedEntity.attributes.firstWhere(
                      (a) => a.isPrimaryKey,
                    );

                    referenceNameController.text =
                        '${referencedEntity.name.toLowerCase()}_${pk.name}';
                    typeController.text = pk.dataType;

                    widget.onUpdate(
                      widget.index,
                      name: referenceNameController.text,
                      dataType: typeController.text,
                      referencedEntityId: value,
                    );
                  }
                },
              ),
            ),

          if (!widget.isForeignKey)
            Expanded(
              child: TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Name',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged:
                    (value) => widget.onUpdate(widget.index, name: value),
              ),
            ),
          const SizedBox(width: 8),

          if (!widget.isForeignKey)
            Expanded(
              child: Autocomplete<String>(
                optionsBuilder: (textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<String>.empty();
                  }

                  final Set<String> options = switch (diagramType) {
                    DiagramType.postgresql => kPostgresDataTypes,
                    DiagramType.firestore => kFirestoreDataTypes,
                    DiagramType.custom => {},
                  };

                  return options.where(
                    (String option) => option.toLowerCase().contains(
                      textEditingValue.text.toLowerCase(),
                    ),
                  );
                },
                onSelected: (String selection) {
                  typeController.text = selection;
                  widget.onUpdate(widget.index, dataType: selection);
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
                      decoration: const InputDecoration(
                        hintText: 'Type',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged:
                          (value) =>
                              widget.onUpdate(widget.index, dataType: value),
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
              widget.onRemove.call(widget.index);
            },
            tooltip: 'Remove attribute',
            color: Theme.of(context).colorScheme.error,
          ),
        ],
      );
    },
  );
}
