import 'package:database_diagrams_client/entity_card.dart';
import 'package:database_diagrams_client/relationship_painter.dart';
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
          // Relationship lines layer
          CustomPaint(
            size: const Size(2000, 2000),
            painter: RelationshipPainter(
              entities: entities,
              entityPositions: entityPositions,
            ),
          ),
          // Existing entities
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

class _DraggableEntity extends StatefulWidget {
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
  State<_DraggableEntity> createState() => _DraggableEntityState();
}

class _DraggableEntityState extends State<_DraggableEntity> {
  Offset? dragStartOffset;

  @override
  Widget build(BuildContext context) => Positioned(
    left: widget.position.x,
    top: widget.position.y,
    child: GestureDetector(
      onPanStart: (details) {
        dragStartOffset = details.localPosition;
      },
      onPanUpdate: (details) {
        final RenderBox? stackBox =
            context.findAncestorRenderObjectOfType<RenderBox>();

        if (stackBox != null && dragStartOffset != null) {
          final Offset localPosition = stackBox.globalToLocal(
            details.globalPosition,
          );

          // Subtract the initial tap offset to maintain grab point
          widget.onMoved(
            widget.entity.id,
            Offset(
              localPosition.dx - dragStartOffset!.dx,
              localPosition.dy - dragStartOffset!.dy,
            ),
          );
        }
      },
      onPanEnd: (_) {
        dragStartOffset = null;
      },
      child: EntityCard(entity: widget.entity),
    ),
  );
}
