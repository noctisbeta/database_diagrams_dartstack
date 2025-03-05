import 'package:database_diagrams_server/health/services/health_service.dart';
import 'package:database_diagrams_server/postgres/implementations/postgres_service.dart';
import 'package:database_diagrams_server/util/context_key.dart';
import 'package:database_diagrams_server/util/request_extension.dart';
import 'package:shelf/shelf.dart';

HealthService? _healthService;

Middleware healthServiceProvider() =>
    (Handler innerHandler) => (Request request) async {
      if (_healthService == null) {
        final PostgresService postgresService = request.getFromContext(
          ContextKey.postgresService,
        );

        _healthService = HealthService(postgresService: postgresService);
      }

      final Request newRequest = request.addToContext(
        ContextKey.healthService,
        _healthService,
      );

      return await innerHandler(newRequest);
    };
