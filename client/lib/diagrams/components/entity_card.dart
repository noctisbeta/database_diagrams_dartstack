import 'package:common/er/entity.dart';
import 'package:flutter/material.dart';

class EntityCard extends StatelessWidget {
  const EntityCard({required this.entity, super.key});

  final Entity entity;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 250, // Fixed width for the card
    child: Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Entity name section
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Text(
              entity.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          // Attributes section
          if (entity.attributes.isNotEmpty)
            ColoredBox(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      child: Row(
                        children: [
                          // Name section with fixed width
                          Expanded(flex: 2, child: Text(attribute.name)),
                          // Flags section
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
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
                          const SizedBox(width: 8),
                          // Type section with fixed width
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontStyle: FontStyle.italic,
                                ),
                                children: [
                                  TextSpan(text: attribute.dataType),
                                  if (attribute.isNullable)
                                    const TextSpan(
                                      text: '?',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                ],
                              ),
                            ),
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
