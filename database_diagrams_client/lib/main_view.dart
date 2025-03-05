import 'dart:async';

import 'package:database_diagrams_client/diagram_canvas.dart';
import 'package:database_diagrams_client/state/diagram_cubit.dart';
import 'package:database_diagrams_client/state/diagram_state.dart';
import 'package:database_diagrams_client/widgets/add_entity_dialog.dart';
import 'package:database_diagrams_client/widgets/toolbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  void _showAddEntityDialog(BuildContext context) => unawaited(
    showDialog(
      context: context,
      builder:
          (dialogContext) => BlocProvider.value(
            value: context.read<DiagramCubit>(),
            child: const AddEntityDialog(),
          ),
    ),
  );

  @override
  Widget build(BuildContext context) => BlocBuilder<DiagramCubit, DiagramState>(
    builder:
        (context, state) => Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddEntityDialog(context),
            child: const Icon(Icons.add),
          ),
          body: Column(
            children: [
              // Replace the Container with Toolbar
              Toolbar(onSave: () {}, onSignIn: () {}),
              Expanded(
                child: DiagramCanvas(
                  entities: state.entities,
                  entityPositions: state.entityPositions,
                  onEntityMoved: (entityId, offset) {
                    context.read<DiagramCubit>().updateEntityPosition(
                      entityId,
                      offset.dx,
                      offset.dy,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
  );
}
