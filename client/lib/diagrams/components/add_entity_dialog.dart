import 'package:client/diagrams/components/attribute_row.dart';
import 'package:client/diagrams/components/entity_card.dart';
import 'package:client/diagrams/controllers/diagram_cubit.dart';
import 'package:client/diagrams/controllers/entity_editor_cubit.dart';
import 'package:client/diagrams/models/entity_editor_state.dart';
import 'package:common/er/attribute.dart';
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

  late List<Attribute> localAttributes =
      context.read<EntityEditorCubit>().state.attributes;

  bool showTooltips = true;

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
      localAttributes = state.attributes;

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
                        errorText:
                            context.read<EntityEditorCubit>().state.nameError,
                        labelText: 'Entity Name',
                        hintText: 'Enter entity name',
                        border: const OutlineInputBorder(),
                      ),
                      autofocus: true,
                      onChanged: context.read<EntityEditorCubit>().setName,
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
                            child: TooltipVisibility(
                              visible: showTooltips,
                              child: ReorderableListView.builder(
                                shrinkWrap: true,
                                buildDefaultDragHandles: false,
                                itemCount: localAttributes.length,
                                proxyDecorator:
                                    (child, index, animation) => Material(
                                      type: MaterialType.transparency,
                                      child: TooltipVisibility(
                                        visible: false,
                                        child: BlocProvider.value(
                                          value:
                                              context.read<EntityEditorCubit>(),
                                          child: child,
                                        ),
                                      ),
                                    ),
                                onReorder: (int oldIndex, int newIndex) {
                                  if (oldIndex < newIndex) {
                                    newIndex -= 1;
                                  }
                                  setState(() {
                                    final Attribute item = localAttributes
                                        .removeAt(oldIndex);

                                    localAttributes.insert(newIndex, item);

                                    for (
                                      int i = 0;
                                      i < localAttributes.length;
                                      i++
                                    ) {
                                      localAttributes[i] = localAttributes[i]
                                          .copyWith(order: i);
                                    }
                                  });
                                },
                                onReorderStart: (index) {
                                  setState(() {
                                    showTooltips = false;
                                  });
                                },

                                onReorderEnd: (index) {
                                  context
                                      .read<EntityEditorCubit>()
                                      .setAttributes(localAttributes);

                                  showTooltips = true;
                                },
                                itemBuilder:
                                    (context, index) => Material(
                                      key: ValueKey(localAttributes[index].id),
                                      type: MaterialType.transparency,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        child: AttributeRow(
                                          availableEntities: availableEntities,
                                          attributeId:
                                              localAttributes[index].id,
                                        ),
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
                        onPressed:
                            context.read<EntityEditorCubit>().addAttribute,
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
                      name:
                          context.watch<EntityEditorCubit>().state.name.isEmpty
                              ? 'Entity Name'
                              : context.watch<EntityEditorCubit>().state.name,
                      attributes:
                          context
                              .watch<EntityEditorCubit>()
                              .state
                              .attributes
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
              final bool isValid = context
                  .read<EntityEditorCubit>()
                  .validateEntity(
                    context.read<DiagramCubit>().allowedDataTypes,
                  );

              if (!isValid) {
                return;
              }

              if (entityId != null) {
                final Entity updatedEntity = Entity(
                  id: entityId!,
                  name: context.read<EntityEditorCubit>().state.name,
                  attributes:
                      context
                          .read<EntityEditorCubit>()
                          .state
                          .attributes
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
                  name: context.read<EntityEditorCubit>().state.name,
                  attributes:
                      context
                          .read<EntityEditorCubit>()
                          .state
                          .attributes
                          .toList(),
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
