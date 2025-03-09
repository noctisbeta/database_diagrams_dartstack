import 'dart:io';

import 'package:server/projects/projects_handler.dart';
import 'package:server/util/context_key.dart';
import 'package:server/util/http_method.dart';
import 'package:server/util/request_extension.dart';
import 'package:shelf/shelf.dart';

Future<Response> projectsRouteHandler(Request request) async {
  final ProjectsHandler projectsHandler = request.getFromContext(
    ContextKey.projectsHandler,
  );

  final method = HttpMethod.fromString(request.method);

  return switch (method) {
    HttpMethod.get => await projectsHandler.getProjects(request),
    HttpMethod.post => await projectsHandler.createProject(request),
    _ => Response(HttpStatus.methodNotAllowed),
  };
}
