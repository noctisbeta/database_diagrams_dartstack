import 'package:client/diagrams/controllers/diagram_cubit.dart';
import 'package:client/diagrams/models/diagram_state.dart';
import 'package:common/er/diagrams/diagram_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DiagramTypeIndicator extends StatelessWidget {
  const DiagramTypeIndicator({super.key});

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
        case DiagramType.firebase:
          icon = Icons.article;
          color = Colors.orange;
          label = 'Firebase';
        case DiagramType.custom:
          icon = Icons.settings;
          color = Colors.green;
          label = 'Custom';
      }

      return Tooltip(
        message: 'This diagram uses $label schema rules',
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
      );
    },
  );
}
