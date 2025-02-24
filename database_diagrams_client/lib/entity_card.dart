import 'package:database_diagrams_common/er/entity.dart';
import 'package:flutter/material.dart';

class EntityCard extends StatelessWidget {
  const EntityCard({required this.entity, super.key});

  final Entity entity;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(entity.name, style: Theme.of(context).textTheme.titleMedium),
          const Divider(),
          for (final attribute in entity.attributes)
            Text(
              '${attribute.name}: ${attribute.dataType}',
              style: TextStyle(
                fontWeight:
                    attribute.isPrimaryKey
                        ? FontWeight.bold
                        : FontWeight.normal,
              ),
            ),
        ],
      ),
    ),
  );
}
