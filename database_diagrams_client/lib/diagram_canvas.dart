import 'package:database_diagrams_client/entity_card.dart';
import 'package:database_diagrams_common/er/entity.dart';
import 'package:database_diagrams_common/er/entity_position.dart';
import 'package:flutter/material.dart';

class DiagramCanvas extends StatelessWidget {
  const DiagramCanvas({
    required this.entities,
    required this.entityPositions,
    required this.onEntityMoved,
    super.key,
  });

  final List<Entity> entities;
  final List<EntityPosition> entityPositions;
  final void Function(String entityId, Offset position) onEntityMoved;

  @override
  Widget build(BuildContext context) => InteractiveViewer(
    boundaryMargin: const EdgeInsets.all(100),
    minScale: 0.5,
    maxScale: 2,
    child: SizedBox(
      width: 2000,
      height: 2000,
      child: Stack(
        children: [
          // Background grid (to be implemented)
          for (final entity in entities)
            _DraggableEntity(
              key: ValueKey(entity.id),
              entity: entity,
              position: entityPositions.firstWhere(
                (pos) => pos.entityId == entity.id,
              ),
              onMoved: onEntityMoved,
            ),
        ],
      ),
    ),
  );
}

class _DraggableEntity extends StatelessWidget {
  const _DraggableEntity({
    required this.entity,
    required this.position,
    required this.onMoved,
    super.key,
  });

  final Entity entity;
  final EntityPosition position;
  final void Function(String entityId, Offset position) onMoved;

  @override
  Widget build(BuildContext context) => Positioned(
    left: position.x,
    top: position.y,
    child: Draggable(
      feedback: EntityCard(entity: entity),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: EntityCard(entity: entity),
      ),
      onDragEnd: (details) {
        // Get the render box of the canvas
        final RenderBox box = context.findRenderObject()! as RenderBox;
        // Convert global position to local
        final Offset localPosition = box.globalToLocal(details.offset);

        onMoved(entity.id, localPosition);
      },
      child: EntityCard(entity: entity),
    ),
  );
}
