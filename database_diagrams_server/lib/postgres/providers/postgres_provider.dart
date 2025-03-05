import 'package:database_diagrams_server/postgres/implementations/postgres_service.dart';
import 'package:database_diagrams_server/util/context_key.dart';
import 'package:database_diagrams_server/util/request_extension.dart';
import 'package:shelf/shelf.dart';

PostgresService? _postgresService;

Middleware postgresServiceProvider() =>
    (Handler innerHandler) => (Request request) async {
      _postgresService ??= await PostgresService.create();

      final Request newRequest = request.addToContext(
        ContextKey.postgresService,
        _postgresService,
      );

      return await innerHandler(newRequest);
    };
