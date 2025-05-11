import 'package:client/landing/components/diagrams_list/desktop_diagrams_list.dart';
import 'package:client/landing/components/diagrams_list/mobile_diagrams_list.dart';
import 'package:client/landing/components/diagrams_list/tablet_diagrams_list.dart';
import 'package:client/responsive/responsive_builder.dart';
import 'package:flutter/material.dart';

class DiagramsList extends StatelessWidget {
  const DiagramsList({super.key});

  @override
  Widget build(BuildContext context) => const ResponsiveBuilder(
    desktop: DesktopDiagramsList.new,
    tablet: TabletDiagramsList.new,
    mobile: MobileDiagramsList.new,
  );
}
