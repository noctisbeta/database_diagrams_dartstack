import 'package:client/diagrams/components/attribute_row/desktop_attribute_row.dart';
import 'package:client/diagrams/components/attribute_row/mobile_attribute_row.dart';
import 'package:client/diagrams/components/attribute_row/tablet_attribute_row.dart';
import 'package:client/responsive/responsive_builder.dart';
import 'package:common/er/entity.dart';
import 'package:flutter/material.dart';

class AttributeRow extends StatelessWidget {
  const AttributeRow({
    required this.attributeId,
    required this.availableEntities,
    super.key,
  });

  final List<Entity> availableEntities;
  final int attributeId;

  @override
  Widget build(BuildContext context) => ResponsiveBuilder(
    desktop:
        () => DesktopAttributeRow(
          attributeId: attributeId,
          availableEntities: availableEntities,
        ),
    tablet:
        () => TabletAttributeRow(
          attributeId: attributeId,
          availableEntities: availableEntities,
        ),
    mobile:
        () => MobileAttributeRow(
          attributeId: attributeId,
          availableEntities: availableEntities,
        ),
  );
}
