import 'dart:async';

import 'package:client/diagrams/components/add_entity_dialog.dart';
import 'package:client/diagrams/components/entity_card.dart';
import 'package:client/diagrams/components/relationship_painter.dart';
import 'package:client/diagrams/controllers/diagram_cubit.dart';
import 'package:common/er/entity.dart';
import 'package:common/er/entity_position.dart';
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
  final void Function(int entityId, Offset position) onEntityMoved;

  @override
  State<DiagramCanvas> createState() => _DiagramCanvasState();
}

class _DiagramCanvasState extends State<DiagramCanvas> {
  @override
  Widget build(BuildContext context) => RepaintBoundary(
    key: context.read<DiagramCubit>().canvasBoundaryKey,
    child: InteractiveViewer(
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
    ),
  );

  void _showCanvasContextMenu(BuildContext context, Offset position) {
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
  final void Function(int entityId, Offset position) onMoved;

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
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showDialog(
                  context: context,
                  builder:
                      (dialogContext) => BlocProvider.value(
                        value: context.read<DiagramCubit>(),
                        child: AddEntityDialog(entity: widget.entity),
                      ),
                );
              });
            },
          ),
          PopupMenuItem(
            child: const Text('Delete Entity'),
            onTap: () {
              // Show confirmation dialog after menu is dismissed
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showDeleteConfirmationDialog(context);
              });
            },
          ),
          // More options
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) => unawaited(
    showDialog(
      context: context,
      builder:
          (BuildContext dialogContext) => AlertDialog(
            title: const Text('Delete Entity'),
            content: Text(
              'Are you sure you want to delete "${widget.entity.name}"?\n\n'
              'This action cannot be undone and will remove all relationships '
              'connected to this entity.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(); // Close dialog
                },
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                onPressed: () {
                  // Perform the delete operation
                  context.read<DiagramCubit>().deleteEntity(widget.entity.id);
                  Navigator.of(dialogContext).pop(); // Close dialog
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    ),
  );
}
