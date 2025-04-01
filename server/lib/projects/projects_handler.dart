import 'dart:io';

import 'package:common/annotations/throws.dart';
import 'package:common/er/projects/create_project_request.dart';
import 'package:common/er/projects/create_project_response.dart';
import 'package:common/er/projects/get_projects_response.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:server/projects/abstractions/i_projects_handler.dart';
import 'package:server/projects/projects_repository.dart';
import 'package:server/util/context_key.dart';
import 'package:server/util/json_response.dart';
import 'package:server/util/request_extension.dart';
import 'package:shelf/shelf.dart';

final class ProjectsHandler implements IProjectsHandler {
  const ProjectsHandler({required ProjectsRepository projectsRepository})
    : _projectsRepository = projectsRepository;

  final ProjectsRepository _projectsRepository;

  @override
  Future<Response> getProjects(Request request) async {
    try {
      final int userId = request.getFromContext(ContextKey.userId);

      final GetProjectsResponse response = await _projectsRepository
          .getProjects(userId);

      return switch (response) {
        GetProjectsResponseSuccess() => JsonResponse.ok(body: response.toMap()),
        GetProjectsResponseFailure() => JsonResponse.internalServerError(
          body: response.toMap(),
        ),
      };
    } on Exception catch (e) {
      return Response(
        HttpStatus.internalServerError,
        body: 'Failed to get projects: $e',
      );
    }
  }

  @override
  Future<Response> createProject(Request request) async {
    try {
      final bool isValidContentType = request.validateContentType(
        ContentType.json.mimeType,
      );

      if (!isValidContentType) {
        return Response(
          HttpStatus.badRequest,
          body: 'Invalid request! Content-Type must be ${ContentType.json}',
        );
      }

      final int userId = request.getFromContext(ContextKey.userId);

      @Throws([FormatException])
      final Map<String, dynamic> json = await request.json();

      @Throws([BadMapShapeException])
      final createProjectRequest = CreateProjectRequest.validatedFromMap(json);

      final CreateProjectResponse response = await _projectsRepository
          .createProject(request: createProjectRequest, userId: userId);

      return switch (response) {
        CreateProjectResponseSuccess() => JsonResponse.created(
          body: response.toMap(),
        ),
        CreateProjectResponseFailure() => JsonResponse.internalServerError(
          body: response.toMap(),
        ),
      };
    } on BadMapShapeException catch (e) {
      return Response(HttpStatus.badRequest, body: 'Invalid request! $e');
    } on FormatException catch (e) {
      return Response(HttpStatus.badRequest, body: 'Invalid request! $e');
    }
  }
}
