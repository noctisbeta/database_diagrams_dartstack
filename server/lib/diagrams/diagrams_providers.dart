import 'package:server/diagrams/abstractions/i_diagrams_handler.dart';
import 'package:server/diagrams/implementations/diagrams_data_source.dart';
import 'package:server/diagrams/implementations/diagrams_handler.dart';
import 'package:server/diagrams/implementations/diagrams_repository.dart';
import 'package:server/postgres/implementations/postgres_service.dart';
import 'package:server/util/context_key.dart';
import 'package:server/util/request_extension.dart';
import 'package:shelf/shelf.dart';

IDiagramsHandler? _diagramsHandler;
Middleware diagramsHandlerProvider() =>
    (Handler innerHandler) => (Request request) async {
      final DiagramsRepository diagramsRepository = request.getFromContext(
        ContextKey.diagramsRepository,
      );

      _diagramsHandler ??= DiagramsHandler(
        diagramsRepository: diagramsRepository,
      );

      final Request newRequest = request.addToContext(
        ContextKey.diagramsHandler,
        _diagramsHandler,
      );

      return await innerHandler(newRequest);
    };

DiagramsRepository? _diagramsRepository;
Middleware diagramsRepositoryProvider() =>
    (Handler innerHandler) => (Request request) async {
      final DiagramsDataSource diagramsDataSource = request.getFromContext(
        ContextKey.diagramsDataSource,
      );

      _diagramsRepository ??= DiagramsRepository(
        diagramsDataSource: diagramsDataSource,
      );

      final Request newRequest = request.addToContext(
        ContextKey.diagramsRepository,
        _diagramsRepository,
      );

      return await innerHandler(newRequest);
    };

DiagramsDataSource? _diagramsDataSource;
Middleware diagramsDataSourceProvider() =>
    (Handler innerHandler) => (Request request) async {
      final PostgresService postgresService = request.getFromContext(
        ContextKey.postgresService,
      );

      _diagramsDataSource ??= DiagramsDataSource(db: postgresService);

      final Request newRequest = request.addToContext(
        ContextKey.diagramsDataSource,
        _diagramsDataSource,
      );

      return await innerHandler(newRequest);
    };
