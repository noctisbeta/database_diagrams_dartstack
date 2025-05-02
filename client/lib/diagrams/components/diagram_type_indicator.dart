import 'dart:async';

import 'package:client/diagrams/controllers/diagram_cubit.dart';
import 'package:client/diagrams/models/diagram_state.dart';
import 'package:common/er/diagrams/diagram_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DiagramTypeIndicator extends StatelessWidget {
  const DiagramTypeIndicator({super.key});

  void _showDataTypesDialog(BuildContext context, String label) {
    final Set<String>? dataTypes =
        context.read<DiagramCubit>().allowedDataTypes;

    if (dataTypes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Custom diagrams do not have predefined data types.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    unawaited(
      showDialog<void>(
        context: context,
        builder:
            (BuildContext dialogContext) => AlertDialog(
              title: Text('$label Data Types'),
              content: SizedBox(
                width: 500,

                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: dataTypes.length,
                  itemBuilder:
                      (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(dataTypes.elementAt(index)),
                      ),
                  separatorBuilder:
                      (context, index) => const Divider(height: 1),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
              ],
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<DiagramCubit, DiagramState>(
    buildWhen:
        (previous, current) => previous.diagramType != current.diagramType,
    builder: (context, state) {
      final DiagramType diagramType = state.diagramType;

      // Define type-specific styles
      final IconData icon;
      final Color color;
      final String label;

      switch (diagramType) {
        case DiagramType.postgresql:
          icon = Icons.table_chart;
          color = Colors.blue;
          label = 'PostgreSQL';
        case DiagramType.firestore:
          icon = Icons.article;
          color = Colors.orange;
          label = 'Firestore';
        case DiagramType.custom:
          icon = Icons.settings;
          color = Colors.green;
          label = 'Custom';
      }

      return Tooltip(
        message: 'This diagram uses $label schema rules',
        child: InkWell(
          onTap: () => _showDataTypesDialog(context, label),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(color: color, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
