import 'dart:async';

import 'package:client/diagrams/components/add_entity_dialog/add_entity_dialog.dart';
import 'package:client/diagrams/controllers/diagram_cubit.dart';
import 'package:common/er/entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EntityCard extends StatelessWidget {
  const EntityCard({required this.entity, required this.editable, super.key});

  final Entity entity;
  final bool editable;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 250,
    child: Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    entity.name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (editable)
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    iconSize: 18,
                    color: Theme.of(context).colorScheme.onPrimaryFixedVariant,
                    tooltip: 'Edit Entity',
                    onPressed: () {
                      unawaited(
                        showDialog(
                          context: context,
                          builder:
                              (dialogContext) => BlocProvider.value(
                                value: context.read<DiagramCubit>(),
                                child: AddEntityDialog(entity: entity),
                              ),
                        ),
                      );
                    },
                    splashRadius: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(), // To make it compact
                  ),
              ],
            ),
          ),
          ColoredBox(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final attribute in entity.attributes)
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                attribute.name,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Spacer(),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (attribute.isIdentity)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 4),
                                    child: Icon(
                                      Icons.format_list_numbered,
                                      size: 16,
                                      color: Colors.green,
                                    ),
                                  ),
                                if (attribute.isPrimaryKey)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 4),
                                    child: Icon(
                                      Icons.key,
                                      size: 16,
                                      color: Colors.amber,
                                    ),
                                  ),
                                if (attribute.isForeignKey)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 4),
                                    child: Icon(
                                      Icons.link,
                                      size: 16,
                                      color: Colors.blue,
                                    ),
                                  ),
                              ],
                            ),
                            Text(
                              attribute.dataType,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic,
                                fontSize: 12,
                              ),
                            ),
                            if (attribute.isNullable)
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Text(
                                  '?',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
