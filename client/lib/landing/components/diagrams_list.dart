import 'dart:async';

import 'package:client/common/main_view.dart';
import 'package:client/diagrams/controllers/diagram_cubit.dart';
import 'package:common/er/diagram.dart';
import 'package:common/logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DiagramsList extends StatefulWidget {
  const DiagramsList({super.key});

  @override
  State<DiagramsList> createState() => _DiagramsListState();
}

class _DiagramsListState extends State<DiagramsList> {
  late Future<List<Diagram>> diagramsFuture =
      context.read<DiagramCubit>().getDiagrams();

  Future<void> _refreshDiagrams() async {
    setState(() {
      diagramsFuture = context.read<DiagramCubit>().getDiagrams();
    });
  }

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
          (dialogContext) => AlertDialog(
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

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  @override
  Widget build(BuildContext context) => Container(
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
        FutureBuilder<List<Diagram>>(
          future: diagramsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              LOG.e('Error loading diagrams: ${snapshot.error}');
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
                  onTap: () async {
                    context.read<DiagramCubit>().loadDiagram(diagram);
                    await Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const MainView()),
                    );
                  },
                );
              },
            );
          },
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
  );
}
