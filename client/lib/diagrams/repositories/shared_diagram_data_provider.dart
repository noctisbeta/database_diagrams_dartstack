import 'package:client/dio_wrapper/jwt_refresh_exception.dart';
import 'package:common/abstractions/map_serializable.dart';
import 'package:common/er/diagrams/get_shared_diagram_request.dart';
import 'package:common/er/diagrams/get_shared_diagram_response.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

@immutable
final class SharedDiagramDataProvider {
  SharedDiagramDataProvider();

  static const String basePath =
      kDebugMode
          ? 'http://localhost:8080/api/v1/shared-diagrams'
          : 'https://api.diagrams.fractalfable.com/api/v1/shared-diagrams';

  late final Dio _dio = Dio(BaseOptions(baseUrl: basePath))
    ..interceptors.addAll([
      LogInterceptor(requestBody: true, responseBody: true),
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

  Future<GetSharedDiagramResponse> getSharedDiagram(
    GetSharedDiagramRequest request,
  ) => _makeRequest(
    endpoint: '/${request.shortcode}',
    method: 'GET',
    successBuilder: GetSharedDiagramResponseSuccess.validatedFromMap,
    errorBuilder: GetSharedDiagramResponseError.validatedFromMap,
    onRefreshFailed:
        () => const GetSharedDiagramResponseError(
          message: 'Failed to refresh token',
        ),
  );
}
