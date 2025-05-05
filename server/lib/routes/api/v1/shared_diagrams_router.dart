import 'package:server/annotations/prefix.dart';
import 'package:server/diagrams/implementations/diagrams_handler.dart';
import 'package:shelf_router/shelf_router.dart';

@Prefix('/api/v1/shared-diagrams')
Router createDiagramsRouter(DiagramsHandler diagramsHandler) {
  final router = Router()..get('/<id>', diagramsHandler.getSharedDiagram);

  return router;
}
