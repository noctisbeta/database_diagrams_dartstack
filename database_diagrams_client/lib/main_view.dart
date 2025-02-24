import 'package:database_diagrams_client/diagram_canvas.dart';
import 'package:database_diagrams_common/er/entity.dart';
import 'package:database_diagrams_common/er/entity_position.dart';
import 'package:flutter/material.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  final List<Entity> entities = [
    const Entity(id: '1', name: 'Example Entity', attributes: []),

    const Entity(id: '2', name: 'Another Entity', attributes: []),

    const Entity(id: '3', name: 'Yet Another Entity', attributes: []),
  ];

  final List<EntityPosition> entityPositions = [
    const EntityPosition(entityId: '1', x: 100, y: 100),

    const EntityPosition(entityId: '2', x: 200, y: 200),

    const EntityPosition(entityId: '3', x: 300, y: 300),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Column(
      children: [
        // Toolbar section
        Container(
          height: 60,
          color: Colors.grey[200],
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Add toolbar items here
              IconButton(icon: const Icon(Icons.add), onPressed: () {}),
              IconButton(icon: const Icon(Icons.save), onPressed: () {}),
            ],
          ),
        ),
        // Diagram canvas section
        Expanded(
          child: DiagramCanvas(
            entities: entities,
            entityPositions: entityPositions,
            onEntityMoved: (entityId, offset) {
              setState(() {
                final int index = entityPositions.indexWhere(
                  (pos) => pos.entityId == entityId,
                );
                entityPositions[index] = entityPositions[index].copyWith(
                  x: entityPositions[index].x + offset.dx,
                  y: entityPositions[index].y + offset.dy,
                );
              });
            },
          ),
        ),
      ],
    ),
  );
}
