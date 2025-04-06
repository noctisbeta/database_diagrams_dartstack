import 'package:common/er/attribute.dart';
import 'package:common/er/entity.dart';
import 'package:common/er/entity_position.dart';
import 'package:flutter/material.dart';

class RelationshipPainter extends CustomPainter {
  const RelationshipPainter({
    required this.entities,
    required this.entityPositions,
  });

  final List<Entity> entities;
  final List<EntityPosition> entityPositions;

  static const cardWidth = 250.0;
  static const headerHeight = 40.0;
  static const attributeHeight = 40.0;
  static const attributePadding = 6.0;
  // Add spacing constant for connection points
  static const connectionOffset = 15.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.blue.withValues(alpha: 0.6)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    for (final Entity entity in entities) {
      final EntityPosition sourcePosition = entityPositions.firstWhere(
        (pos) => pos.entityId == entity.id,
      );

      for (final Attribute attribute in entity.attributes) {
        if (attribute.isForeignKey && attribute.referencedEntityId != null) {
          final Entity targetEntity = entities.firstWhere(
            (e) => e.id == attribute.referencedEntityId,
          );

          final EntityPosition targetPosition = entityPositions.firstWhere(
            (pos) => pos.entityId == targetEntity.id,
          );

          final Attribute targetAttribute = targetEntity.attributes.firstWhere(
            (attr) => attr.isPrimaryKey,
          );

          _drawRelationship(
            canvas,
            paint,
            sourceEntity: entity,
            sourceAttribute: attribute,
            sourcePosition: sourcePosition,
            targetEntity: targetEntity,
            targetAttribute: targetAttribute,
            targetPosition: targetPosition,
          );
        }
      }
    }
  }

  void _drawRelationship(
    Canvas canvas,
    Paint paint, {
    required Entity sourceEntity,
    required Attribute sourceAttribute,
    required EntityPosition sourcePosition,
    required Entity targetEntity,
    required Attribute targetAttribute,
    required EntityPosition targetPosition,
  }) {
    final double sourceY = _getAttributeY(sourceEntity, sourceAttribute);
    final double targetY = _getAttributeY(targetEntity, targetAttribute);

    // Determine if connection should be made from left or right side
    final bool shouldConnectFromRight = sourcePosition.x < targetPosition.x;

    // Update start and end points to be offset from cards
    final startPoint = Offset(
      sourcePosition.x +
          (shouldConnectFromRight
              ? cardWidth + connectionOffset
              : -connectionOffset),
      sourcePosition.y + sourceY,
    );

    final endPoint = Offset(
      targetPosition.x +
          (!shouldConnectFromRight
              ? cardWidth + connectionOffset
              : -connectionOffset),
      targetPosition.y + targetY + (attributeHeight / 2),
    );

    // Adjust control points to be further out for smoother curves
    final controlPoint1 = Offset(
      startPoint.dx + (shouldConnectFromRight ? 70 : -70),
      startPoint.dy,
    );

    final controlPoint2 = Offset(
      endPoint.dx + (!shouldConnectFromRight ? 70 : -70),
      endPoint.dy,
    );

    // Draw the curve
    final path =
        Path()
          ..moveTo(startPoint.dx, startPoint.dy)
          ..cubicTo(
            controlPoint1.dx,
            controlPoint1.dy,
            controlPoint2.dx,
            controlPoint2.dy,
            endPoint.dx,
            endPoint.dy,
          );

    canvas.drawPath(path, paint);

    // Draw arrow head slightly offset from the end point
    _drawArrowHead(canvas, paint, endPoint, !shouldConnectFromRight ? -1 : 1);
  }

  void _drawArrowHead(
    Canvas canvas,
    Paint paint,
    Offset tip,
    double direction,
  ) {
    const arrowSize = 10.0;
    final path =
        Path()
          ..moveTo(tip.dx, tip.dy)
          ..lineTo(tip.dx + (arrowSize * direction), tip.dy - arrowSize)
          ..lineTo(tip.dx + (arrowSize * direction), tip.dy + arrowSize)
          ..close();

    canvas.drawPath(path, paint..style = PaintingStyle.fill);
  }

  double _getAttributeY(Entity entity, Attribute attribute) {
    final int attributeIndex = entity.attributes.indexOf(attribute);
    return headerHeight + attributePadding + (attributeIndex * attributeHeight);
  }

  @override
  bool shouldRepaint(RelationshipPainter oldDelegate) =>
      entities != oldDelegate.entities ||
      entityPositions != oldDelegate.entityPositions;
}
