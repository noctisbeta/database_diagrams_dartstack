import 'dart:async';

import 'package:client/common/main_view.dart';
import 'package:client/diagrams/controllers/diagram_cubit.dart';
import 'package:client/landing/components/action_card.dart';
import 'package:client/landing/components/create_diagram_dialog.dart';
import 'package:common/er/diagram.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ActionSection extends StatelessWidget {
  const ActionSection({super.key});

  Future<void> _showCreateDiagramDialog(BuildContext context) => showDialog(
    context: context,
    barrierDismissible: false,
    builder:
        (context) => CreateDiagramDialog(
          onCreateDiagram: (name, type) {
            final diagram = Diagram(
              id: null,
              name: name,
              entities: const [],
              entityPositions: const [],
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              diagramType: type,
            );
            context.read<DiagramCubit>().loadDiagram(diagram);

            Navigator.of(context).pop();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const MainView()),
            );
          },
        ),
  );

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: ActionCard(
          title: 'Create New',
          description: 'Start a new diagram from scratch',
          icon: Icons.add_circle_outline,
          iconColor: Colors.green,
          isPrimary: true,
          onTap: () {
            unawaited(_showCreateDiagramDialog(context));
          },
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: ActionCard(
          title: 'Use Template',
          description: 'Start with a pre-built schema',
          icon: Icons.content_copy,
          iconColor: Colors.orange,
          isPrimary: false,
          onTap: () {},
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: ActionCard(
          title: 'Import',
          description: 'Import from SQL or JSON',
          icon: Icons.upload_file,
          iconColor: Colors.purple,
          isPrimary: false,
          onTap: () {},
        ),
      ),
    ],
  );
}
