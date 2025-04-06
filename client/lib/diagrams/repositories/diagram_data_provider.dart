import 'package:client/dio_wrapper/jwt_interceptor.dart';
import 'package:client/dio_wrapper/jwt_refresh_exception.dart';
import 'package:common/abstractions/map_serializable.dart';
import 'package:common/er/diagrams/delete_diagram_response.dart';
import 'package:common/er/diagrams/get_diagrams_response.dart';
import 'package:common/er/diagrams/save_diagram_request.dart';
import 'package:common/er/diagrams/save_diagram_response.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

@immutable
final class DiagramDataProvider {
  DiagramDataProvider({required JwtInterceptor jwtInterceptor})
    : _jwtInterceptor = jwtInterceptor;

  final JwtInterceptor _jwtInterceptor;

  static const String basePath =
      kDebugMode
          ? 'http://localhost:8080/api/v1/diagrams'
          : 'https://api.diagrams.fractalfable.com/api/v1/diagrams';

  late final Dio _dio = Dio(BaseOptions(baseUrl: basePath))
    ..interceptors.addAll([
      LogInterceptor(requestBody: true, responseBody: true),
      _jwtInterceptor,
    ]);

  /// Generic method to handle API requests with consistent error handling
  Future<T> _makeRequest<T>({
    required String endpoint,
    required String method,
    required T Function(Map<String, dynamic>) successBuilder,
    required T Function(Map<String, dynamic>) errorBuilder,
    required T Function() onRefreshFailed,
    MapSerializable? data,
  }) async {
    try {
      late final Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await _dio.get(endpoint);
        case 'POST':
          response = await _dio.post(endpoint, data: data?.toMap());
        case 'PUT':
          response = await _dio.put(endpoint, data: data?.toMap());
        case 'DELETE':
          response = await _dio.delete(endpoint);
        default:
          throw ArgumentError('Unsupported HTTP method: $method');
      }

      return successBuilder(response.data);
    } on JWTRefreshException catch (_) {
      return onRefreshFailed();
    } on DioException catch (e) {
      return errorBuilder(e.response?.data ?? {});
    }
  }

  Future<SaveDiagramResponse> saveDiagram(SaveDiagramRequest request) {
    final String endpoint = request.id != null ? '/${request.id}' : '';
    final String method = request.id != null ? 'PUT' : 'POST';

    return _makeRequest(
      endpoint: endpoint,
      method: method,
      data: request,
      successBuilder: SaveDiagramResponseSuccess.validatedFromMap,
      errorBuilder: SaveDiagramResponseError.validatedFromMap,
      onRefreshFailed:
          () => const SaveDiagramResponseError(
            message: 'Failed to refresh token',
          ),
    );
  }

  Future<GetDiagramsResponse> getDiagrams() => _makeRequest(
    endpoint: '/',
    method: 'GET',
    successBuilder: GetDiagramsResponseSuccess.validatedFromMap,
    errorBuilder: GetDiagramsResponseError.validatedFromMap,
    onRefreshFailed:
        () =>
            const GetDiagramsResponseError(message: 'Failed to refresh token'),
  );

  Future<DeleteDiagramResponse> deleteDiagram(int diagramId) => _makeRequest(
    endpoint: '/$diagramId',
    method: 'DELETE',
    successBuilder: DeleteDiagramResponseSuccess.validatedFromMap,
    errorBuilder: DeleteDiagramResponseError.validatedFromMap,
    onRefreshFailed:
        () => const DeleteDiagramResponseError(
          message: 'Failed to refresh token',
        ),
  );
}
