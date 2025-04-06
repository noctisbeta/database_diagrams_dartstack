import 'package:common/abstractions/map_serializable.dart';
import 'package:common/auth/login/login_request.dart';
import 'package:common/auth/login/login_response.dart';
import 'package:common/auth/register/register_request.dart';
import 'package:common/auth/register/register_response.dart';
import 'package:common/auth/tokens/refresh_jwtoken_request.dart';
import 'package:common/auth/tokens/refresh_jwtoken_response.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

@immutable
final class AuthDataProvider {
  const AuthDataProvider();

  static const String basePath =
      kDebugMode
          ? 'http://localhost:8080/api/v1/auth'
          : 'https://api.diagrams.fractalfable.com/api/v1/auth';

  static final Dio _dio = Dio(BaseOptions(baseUrl: basePath))
    ..interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

  Future<T> _makeRequest<T>({
    required String endpoint,
    required MapSerializable data,
    required T Function(Map<String, dynamic>) successBuilder,
    required T Function(Map<String, dynamic>) errorBuilder,
  }) async {
    try {
      final Response response = await _dio.post(endpoint, data: data.toMap());

      return successBuilder(response.data);
    } on DioException catch (e) {
      return errorBuilder(e.response?.data ?? {});
    }
  }

  Future<LoginResponse> login(LoginRequest request) => _makeRequest(
    endpoint: '/login',
    data: request,
    successBuilder: LoginResponseSuccess.validatedFromMap,
    errorBuilder: LoginResponseError.validatedFromMap,
  );

  Future<RegisterResponse> register(RegisterRequest request) => _makeRequest(
    endpoint: '/register',
    data: request,
    successBuilder: RegisterResponseSuccess.validatedFromMap,
    errorBuilder: RegisterResponseError.validatedFromMap,
  );

  Future<RefreshJWTokenResponse> refreshJWToken(
    RefreshJWTokenRequest request,
  ) => _makeRequest(
    endpoint: '/refresh',
    data: request,
    successBuilder: RefreshJWTokenResponseSuccess.validatedFromMap,
    errorBuilder: RefreshJWTokenResponseError.validatedFromMap,
  );
}
