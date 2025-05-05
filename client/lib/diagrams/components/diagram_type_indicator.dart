import 'dart:async';

import 'package:client/diagrams/controllers/diagram_cubit.dart';
import 'package:client/diagrams/models/diagram_state.dart';
import 'package:common/er/diagram.dart';
import 'package:common/er/diagrams/diagram_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum DiagramAction { showTypes, changeRuleset }

class DiagramTypeIndicator extends StatelessWidget {
  const DiagramTypeIndicator({super.key});

  void _showDataTypesDialog(BuildContext context, String label) {
    final Set<String>? dataTypes =
        context.read<DiagramCubit>().allowedDataTypes;

    if (dataTypes == null || dataTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No predefined data types for this ruleset.'),
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

  Future<bool?> _showResetConfirmationDialog(
    BuildContext context,
    DiagramType currentType,
    DiagramType newType,
  ) => showDialog<bool>(
    context: context,
    builder:
        (dialogContext) => AlertDialog(
          title: const Text('Change Diagram Ruleset?'),
          content: Text(
            'Changing the diagram ruleset from ${currentType.name} '
            'to ${newType.name} '
            'will reset the current diagram canvas and start a new diagram.\n\n'
            'Any unsaved changes will be lost. Are you sure you want'
            ' to continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Reset and Change'),
            ),
          ],
        ),
  );

  Future<void> _showChangeRulesetDialog(
    BuildContext context,
    DiagramType currentType,
  ) async {
    final DiagramType? selectedType = await showDialog<DiagramType>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Select New Ruleset'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  DiagramType.values
                      .map(
                        (type) => ListTile(
                          title: Text(type.name),

                          enabled: type != currentType,
                          onTap:
                              type != currentType
                                  ? () => Navigator.of(dialogContext).pop(type)
                                  : null,
                        ),
                      )
                      .toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );

    if (selectedType != null && context.mounted) {
      final bool? confirmed = await _showResetConfirmationDialog(
        context,
        currentType,
        selectedType,
      );

      if ((confirmed ?? false) && context.mounted) {
        context.read<DiagramCubit>().loadDiagram(
          Diagram.initial('New Diagram', selectedType),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<DiagramCubit, DiagramState>(
    buildWhen:
        (previous, current) => previous.diagramType != current.diagramType,
    builder: (context, state) {
      final DiagramType diagramType = state.diagramType;

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

      return Builder(
        builder:
            (menuContext) => Tooltip(
              message: 'Diagram Ruleset: $label (Click for options)',
              child: InkWell(
                onTap: () {
                  final RenderBox renderBox =
                      menuContext.findRenderObject()! as RenderBox;
                  final Offset offset = renderBox.localToGlobal(Offset.zero);
                  final Size size = renderBox.size;

                  unawaited(
                    showMenu<DiagramAction>(
                      context: context,
                      position: RelativeRect.fromLTRB(
                        offset.dx,
                        offset.dy + size.height,
                        offset.dx + size.width,
                        offset.dy + size.height * 2,
                      ),
                      items: const [
                        PopupMenuItem<DiagramAction>(
                          value: DiagramAction.showTypes,
                          child: Text('Show Allowed Types'),
                        ),
                        PopupMenuItem<DiagramAction>(
                          value: DiagramAction.changeRuleset,
                          child: Text('Change Ruleset...'),
                        ),
                      ],
                      elevation: 8,
                    ).then((DiagramAction? selectedAction) {
                      if (selectedAction != null) {
                        switch (selectedAction) {
                          case DiagramAction.showTypes:
                            _showDataTypesDialog(context, label);
                          case DiagramAction.changeRuleset:
                            _showChangeRulesetDialog(context, diagramType);
                        }
                      }
                    }),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
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
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      );
    },
  );
}
