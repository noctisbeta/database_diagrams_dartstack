import 'package:client/diagrams/components/diagrams_list_dialog/desktop_diagrams_list_dialog.dart';
import 'package:client/diagrams/components/diagrams_list_dialog/mobile_diagrams_list_dialog.dart';
import 'package:client/diagrams/components/diagrams_list_dialog/tablet_diagrams_list_dialog.dart';
import 'package:client/responsive/responsive_builder.dart';
import 'package:flutter/material.dart';

class DiagramsListDialog extends StatelessWidget {
  const DiagramsListDialog({super.key});

  @override
  Widget build(BuildContext context) => ResponsiveBuilder(
    desktop: () => const DesktopDiagramsListDialog(),
    tablet: () => const TabletDiagramsListDialog(),
    mobile: () => const MobileDiagramsListDialog(),
  );
}
