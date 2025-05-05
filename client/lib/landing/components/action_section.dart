import 'dart:async';

import 'package:client/diagrams/controllers/diagram_cubit.dart';
import 'package:client/landing/components/action_card.dart';
import 'package:client/landing/components/create_diagram_dialog.dart';
import 'package:client/routing/router_path.dart';
import 'package:common/er/diagram.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ActionSection extends StatelessWidget {
  const ActionSection({super.key});

  Future<void> _showCreateDiagramDialog(BuildContext context) => showDialog(
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
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: ActionCard(
          title: 'Use Template',
          description: 'Start with a pre-built schema',
          icon: Icons.content_copy,
          iconColor: Colors.orange,
          onTap: () {},
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: ActionCard(
          title: 'Create New',
          description: 'Start a new diagram from scratch',
          icon: Icons.add_circle_outline,
          iconColor: Colors.green,
          onTap: () {
            unawaited(_showCreateDiagramDialog(context));
          },
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: ActionCard(
          title: 'Import',
          description: 'Import from SQL or JSON',
          icon: Icons.upload_file,
          iconColor: Colors.purple,
          onTap: () {},
        ),
      ),
    ],
  );
}
