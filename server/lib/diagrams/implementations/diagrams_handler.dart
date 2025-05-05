import 'dart:io';

import 'package:common/annotations/throws.dart';
import 'package:common/er/diagrams/get_diagrams_request.dart';
import 'package:common/er/diagrams/get_diagrams_response.dart';
import 'package:common/er/diagrams/get_shared_diagram_response.dart';
import 'package:common/er/diagrams/save_diagram_request.dart';
import 'package:common/er/diagrams/save_diagram_response.dart';
import 'package:common/er/diagrams/share_diagram_request.dart';
import 'package:common/er/diagrams/share_diagram_response.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:meta/meta.dart';
import 'package:server/diagrams/abstractions/i_diagams_repository.dart';
import 'package:server/diagrams/abstractions/i_diagrams_handler.dart';
import 'package:server/postgres/database_exception.dart';
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

  @override
  Future<Response> updateDiagram(Request request, String id) async {
    try {
      final Map<String, dynamic> json = await request.json();

      final saveDiagramRequest = SaveDiagramRequest.validatedFromMap(json);

      final int userId = request.getUserId();
      final int diagramId = int.parse(id);

      final SaveDiagramResponse response = await _diagramsRepository
          .updateDiagram(saveDiagramRequest, userId, diagramId);

      return JsonResponse.ok(body: response.toMap());
    } on BadMapShapeException catch (e) {
      return JsonResponse.badRequest(body: 'Invalid request! $e');
    } on FormatException catch (e) {
      return JsonResponse.badRequest(body: 'Invalid request! $e');
    }
  }

  @override
  Future<Response> deleteDiagram(Request request, String id) async {
    try {
      final int userId = request.getUserId();
      final int diagramId = int.parse(id);

      await _diagramsRepository.deleteDiagram(diagramId, userId);

      return JsonResponse.ok(body: {'message': 'Diagram deleted successfully'});
    } on FormatException catch (e) {
      return JsonResponse.badRequest(body: 'Invalid diagram ID: $e');
    } on DatabaseException catch (e) {
      return JsonResponse.internalServerError(
        body: 'Failed to delete diagram: $e',
      );
    }
  }

  @override
  Future<Response> getSharedDiagram(Request request, String shortcode) async {
    try {
      final GetSharedDiagramResponse response = await _diagramsRepository
          .getSharedDiagram(shortcode);

      switch (response) {
        case GetSharedDiagramResponseSuccess():
          return JsonResponse.ok(body: response.toMap());
        case GetSharedDiagramResponseError():
          return JsonResponse.notFound(body: 'Diagram not found!');
      }
    } on BadMapShapeException catch (e) {
      return JsonResponse.badRequest(body: 'Invalid request! $e');
    } on FormatException catch (e) {
      return JsonResponse.badRequest(body: 'Invalid request! $e');
    }
  }

  @override
  Future<Response> shareDiagram(Request request) async {
    try {
      final Map<String, dynamic> json = await request.json();

      final shareDiagramRequest = ShareDiagramRequest.validatedFromMap(json);

      final int userId = request.getUserId();

      final ShareDiagramResponse response = await _diagramsRepository
          .shareDiagram(shareDiagramRequest, userId);

      switch (response) {
        case ShareDiagramResponseSuccess():
          return JsonResponse.ok(body: response.toMap());
        case ShareDiagramResponseError(:final errorType):
          switch (errorType) {
            case ShareDiagramError.userNotOwner:
              return JsonResponse.forbidden(
                body: 'You do not own this diagram',
              );
            case ShareDiagramError.notAuthorized:
              return JsonResponse.forbidden(
                body: 'You are not authorized to share this diagram',
              );
          }
      }
    } on BadMapShapeException catch (e) {
      return JsonResponse.badRequest(body: 'Invalid request! $e');
    } on FormatException catch (e) {
      return JsonResponse.badRequest(body: 'Invalid request! $e');
    }
  }
}
