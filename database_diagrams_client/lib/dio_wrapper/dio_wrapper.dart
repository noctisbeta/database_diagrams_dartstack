import 'package:database_diagrams_client/dio_wrapper/configure_dio_web.dart';
import 'package:database_diagrams_client/dio_wrapper/jwt_interceptor.dart';
import 'package:database_diagrams_common/logger/logger.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

@immutable
final class DioWrapper {
  const DioWrapper._(this._dio);

  factory DioWrapper.unauthorized() {
    final dio = Dio(
        BaseOptions(
          baseUrl: 'http://localhost:8080/api/v1',
          validateStatus: (status) => status != null && status < 500,
        ),
      )
      ..interceptors.addAll([
        LogInterceptor(requestBody: true, responseBody: true),
        InterceptorsWrapper(onError: (e, handler) => handler.next(e)),
      ]);

    if (kDebugMode) {
      configureDioAdapter(dio);
    }

    return DioWrapper._(dio);
  }

  factory DioWrapper.authorized() {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080/api/v1'))
      ..interceptors.add(
        JwtInterceptor(
          secureStorage: const FlutterSecureStorage(),
          unauthorizedDio: DioWrapper.unauthorized(),
        ),
      );

    if (kDebugMode) {
      configureDioAdapter(dio);
    }

    return DioWrapper._(dio);
  }

  final Dio _dio;

  Future<Response> request(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final Response response = await _dio.request(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return response;
    } on DioException catch (e) {
      LOG.e('Error making request: $e');
      rethrow;
    }
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final Response response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );

      return response;
    } on DioException catch (e) {
      LOG.e('Error getting data: $e');
      rethrow;
    }
  }

  Future<Response> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final Response response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return response;
    } on DioException catch (e) {
      LOG.e('Error posting data: $e');
      rethrow;
    }
  }
}
