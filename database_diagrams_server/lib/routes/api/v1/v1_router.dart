import 'package:database_diagrams_server/auth/auth_providers.dart';
import 'package:database_diagrams_server/health/providers/health_service_provider.dart';
import 'package:database_diagrams_server/routes/api/v1/auth/auth_router.dart';
import 'package:database_diagrams_server/routes/api/v1/health/api_v1_health_handler.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

Future<Router> createV1Router() async {
  final Handler healthHandler = const Pipeline()
      .addMiddleware(healthServiceProvider())
      .addHandler(apiV1HealthHandler);

  final Router authRouter = createAuthRouter();
  final Handler authHandler = const Pipeline()
      .addMiddleware(authDataSourceProvider())
      .addMiddleware(authRepositoryProvider())
      .addMiddleware(authHandlerProvider())
      .addHandler(authRouter.call);

  final router =
      Router()
        ..mount('/auth', authHandler)
        ..all('/health', healthHandler);

  return router;
}
