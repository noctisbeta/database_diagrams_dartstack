import 'package:server/annotations/prefix.dart';
import 'package:server/diagrams/implementations/diagrams_handler.dart';
import 'package:shelf_router/shelf_router.dart';

@Prefix('/api/v1/diagrams')
Router createDiagramsRouter(DiagramsHandler diagramsHandler) {
  final router =
      Router()
        ..post('/', diagramsHandler.saveDiagram)
        ..get('/', diagramsHandler.getDiagrams)
        ..put('/<id>', diagramsHandler.updateDiagram)
        ..delete('/<id>', diagramsHandler.deleteDiagram);

  return router;
}
