import 'dart:io';

import 'package:common/annotations/throws.dart';
import 'package:common/er/diagrams/get_diagrams_request.dart';
import 'package:common/er/diagrams/get_diagrams_response.dart';
import 'package:common/er/diagrams/save_diagram_request.dart';
import 'package:common/er/diagrams/save_diagram_response.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:meta/meta.dart';
import 'package:server/diagrams/abstractions/i_diagams_repository.dart';
import 'package:server/diagrams/abstractions/i_diagrams_handler.dart';
import 'package:server/util/json_response.dart';
import 'package:server/util/request_extension.dart';
import 'package:shelf/shelf.dart';

@immutable
final class DiagramsHandler implements IDiagramsHandler {
  const DiagramsHandler({required IDiagramsRepository diagramsRepository})
    : _diagramsRepository = diagramsRepository;

  final IDiagramsRepository _diagramsRepository;

  @override
  Future<Response> getDiagrams(Request request) async {
    try {
      @Throws([BadMapShapeException])
      final getDiagramsRequest = GetDiagramsRequest.validatedFromMap();

      final int userId = request.getUserId();

      final GetDiagramsResponse response = await _diagramsRepository
          .getDiagrams(getDiagramsRequest, userId);

      return JsonResponse.ok(body: response.toMap());
    } on BadMapShapeException catch (e) {
      return JsonResponse.badRequest(body: 'Invalid request! $e');
    } on FormatException catch (e) {
      return JsonResponse.badRequest(body: 'Invalid request! $e');
    }
  }

  @override
  Future<Response> saveDiagram(Request request) async {
    try {
      final bool isValidContentType = request.validateContentType(
        ContentType.json.mimeType,
      );

      if (!isValidContentType) {
        return Future.value(
          Response(
            HttpStatus.badRequest,
            body: 'Invalid request! Content-Type must be ${ContentType.json}',
          ),
        );
      }

      final Map<String, dynamic> json = await request.json();

      final saveDiagramRequest = SaveDiagramRequest.validatedFromMap(json);

      final int userId = request.getUserId();

      final SaveDiagramResponse response = await _diagramsRepository
          .saveDiagram(saveDiagramRequest, userId);

      return JsonResponse.created(body: response.toMap());
    } on BadMapShapeException catch (e) {
      return Future.value(
        Response(HttpStatus.badRequest, body: 'Invalid request! $e'),
      );
    } on FormatException catch (e) {
      return JsonResponse.badRequest(body: 'Invalid request! $e');
    }
  }
}
