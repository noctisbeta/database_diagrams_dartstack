import 'package:server/routes/api/v1/projects/projects_route_handler.dart';
import 'package:shelf_router/shelf_router.dart';

Router createProjectsRouter() {
  final router = Router()..all('/', projectsRouteHandler);

  return router;
}
