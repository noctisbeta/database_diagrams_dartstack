import 'dart:async';
import 'dart:io';

import 'package:client/dio_wrapper/jwt_refresh_exception.dart';
import 'package:common/auth/tokens/jwtoken.dart';
import 'package:common/auth/tokens/refresh_jwtoken_request.dart';
import 'package:common/auth/tokens/refresh_jwtoken_response.dart';
import 'package:common/auth/tokens/refresh_token.dart';
import 'package:common/auth/tokens/refresh_token_wrapper.dart';
import 'package:common/logger/logger.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class JwtInterceptor extends InterceptorsWrapper {
  JwtInterceptor({required FlutterSecureStorage secureStorage})
    : _storage = secureStorage;

  static const String refreshPath =
      kDebugMode
          ? 'http://localhost:8080/api/v1/auth/refresh'
          : 'https://api.diagrams.fractalfable.com/api/v1/auth/refresh';

  static final Dio _dio =
      Dio()
        ..interceptors.add(
          LogInterceptor(requestBody: true, responseBody: true),
        );

  final FlutterSecureStorage _storage;

  VoidCallback? onRefreshFailedCallback;

  // Expose the stream for listeners

  // Method to call when refresh fails
  void _emitRefreshFailed() {
    onRefreshFailedCallback?.call();
  }

  Future<JWToken?> _refreshToken() async {
    try {
      final String? refreshTokenString = await _storage.read(
        key: 'refresh_token',
      );
      final String? refreshTokenExpiresAtString = await _storage.read(
        key: 'refresh_token_expires_at',
      );

      // If tokens are missing, notify auth system and return null
      if (refreshTokenString == null || refreshTokenExpiresAtString == null) {
        LOG.e('Refresh token or expiration not found in secure storage');
        _emitRefreshFailed(); // Emit the refresh failed event
        return null;
      }

      final RefreshToken refreshToken = RefreshToken.fromRefreshTokenString(
        refreshTokenString,
      );
      final DateTime refreshTokenExpiresAt = DateTime.parse(
        refreshTokenExpiresAtString,
      );

      // If refresh token is expired, notify auth system and return null
      if (DateTime.now().isAfter(refreshTokenExpiresAt)) {
        _emitRefreshFailed(); // Emit the refresh failed event
        return null;
      }

      final RefreshJWTokenRequest refreshTokenRequest = RefreshJWTokenRequest(
        refreshToken: refreshToken,
      );

      try {
        final Response response = await _dio.post(
          refreshPath,
          data: refreshTokenRequest.toMap(),
        );

        final RefreshJWTokenResponseSuccess refreshTokenResponse =
            RefreshJWTokenResponseSuccess.validatedFromMap(
              response.data as Map<String, dynamic>,
            );

        final RefreshTokenWrapper refreshTokenWrapper =
            refreshTokenResponse.refreshTokenWrapper;

        final RefreshToken newRefreshToken = refreshTokenWrapper.refreshToken;
        final DateTime newRefreshTokenExpiresAt =
            refreshTokenWrapper.refreshTokenExpiresAt;
        final JWToken newJwToken = refreshTokenResponse.jwToken;

        await _storage.write(
          key: 'refresh_token',
          value: newRefreshToken.value,
        );
        await _storage.write(
          key: 'refresh_token_expires_at',
          value: newRefreshTokenExpiresAt.toIso8601String(),
        );
        await _storage.write(key: 'jw_token', value: newJwToken.value);

        return newJwToken;
      } on DioException catch (e) {
        LOG.e('Failed to refresh token: $e');
        _emitRefreshFailed(); // Emit the refresh failed event
        return null;
      }
    } on DioException catch (e) {
      LOG.e('Error in refresh token flow: $e');
      _emitRefreshFailed(); // Emit the refresh failed event
      return null;
    }
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final String? jwTokenString = await _storage.read(key: 'jw_token');

    if (jwTokenString == null) {
      throw Exception('Token not found in storage in JwtInterceptor');
    }

    final JWToken token = JWToken.fromJwtString(jwTokenString);

    options.headers['Authorization'] = 'Bearer $token';

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == HttpStatus.unauthorized) {
      try {
        final JWToken? newToken = await _refreshToken();

        // If token refresh failed, we need to handle session expiration
        if (newToken == null) {
          // Already emitted the event in _refreshToken
          LOG.d('Rejecting handler.');
          return handler.reject(
            JWTRefreshException(
              message: 'Token refresh failed',
              requestOptions: err.requestOptions,
            ),
          );
        }

        final RequestOptions requestOptions = err.requestOptions;
        requestOptions.headers['Authorization'] = 'Bearer $newToken';

        final String fullUrl = requestOptions.uri.toString();

        final Response response = await _dio.request(
          fullUrl,
          options: Options(
            method: requestOptions.method,
            headers: requestOptions.headers,
          ),
          data: requestOptions.data,
          queryParameters: requestOptions.queryParameters,
        );

        return handler.resolve(response);
      } on DioException catch (e) {
        _emitRefreshFailed();
        return handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: 'Authentication error: $e',
            type: DioExceptionType.badResponse,
          ),
        );
      }
    }
    return handler.next(err);
  }
}
