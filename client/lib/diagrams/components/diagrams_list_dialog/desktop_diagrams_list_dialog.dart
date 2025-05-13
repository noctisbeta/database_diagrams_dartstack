import 'dart:async';

import 'package:client/diagrams/controllers/diagram_cubit.dart';
import 'package:client/routing/router_path.dart';
import 'package:common/er/diagram.dart';
import 'package:common/logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class DesktopDiagramsListDialog extends StatefulWidget {
  const DesktopDiagramsListDialog({super.key});

  @override
  State<DesktopDiagramsListDialog> createState() =>
      _DesktopDiagramsListDialogState();
}

class _DesktopDiagramsListDialogState extends State<DesktopDiagramsListDialog> {
  late Future<List<Diagram>> diagramsFuture =
      context.read<DiagramCubit>().getDiagrams();

  // Function to refresh diagrams list
  Future<void> _refreshDiagrams() async {
    final Future<List<Diagram>> newDiagrams =
        context.read<DiagramCubit>().getDiagrams();

    setState(() {
      diagramsFuture = newDiagrams;
    });
  }

  // Show delete confirmation dialog
  Future<void> _showDeleteConfirmation(
    BuildContext context,
    Diagram diagram,
  ) async {
    void onError() {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to delete diagram')));
    }

    Future<void> onSuccess() async {
      await context.read<DiagramCubit>().deleteDiagram(diagram.id!);
      await _refreshDiagrams();
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder:
          (BuildContext dialogContext) => AlertDialog(
            title: const Text('Delete Diagram'),
            content: Text(
              'Are you sure you want to delete "${diagram.name}"?\n\n'
              'This action cannot be undone. All entities and relationships '
              'in this diagram will be permanently deleted.',
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
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed ?? false) {
      try {
        await onSuccess();
      } on Exception catch (e) {
        LOG.e('Error deleting diagram: $e');
        onError();
      }
    }
  }

  @override
  Widget build(BuildContext context) => Dialog(
    child: Container(
      width: 500,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Diagrams',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: 300,
            child: FutureBuilder<List<Diagram>>(
              future: diagramsFuture,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  LOG.e('Error loading diagrams: ${snapshot.error}');
                }

                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading diagrams'));
                }

                if (snapshot.data!.isEmpty) {
                  return const Center(child: Text('No diagrams found'));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final List<Diagram> diagrams = snapshot.data!;
                    final Diagram diagram = diagrams[index];
                    return ListTile(
                      title: Text(diagram.name),
                      subtitle: Text(
                        'Last modified: ${_formatDate(diagram.updatedAt)}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_formatDate(diagram.createdAt)),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            color: Theme.of(context).colorScheme.error,
                            tooltip: 'Delete diagram',
                            onPressed:
                                () => unawaited(
                                  _showDeleteConfirmation(context, diagram),
                                ),
                          ),
                        ],
                      ),
                      onTap: () {
                        context.read<DiagramCubit>().loadDiagram(diagram);

                        Navigator.of(context).pop();

                        final String? currentLocation =
                            GoRouter.of(context).state.name;

                        if (currentLocation == RouterPath.landing.name) {
                          context.goNamed(
                            RouterPath.editor.name,
                            extra: diagram,
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: _refreshDiagrams,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  // Helper method to format dates consistently
  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}
