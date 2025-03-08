import 'package:database_diagrams_server/routes/api/v1/auth/login/login_route_handler.dart';
import 'package:database_diagrams_server/routes/api/v1/auth/refresh/index.dart';
import 'package:database_diagrams_server/routes/api/v1/auth/register/register_route_handler.dart';
import 'package:shelf_router/shelf_router.dart';

Router createAuthRouter() {
  final router =
      Router()
        ..all('/login', loginRouteHandler)
        ..all('/register', registerRouteHandler)
        ..all('/refresh', refreshRouteHandler);

  return router;
}
