import 'package:client/diagrams/components/add_entity_dialog/desktop_add_entity_dialog.dart';
import 'package:client/diagrams/components/add_entity_dialog/mobile_add_entity_dialog.dart';
import 'package:client/diagrams/components/add_entity_dialog/tablet_add_entity_dialog.dart';
import 'package:client/responsive/responsive_builder.dart';
import 'package:common/er/entity.dart';
import 'package:flutter/material.dart';

class AddEntityDialog extends StatelessWidget {
  const AddEntityDialog({this.entity, super.key});

  final Entity? entity;

  @override
  Widget build(BuildContext context) => ResponsiveBuilder(
    desktop: () => DesktopAddEntityDialog(entity: entity),
    tablet: () => TabletAddEntityDialog(entity: entity),
    mobile: () => MobileAddEntityDialog(entity: entity),
  );
}
