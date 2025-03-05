import 'dart:io';

import 'package:database_diagrams_server/auth/auth_handler.dart';
import 'package:database_diagrams_server/util/context_key.dart';
import 'package:database_diagrams_server/util/http_method.dart';
import 'package:database_diagrams_server/util/request_extension.dart';
import 'package:shelf/shelf.dart';

Future<Response> registerRouteHandler(Request request) async {
  final AuthHandler authHandler = request.getFromContext(
    ContextKey.authHandler,
  );

  final method = HttpMethod.fromString(request.method);

  return switch (method) {
    HttpMethod.post => await authHandler.register(request),
    _ => Response(HttpStatus.methodNotAllowed),
  };
}
