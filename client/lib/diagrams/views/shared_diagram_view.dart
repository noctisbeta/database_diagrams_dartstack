import 'package:client/diagrams/components/diagram_canvas.dart';
import 'package:client/diagrams/repositories/shared_diagram_data_provider.dart';
import 'package:client/diagrams/repositories/shared_diagram_repository.dart';
import 'package:common/er/diagram.dart';
import 'package:common/er/diagrams/get_shared_diagram_request.dart';
import 'package:common/er/diagrams/get_shared_diagram_response.dart';
import 'package:flutter/material.dart';

class SharedDiagramView extends StatefulWidget {
  const SharedDiagramView({required this.shortcode, super.key});

  final String shortcode;

  @override
  State<SharedDiagramView> createState() => _SharedDiagramViewState();
}

class _SharedDiagramViewState extends State<SharedDiagramView> {
  late Future<Diagram> diagramFuture = _getDiagram();

  Future<Diagram> _getDiagram() async {
    final GetSharedDiagramResponse response = await SharedDiagramRepository(
      dataProvider: SharedDiagramDataProvider(),
    ).getSharedDiagram(GetSharedDiagramRequest(shortcode: widget.shortcode));

    switch (response) {
      case GetSharedDiagramResponseSuccess(:final diagram):
        return diagram;
      case GetSharedDiagramResponseError(:final message):
        throw Exception('Failed to load diagram: $message');
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Diagram>(
    future: diagramFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        String errorMessage = 'Failed to load diagram.';
        // Extract a more specific message from the exception if possible
        if (snapshot.error is Exception) {
          final message = (snapshot.error! as Exception).toString();
          errorMessage =
              message.startsWith('Exception: ')
                  ? message.substring(11)
                  : message;
        }
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Error: $errorMessage',
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        );
      } else if (snapshot.hasData) {
        final Diagram diagram = snapshot.data!;

        // If not, DiagramCanvas might need adjustment or a read-only version.
        return Scaffold(
          appBar: AppBar(title: Text(diagram.name), centerTitle: true),
          body: DiagramCanvas(
            entities: diagram.entities,
            entityPositions: diagram.entityPositions,
            onEntityMoved: (_, _) {}, // Read-only: No move handler
          ),
        );
      } else {
        return const Center(child: Text('No diagram data available.'));
      }
    },
  );
}
