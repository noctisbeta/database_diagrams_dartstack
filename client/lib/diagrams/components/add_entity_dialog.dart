import 'package:client/diagrams/components/attribute_row.dart';
import 'package:client/diagrams/components/entity_card.dart';
import 'package:client/diagrams/controllers/diagram_cubit.dart';
import 'package:common/er/attribute.dart';
import 'package:common/er/entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddEntityDialog extends StatefulWidget {
  const AddEntityDialog({this.entity, super.key});

  final Entity? entity;

  @override
  State<AddEntityDialog> createState() => _AddEntityDialogState();
}

class _AddEntityDialogState extends State<AddEntityDialog> {
  final TextEditingController _nameController = TextEditingController();
  final List<Attribute> _attributes = [];

  int? _primaryKeyIndex;

  List<Entity> get availableEntities =>
      context
          .read<DiagramCubit>()
          .state
          .entities
          .where((e) => e.id != widget.entity?.id)
          .toList();

  @override
  void initState() {
    super.initState();

    if (widget.entity != null) {
      _nameController.text = widget.entity!.name;
      _attributes.addAll(widget.entity!.attributes);
      // Set primary key index if exists
      _primaryKeyIndex = _attributes.indexWhere((attr) => attr.isPrimaryKey);
    } else {
      _addAttribute();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addAttribute() {
    setState(() {
      _attributes.add(
        Attribute(
          id: _attributes.length + 1,
          name: '',
          dataType: '',
          order: _attributes.length, // Add order
        ),
      );
    });
  }

  void _removeAttribute(int index) {
    // Do not allow removing the last attribute
    if (_attributes.length <= 1) {
      return;
    }

    setState(() {
      _attributes.removeAt(index);
    });
  }

  void _updateAttribute(
    int index, {
    String? name,
    String? dataType,
    bool? isPrimaryKey,
    bool? isForeignKey,
    bool? isNullable,
    int? referencedEntityId,
  }) {
    setState(() {
      // Handle primary key changes
      if (isPrimaryKey != null) {
        if (isPrimaryKey) {
          // Uncheck previous primary key if exists
          if (_primaryKeyIndex != null && _primaryKeyIndex != index) {
            _attributes[_primaryKeyIndex!] = _attributes[_primaryKeyIndex!]
                .copyWith(isPrimaryKey: false);
          }
          _primaryKeyIndex = index;
        } else {
          if (_primaryKeyIndex == index) {
            _primaryKeyIndex = null;
          }
        }
      }

      _attributes[index] = _attributes[index].copyWith(
        name: name ?? _attributes[index].name,
        dataType: dataType ?? _attributes[index].dataType,
        isPrimaryKey: isPrimaryKey ?? _attributes[index].isPrimaryKey,
        isForeignKey: isForeignKey ?? _attributes[index].isForeignKey,
        isNullable: isNullable ?? _attributes[index].isNullable,
        referencedEntityIdFactory:
            referencedEntityId == null ? null : () => referencedEntityId,
      );
    });
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Add New Entity'),
    content: SizedBox(
      height: 500,
      width: 800,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side - Form
          SizedBox(
            height: 500,
            width: 490,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Entity name field
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Entity Name',
                    hintText: 'Enter entity name',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 24),
                // Attributes table
                Expanded(
                  child: Column(
                    children: [
                      // Table header
                      const Row(
                        children: [
                          SizedBox(width: 46),
                          Text('Flags'),
                          SizedBox(width: 97),
                          Text('Name'),
                          SizedBox(width: 98),
                          Text('Type'),
                        ],
                      ),
                      const Divider(),
                      // Attributes list
                      Expanded(
                        child: ReorderableListView.builder(
                          shrinkWrap: true,
                          buildDefaultDragHandles: false,
                          itemCount: _attributes.length,
                          onReorder: (oldIndex, newIndex) {
                            setState(() {
                              // Adjust the newIndex as needed
                              if (oldIndex < newIndex) {
                                newIndex -= 1;
                              }

                              // First, remove the item
                              final Attribute item = _attributes.removeAt(
                                oldIndex,
                              );

                              // Then insert it at the new position
                              _attributes.insert(newIndex, item);

                              // Update order values for all attributes
                              for (var i = 0; i < _attributes.length; i++) {
                                _attributes[i] = _attributes[i].copyWith(
                                  order: i,
                                );
                              }

                              // Update primary key index after reordering
                              if (_primaryKeyIndex != null) {
                                if (_primaryKeyIndex == oldIndex) {
                                  // The primary key was moved
                                  _primaryKeyIndex = newIndex;
                                } else if (oldIndex < _primaryKeyIndex! &&
                                    newIndex >= _primaryKeyIndex!) {
                                  // An item was moved from before the PK to after it
                                  // This shifts the PK one position up
                                  _primaryKeyIndex = _primaryKeyIndex! - 1;
                                } else if (oldIndex > _primaryKeyIndex! &&
                                    newIndex <= _primaryKeyIndex!) {
                                  // An item was moved from after the PK to before it
                                  // This shifts the PK one position down
                                  _primaryKeyIndex = _primaryKeyIndex! + 1;
                                }

                                // Ensure the index stays within bounds
                                _primaryKeyIndex = _primaryKeyIndex!.clamp(
                                  0,
                                  _attributes.length - 1,
                                );
                              }
                            });
                          },
                          itemBuilder:
                              (context, index) => Material(
                                key: ValueKey(_attributes[index].id),
                                type: MaterialType.transparency,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: AttributeRow(
                                    index: index,
                                    isPrimaryKey:
                                        _attributes[index].isPrimaryKey,
                                    isForeignKey:
                                        _attributes[index].isForeignKey,
                                    isNullable: _attributes[index].isNullable,
                                    availableEntities: availableEntities,
                                    onRemove: _removeAttribute,
                                    onUpdate: _updateAttribute,
                                    attribute: _attributes[index],
                                  ),
                                ),
                              ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Add attribute button
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: OutlinedButton.icon(
                    onPressed: _addAttribute,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Attribute'),
                  ),
                ),
              ],
            ),
          ),

          // Vertical Divider
          SizedBox(
            width: 20,
            height: 500,
            child: VerticalDivider(
              width: 1,
              color: Theme.of(context).dividerColor,
            ),
          ),

          // Right side - Preview
          SizedBox(
            width: 290,
            height: 500,
            child: SingleChildScrollView(
              child: EntityCard(
                entity: Entity(
                  id: -1,
                  name:
                      _nameController.text.isEmpty
                          ? 'Entity Name'
                          : _nameController.text,
                  attributes:
                      _attributes.where((attr) => attr.name.isNotEmpty).toList()
                        ..sort((a, b) => a.order.compareTo(b.order)),
                ),
              ),
            ),
          ),
        ],
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

          if (_attributes.any((a) => a.name.isEmpty)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('All attributes must have a name')),
            );
            return;
          }

          if (_attributes.any((a) => a.dataType.isEmpty)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('All attributes must have a type')),
            );
            return;
          }

          if (widget.entity != null) {
            // Update existing entity
            final Entity updatedEntity = widget.entity!.copyWith(
              name: _nameController.text,
              attributes:
                  _attributes.where((attr) => attr.name.isNotEmpty).toList()
                    ..sort((a, b) => a.order.compareTo(b.order)),
            );

            context.read<DiagramCubit>().updateEntity(
              widget.entity!.id,
              updatedEntity,
            );
          } else {
            final entity = Entity(
              id: -1,
              name: _nameController.text,
              attributes: _attributes.toList(),
            );

            context.read<DiagramCubit>().addEntity(entity);
          }

          Navigator.pop(context);
        },
        child: Text(widget.entity != null ? 'Update Entity' : 'Add Entity'),
      ),
    ],
  );
}
