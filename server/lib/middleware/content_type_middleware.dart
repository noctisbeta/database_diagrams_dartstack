import 'dart:io';

import 'package:server/util/request_extension.dart';
import 'package:shelf/shelf.dart';

/// Middleware that enforces JSON content type for non-GET requests
Middleware enforceJsonContentType() =>
    (Handler innerHandler) => (Request request) async {
      // Skip content type validation for GET requests
      if (request.method == 'GET' ||
          request.method == 'HEAD' ||
          request.method == 'OPTIONS' ||
          request.method == 'TRACE' ||
          request.method == 'CONNECT' ||
          request.method == 'DELETE') {
        return await innerHandler(request);
      }

      final bool isValidContentType = request.validateContentType(
        ContentType.json.mimeType,
      );

      if (!isValidContentType) {
        return Response(
          HttpStatus.badRequest,
          body:
              'Invalid request! Content-Type must be '
              '${ContentType.json.mimeType}',
        );
      }

      return await innerHandler(request);
    };
