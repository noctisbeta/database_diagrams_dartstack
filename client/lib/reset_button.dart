import 'dart:async';

import 'package:client/diagrams/controllers/diagram_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ResetButton extends StatelessWidget {
  const ResetButton({super.key});

  @override
  Widget build(BuildContext context) => IconButton(
    icon: const Icon(Icons.refresh),
    tooltip: 'Reset Diagram',
    onPressed: () => unawaited(_showResetConfirmationDialog(context)),
  );

  Future<void> _showResetConfirmationDialog(BuildContext context) async {
    void reset() {
      context.read<DiagramCubit>().resetDiagram();
    }

    final bool? shouldReset = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reset Diagram'),
            content: const Text(
              'Are you sure you want to reset this diagram?'
              ' All unsaved changes will be lost.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Reset'),
              ),
            ],
          ),
    );

    if (shouldReset ?? false) {
      reset();
    }
  }
}
