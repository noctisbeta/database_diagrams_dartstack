import 'package:client/diagrams/controllers/diagram_cubit.dart';
import 'package:client/landing/components/create_diagram_dialog/desktop_create_diagram_dialog.dart';
import 'package:client/landing/components/create_diagram_dialog/mobile_create_diagram_dialog.dart';
import 'package:client/landing/components/create_diagram_dialog/tablet_create_diagram_dialog.dart';
import 'package:client/responsive/responsive_builder.dart';
import 'package:client/routing/router_path.dart';
import 'package:common/er/diagram.dart';
import 'package:common/er/diagrams/diagram_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CreateDiagramDialog extends StatelessWidget {
  const CreateDiagramDialog({required this.onCreateDiagram, super.key});
  final Function(String name, DiagramType type) onCreateDiagram;

  static Future<void> showCreateDiagramDialog(BuildContext context) =>
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => CreateDiagramDialog(
              onCreateDiagram: (name, diagramType) {
                final diagram = Diagram.initial(name, diagramType);
                context.read<DiagramCubit>().loadDiagram(diagram);

                Navigator.of(context).pop();

                context.goNamed(RouterPath.editor.name);
              },
            ),
      );

  @override
  Widget build(BuildContext context) => ResponsiveBuilder(
    desktop: () => DesktopCreateDiagramDialog(onCreateDiagram: onCreateDiagram),
    tablet: () => TabletCreateDiagramDialog(onCreateDiagram: onCreateDiagram),
    mobile: () => MobileCreateDiagramDialog(onCreateDiagram: onCreateDiagram),
  );
}
