import 'dart:async';

import 'package:client/diagrams/diagram_cubit.dart';
import 'package:common/er/diagram.dart';
import 'package:common/logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DiagramsListDialog extends StatefulWidget {
  const DiagramsListDialog({super.key});

  @override
  State<DiagramsListDialog> createState() => _DiagramsListDialogState();
}

class _DiagramsListDialogState extends State<DiagramsListDialog> {
  late Future<List<Diagram>> diagramsFuture =
      context.read<DiagramCubit>().getDiagrams();

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
          FutureBuilder<List<Diagram>>(
            future: diagramsFuture,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                LOG.e('Error loading diagrams: ${snapshot.error}');
              }
              return Flexible(
                child: switch (snapshot.connectionState) {
                  ConnectionState.waiting ||
                  ConnectionState.none ||
                  ConnectionState.active => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  ConnectionState.done =>
                    snapshot.hasError
                        ? const Center(child: Text('Error loading diagrams'))
                        : snapshot.data!.isEmpty
                        ? const Center(child: Text('No diagrams found'))
                        : ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final List<Diagram> diagrams = snapshot.data!;
                            final Diagram diagram = diagrams[index];
                            return ListTile(
                              title: Text(diagram.name),
                              subtitle: Text(diagram.name),
                              trailing: Text(
                                '${diagram.createdAt.day}/${diagram.createdAt.month}/${diagram.createdAt.year}',
                              ),
                              onTap: () {
                                context.read<DiagramCubit>().loadDiagram(
                                  diagram,
                                );
                                Navigator.of(context).pop();
                              },
                            );
                          },
                        ),
                },
              );
            },
          ),

          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ),
        ],
      ),
    ),
  );
}
