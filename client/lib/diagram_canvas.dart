import 'dart:async';

import 'package:client/entity_card.dart';
import 'package:client/relationship_painter.dart';
import 'package:client/state/diagram_cubit.dart';
import 'package:client/widgets/add_entity_dialog.dart';
import 'package:common/er/entity.dart';
import 'package:common/er/entity_position.dart';
import 'package:common/logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DiagramCanvas extends StatefulWidget {
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
  State<DiagramCanvas> createState() => _DiagramCanvasState();
}

class _DiagramCanvasState extends State<DiagramCanvas> {
  @override
  Widget build(BuildContext context) => InteractiveViewer(
    boundaryMargin: const EdgeInsets.all(100),
    minScale: 0.5,
    maxScale: 2,
    child: GestureDetector(
      onSecondaryTapUp: (details) {
        final Offset adjustedOffset = details.globalPosition;
        _showCanvasContextMenu(context, adjustedOffset);
      },
      child: Stack(
        children: [
          // Relationship lines layer
          CustomPaint(
            size: const Size(2000, 2000),
            painter: RelationshipPainter(
              entities: widget.entities,
              entityPositions: widget.entityPositions,
            ),
          ),
          // Existing entities
          for (final entity in widget.entities)
            _DraggableEntity(
              key: ValueKey(entity.id),
              entity: entity,
              position: widget.entityPositions.firstWhere(
                (pos) => pos.entityId == entity.id,
              ),
              onMoved: widget.onEntityMoved,
            ),
        ],
      ),
    ),
  );

  void _showCanvasContextMenu(BuildContext context, Offset position) {
    LOG.i('Menu position: $position');
    unawaited(
      showMenu(
        context: context,
        position: RelativeRect.fromLTRB(
          position.dx,
          position.dy,
          position.dx + 1,
          position.dy + 1,
        ),
        items: [
          PopupMenuItem(
            child: const Text('Add New Entity'),
            onTap: () {
              showDialog(
                context: context,
                builder:
                    (dialogContext) => BlocProvider.value(
                      value: context.read<DiagramCubit>(),
                      child: const AddEntityDialog(),
                    ),
              );
            },
          ),
          // More menu items as needed
        ],
      ),
    );
  }
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
        // Your existing pan handling code
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
      onSecondaryTapUp: (details) {
        // Show entity-specific context menu
        _showEntityContextMenu(context, details.globalPosition);
      },
      child: EntityCard(entity: widget.entity),
    ),
  );

  void _showEntityContextMenu(BuildContext context, Offset position) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject()! as RenderBox;

    unawaited(
      showMenu(
        context: context,
        position: RelativeRect.fromRect(
          Rect.fromLTWH(position.dx, position.dy, 0, 0),
          Rect.fromLTWH(0, 0, overlay.size.width, overlay.size.height),
        ),
        items: [
          PopupMenuItem(
            child: const Text('Edit Entity'),
            onTap: () {
              // Handle edit action
            },
          ),
          PopupMenuItem(
            child: const Text('Delete Entity'),
            onTap: () {
              // Handle delete action
            },
          ),
          // More options
        ],
      ),
    );
  }
}
