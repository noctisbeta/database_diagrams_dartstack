import 'package:client/widgets/attribute_toggle.dart';
import 'package:common/er/attribute.dart';
import 'package:common/er/entity.dart';
import 'package:flutter/material.dart';

class AttributeRow extends StatefulWidget {
  const AttributeRow({
    required this.index,
    required this.isPrimaryKey,
    required this.isForeignKey,
    required this.isNullable,
    required this.onRemove,
    required this.onUpdate,
    required this.availableEntities, // Add this
    super.key,
  });

  final int index;
  final bool isPrimaryKey;
  final bool isForeignKey;
  final bool isNullable;
  final List<Entity> availableEntities; // Add this
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
  int? selectedEntityId;

  @override
  void dispose() {
    nameController.dispose();
    typeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Row(
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

      // Entity selector (shown when FK is checked)
      if (widget.isForeignKey) ...[
        Expanded(
          child: DropdownButtonFormField<int>(
            value: selectedEntityId,
            decoration: const InputDecoration(
              hintText: 'Select referenced entity',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items:
                widget.availableEntities
                    .where((e) => e.attributes.any((a) => a.isPrimaryKey))
                    .map(
                      (e) => DropdownMenuItem(value: e.id, child: Text(e.name)),
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

                // Update name and type based on referenced PK
                nameController.text =
                    '${referencedEntity.name.toLowerCase()}_${pk.name}';
                typeController.text = pk.dataType;

                widget.onUpdate(
                  widget.index,
                  name: nameController.text,
                  dataType: typeController.text,
                  referencedEntityId: value,
                );
              }
            },
          ),
        ),
        const SizedBox(width: 8),
      ],

      // Name column
      if (!widget.isForeignKey) ...[
        Expanded(
          child: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              hintText: 'Name',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (value) => widget.onUpdate(widget.index, name: value),
          ),
        ),
        const SizedBox(width: 8),

        // Type column
        Expanded(
          child: TextField(
            controller: typeController,
            decoration: const InputDecoration(
              hintText: 'Type',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged:
                (value) => widget.onUpdate(widget.index, dataType: value),
          ),
        ),
      ],
      const SizedBox(width: 8),
      // Delete button
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
}
