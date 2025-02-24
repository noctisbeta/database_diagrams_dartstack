import 'dart:io';

import 'package:database_diagrams_common/logger/logger.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

// Configure routes.
final _router =
    Router()
      ..get('/', _rootHandler)
      ..get('/echo/<message>', _echoHandler);

Response _rootHandler(Request req) => Response.ok('Hello, World!\n');

Response _echoHandler(Request request) {
  final String? message = request.params['message'];
  return Response.ok('$message\n');
}

void main(List<String> args) async {
  // Use any available host or container IP (usually `0.0.0.0`).
  final InternetAddress ip = InternetAddress.anyIPv4;

  // Configure a pipeline that logs requests.
  final Handler handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(_router.call);

  // For running in containers, we respect the PORT environment variable.
  final int port = int.parse(Platform.environment['PORT'] ?? '8080');
  final HttpServer server = await serve(handler, ip, port);
  LOG.d('Server listening on port ${server.port}');
}
