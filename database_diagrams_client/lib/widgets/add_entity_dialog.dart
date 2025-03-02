import 'package:database_diagrams_client/state/diagram_cubit.dart';
import 'package:database_diagrams_common/er/attribute.dart';
import 'package:database_diagrams_common/er/attribute_type.dart';
import 'package:database_diagrams_common/er/entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddEntityDialog extends StatefulWidget {
  const AddEntityDialog({super.key});

  @override
  State<AddEntityDialog> createState() => _AddEntityDialogState();
}

class _AddEntityDialogState extends State<AddEntityDialog> {
  final TextEditingController _nameController = TextEditingController();
  final List<TextEditingController> _attributeNameControllers = [];
  final List<TextEditingController> _attributeTypeControllers = [];
  final List<Attribute> _attributes = [];

  // Add this getter to get all available entities except the current one
  List<Entity> get availableEntities =>
      context.read<DiagramCubit>().state.entities;

  @override
  void initState() {
    super.initState();
    // Start with one attribute
    _addAttribute();
  }

  void _addAttribute() {
    final nameController = TextEditingController();
    final typeController = TextEditingController();

    setState(() {
      _attributeNameControllers.add(nameController);
      _attributeTypeControllers.add(typeController);
      _attributes.add(
        Attribute(
          id: (_attributes.length + 1).toString(),
          name: '',
          dataType: '',
        ),
      );
    });
  }

  void _removeAttribute(int index) {
    // Don't allow removing if this is the last attribute
    if (_attributes.length <= 1) {
      return;
    }

    setState(() {
      _attributes.removeAt(index);
      _attributeNameControllers[index].dispose();
      _attributeTypeControllers[index].dispose();
      _attributeNameControllers.removeAt(index);
      _attributeTypeControllers.removeAt(index);
    });
  }

  void _updateAttribute(
    int index, {
    String? name,
    String? dataType,
    AttributeType? type,
    bool? isPrimaryKey,
    bool? isForeignKey,
    bool? isNullable,
    String? referencedEntityId,
  }) {
    setState(() {
      _attributes[index] = _attributes[index].copyWith(
        name: name ?? _attributeNameControllers[index].text,
        dataType: dataType ?? _attributeTypeControllers[index].text,
        type: type,
        isPrimaryKey: isPrimaryKey,
        isForeignKey: isForeignKey,
        isNullable: isNullable,
        referencedEntityIdFactory:
            referencedEntityId == null ? null : () => referencedEntityId,
      );
    });
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Add New Entity'),
    content: ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 500,
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: IntrinsicHeight(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Entity name input
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Entity Name',
                hintText: 'Enter entity name',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 24),

            // Attributes section header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Attributes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton.filled(
                  onPressed: _addAttribute,
                  icon: const Icon(Icons.add),
                  tooltip: 'Add Attribute',
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Attributes list - always show
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (
                      var index = 0;
                      index < _attributes.length;
                      index++
                    ) ...[
                      if (index > 0) const SizedBox(height: 8),
                      _buildAttributeCard(index),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          if (_nameController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Entity name is required')),
            );
            return;
          }

          // Check if at least one attribute has a name
          if (_attributes.every((attr) => attr.name.isEmpty)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('At least one attribute with a name is required'),
              ),
            );
            return;
          }

          final entity = Entity(
            id: '',
            name: _nameController.text,
            attributes:
                _attributes.where((attr) => attr.name.isNotEmpty).toList(),
          );

          context.read<DiagramCubit>().addEntity(entity);
          Navigator.pop(context);
        },
        child: const Text('Add Entity'),
      ),
    ],
  );

  Widget _buildAttributeCard(int index) => Card(
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _attributeNameControllers[index],
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'Enter attribute name',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (value) => _updateAttribute(index, name: value),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _attributeTypeControllers[index],
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    hintText: 'e.g., String, Int',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged:
                      (value) => _updateAttribute(index, dataType: value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ChoiceChip(
                label: const Text('PK'),
                selected: _attributes[index].isPrimaryKey,
                onSelected:
                    (value) => _updateAttribute(index, isPrimaryKey: value),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('FK'),
                selected: _attributes[index].isForeignKey,
                onSelected: (value) {
                  _updateAttribute(
                    index,
                    isForeignKey: value,
                    // Reset referenced entity when FK is deselected
                    referencedEntityId: value ? null : null,
                  );
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Nullable'),
                selected: _attributes[index].isNullable,
                onSelected:
                    (value) => _updateAttribute(index, isNullable: value),
              ),
            ],
          ),

          // Show FK selector only when FK is selected
          if (_attributes[index].isForeignKey) ...[
            const SizedBox(height: 8),
            _buildForeignKeySelector(index),
          ],

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (_attributes.length > 1)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red[400],
                  onPressed: () => _removeAttribute(index),
                  tooltip: 'Remove Attribute',
                ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _buildForeignKeySelector(int index) {
    List<DropdownMenuItem<String>> buildDropdownItems() {
      final items = <DropdownMenuItem<String>>[];

      for (final Entity entity in availableEntities) {
        final Attribute primaryKeyAttribute = entity.attributes.firstWhere(
          (attr) => attr.isPrimaryKey,
        );

        final label = '${entity.name}.${primaryKeyAttribute.name}';

        items.add(DropdownMenuItem(value: entity.id, child: Text(label)));
      }

      return items;
    }

    return DropdownButtonFormField<String>(
      value: _attributes[index].referencedEntityId,
      decoration: const InputDecoration(
        labelText: 'References',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      items: buildDropdownItems(),
      onChanged: (entityId) {
        if (entityId != null) {
          _updateAttribute(index, referencedEntityId: entityId);
        }
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final TextEditingController controller in _attributeNameControllers) {
      controller.dispose();
    }
    for (final TextEditingController controller in _attributeTypeControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
