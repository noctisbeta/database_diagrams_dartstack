import 'package:client/diagrams/components/attribute_row.dart';
import 'package:client/diagrams/components/entity_card.dart';
import 'package:client/diagrams/controllers/diagram_cubit.dart';
import 'package:client/diagrams/controllers/entity_editor_cubit.dart';
import 'package:client/diagrams/models/entity_editor_state.dart';
import 'package:common/er/entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddEntityDialog extends StatelessWidget {
  const AddEntityDialog({this.entity, super.key});

  final Entity? entity;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) => EntityEditorCubit(),
    child: Builder(
      builder: (context) {
        if (entity != null) {
          context.read<EntityEditorCubit>().loadEntity(entity!);
        }
        return const AddEntityDialogContent();
      },
    ),
  );
}

class AddEntityDialogContent extends StatefulWidget {
  const AddEntityDialogContent({super.key});

  @override
  State<AddEntityDialogContent> createState() => _AddEntityDialogContentState();
}

class _AddEntityDialogContentState extends State<AddEntityDialogContent> {
  final TextEditingController _nameController = TextEditingController();

  int? get entityId => context.read<EntityEditorCubit>().state.id;

  List<Entity> get availableEntities =>
      context
          .read<DiagramCubit>()
          .state
          .entities
          .where((e) => e.id != entityId)
          .toList();

  @override
  void initState() {
    super.initState();

    final EntityEditorState state = context.read<EntityEditorCubit>().state;

    _nameController.text = state.name;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<EntityEditorCubit, EntityEditorState>(
    builder: (context, state) {
      final EntityEditorCubit entityEditorCubit =
          context.read<EntityEditorCubit>();

      return AlertDialog(
        title: const Text('Add New Entity'),
        content: SizedBox(
          height: 500,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 500,
                width: 500,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        errorText: state.nameError,
                        labelText: 'Entity Name',
                        hintText: 'Enter entity name',
                        border: const OutlineInputBorder(),
                      ),
                      autofocus: true,
                      onChanged: entityEditorCubit.setName,
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: Column(
                        children: [
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
                          Expanded(
                            child: ReorderableListView.builder(
                              shrinkWrap: true,
                              buildDefaultDragHandles: false,
                              itemCount: state.attributes.length,
                              onReorder: (oldIndex, newIndex) {},
                              itemBuilder:
                                  (context, index) => Material(
                                    key: ValueKey(state.attributes[index].id),
                                    type: MaterialType.transparency,
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: AttributeRow(
                                        availableEntities: availableEntities,
                                        attribute: state.attributes[index],
                                      ),
                                    ),
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: OutlinedButton.icon(
                        onPressed: entityEditorCubit.addAttribute,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Attribute'),
                      ),
                    ),
                  ],
                ),
              ),
              const VerticalDivider(),
              SizedBox(
                width: 290,
                height: 500,
                child: SingleChildScrollView(
                  child: EntityCard(
                    entity: Entity(
                      id: -1,
                      name: state.name.isEmpty ? 'Entity Name' : state.name,
                      attributes:
                          state.attributes
                              .where((attr) => attr.name.isNotEmpty)
                              .toList()
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
              final bool isValid = entityEditorCubit.validateEntity(
                context.read<DiagramCubit>().allowedDataTypes,
              );

              if (!isValid) {
                return;
              }

              if (entityId != null) {
                final Entity updatedEntity = Entity(
                  id: entityId!,
                  name: state.name,
                  attributes:
                      state.attributes
                          .where((attr) => attr.name.isNotEmpty)
                          .toList()
                        ..sort((a, b) => a.order.compareTo(b.order)),
                );

                context.read<DiagramCubit>().updateEntity(
                  entityId!,
                  updatedEntity,
                );
              } else {
                final entity = Entity(
                  id: -1,
                  name: state.name,
                  attributes: state.attributes.toList(),
                );

                context.read<DiagramCubit>().addEntity(entity);
              }

              Navigator.pop(context);
            },
            child: Text(entityId != null ? 'Update Entity' : 'Add Entity'),
          ),
        ],
      );
    },
  );
}
