import 'package:server/postgres/implementations/postgres_service.dart';
import 'package:server/projects/abstractions/i_projects_handler.dart';
import 'package:server/projects/projects_data_source.dart';
import 'package:server/projects/projects_handler.dart';
import 'package:server/projects/projects_repository.dart';
import 'package:server/util/context_key.dart';
import 'package:server/util/request_extension.dart';
import 'package:shelf/shelf.dart';

IProjectsHandler? _projectsHandler;
Middleware projectsHandlerProvider() =>
    (Handler innerHandler) => (Request request) async {
      final ProjectsRepository projectsRepository = request.getFromContext(
        ContextKey.projectsRepository,
      );

      _projectsHandler ??= ProjectsHandler(
        projectsRepository: projectsRepository,
      );

      final Request newRequest = request.addToContext(
        ContextKey.projectsHandler,
        _projectsHandler,
      );

      return await innerHandler(newRequest);
    };

ProjectsRepository? _projectsRepository;
Middleware projectsRepositoryProvider() =>
    (Handler innerHandler) => (Request request) async {
      final ProjectsDataSource projectsDataSource = request.getFromContext(
        ContextKey.projectsDataSource,
      );

      _projectsRepository ??= ProjectsRepository(
        projectsDataSource: projectsDataSource,
      );

      final Request newRequest = request.addToContext(
        ContextKey.projectsRepository,
        _projectsRepository,
      );

      return await innerHandler(newRequest);
    };

ProjectsDataSource? _projectsDataSource;
Middleware projectsDataSourceProvider() =>
    (Handler innerHandler) => (Request request) async {
      final PostgresService postgresService = request.getFromContext(
        ContextKey.postgresService,
      );

      _projectsDataSource ??= ProjectsDataSource(postgresService);

      final Request newRequest = request.addToContext(
        ContextKey.projectsDataSource,
        _projectsDataSource,
      );

      return await innerHandler(newRequest);
    };
