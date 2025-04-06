import 'package:client/authentication/repositories/auth_data_provider.dart';
import 'package:client/authentication/repositories/auth_secure_storage.dart';
import 'package:common/auth/login/login_request.dart';
import 'package:common/auth/login/login_response.dart';
import 'package:common/auth/register/register_request.dart';
import 'package:common/auth/register/register_response.dart';
import 'package:common/auth/tokens/jwtoken.dart';
import 'package:common/auth/tokens/refresh_jwtoken_request.dart';
import 'package:common/auth/tokens/refresh_jwtoken_response.dart';
import 'package:common/auth/tokens/refresh_token.dart';
import 'package:common/auth/tokens/refresh_token_wrapper.dart';
import 'package:common/auth/user.dart';
import 'package:common/logger/logger.dart';
import 'package:flutter/material.dart';

@immutable
final class AuthRepository {
  const AuthRepository({
    required AuthDataProvider authDataProvider,
    required AuthSecureStorage authSecureStorage,
  }) : _authDataProvider = authDataProvider,
       _authSecureStorage = authSecureStorage;

  final AuthDataProvider _authDataProvider;

  final AuthSecureStorage _authSecureStorage;

  Future<JWToken?> refreshJWToken() async {
    final RefreshToken? refreshToken =
        await _authSecureStorage.getRefreshToken();

    if (refreshToken == null) {
      LOG.e('Refresh token not found in secure storage');
      return null;
    }

    final RefreshJWTokenRequest refreshJWTokenRequest = RefreshJWTokenRequest(
      refreshToken: refreshToken,
    );

    final RefreshJWTokenResponse refreshJWTokenResponse =
        await _authDataProvider.refreshJWToken(refreshJWTokenRequest);

    switch (refreshJWTokenResponse) {
      case RefreshJWTokenResponseSuccess():
        await _authSecureStorage.saveTokens(
          jwToken: refreshJWTokenResponse.jwToken,
          refreshTokenWrapper: refreshJWTokenResponse.refreshTokenWrapper,
        );

        return refreshJWTokenResponse.jwToken;

      case RefreshJWTokenResponseError():
        LOG.e('Error refreshing token: ${refreshJWTokenResponse.error}');
        return null;
    }
  }

  Future<User> getUser() async {
    final String? username = await _authSecureStorage.getUsername();
    final JWToken? token = await _authSecureStorage.getJWToken();

    if (username == null || token == null) {
      throw Exception('Username or token not found in secure storage');
    }

    final RefreshToken? refreshToken =
        await _authSecureStorage.getRefreshToken();

    if (refreshToken == null) {
      throw Exception('Refresh token not found in secure storage');
    }

    final DateTime? refreshTokenExpiresAt =
        await _authSecureStorage.getRefreshTokenExpiresAt();

    if (refreshTokenExpiresAt == null) {
      throw Exception('Refresh token expires at not found in secure storage');
    }

    final RefreshTokenWrapper refreshTokenWrapper = RefreshTokenWrapper(
      refreshToken: refreshToken,
      refreshTokenExpiresAt: refreshTokenExpiresAt,
    );

    return User(
      username: username,
      token: token,
      refreshTokenWrapper: refreshTokenWrapper,
    );
  }

  Future<bool> isAuthenticated() async {
    final JWToken? token = await _authSecureStorage.getJWToken();

    if (token == null) {
      return false;
    }

    final bool isValid = token.isValid();

    switch (isValid) {
      case false:
        final JWToken? newJwToken = await refreshJWToken();
        return newJwToken != null;
      case true:
        return true;
    }
  }

  Future<void> logout() async {
    await _authSecureStorage.clearAuthData();
  }

  Future<LoginResponse> login(LoginRequest loginRequest) async {
    final LoginResponse loginResponse = await _authDataProvider.login(
      loginRequest,
    );

    switch (loginResponse) {
      case LoginResponseSuccess():
        await _authSecureStorage.saveAuthData(
          username: loginRequest.username,
          token: loginResponse.user.token,
          refreshTokenWrapper: loginResponse.user.refreshTokenWrapper,
        );
      case LoginResponseError():
    }

    return loginResponse;
  }

  Future<RegisterResponse> register(RegisterRequest registerRequest) async {
    final RegisterResponse registerResponse = await _authDataProvider.register(
      registerRequest,
    );

    switch (registerResponse) {
      case RegisterResponseSuccess():
        await _authSecureStorage.saveAuthData(
          username: registerRequest.username,
          token: registerResponse.user.token,
          refreshTokenWrapper: registerResponse.user.refreshTokenWrapper,
        );
      case RegisterResponseError():
    }

    return registerResponse;
  }

  Future<({DateTime jwtExpiresAt, DateTime refreshExpiresAt})?>
  getTokenExpirations() async {
    try {
      final JWToken? jwToken = await _authSecureStorage.getJWToken();
      final DateTime? refreshTokenExpiresAt =
          await _authSecureStorage.getRefreshTokenExpiresAt();

      if (jwToken == null || refreshTokenExpiresAt == null) {
        return null;
      }

      final DateTime jwtExpiresAt = jwToken.getExpiration();

      return (
        jwtExpiresAt: jwtExpiresAt,
        refreshExpiresAt: refreshTokenExpiresAt,
      );
    } on Exception catch (e) {
      LOG.e('Error getting token info: $e');
      return null;
    }
  }
}
