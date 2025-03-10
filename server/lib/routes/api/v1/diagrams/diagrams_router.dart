import 'package:server/routes/api/v1/diagrams/diagrams_route_handler.dart';
import 'package:shelf_router/shelf_router.dart';

Router createDiagramsRouter() {
  final router = Router()..all('/', diagramsRouteHandler);

  return router;
}
