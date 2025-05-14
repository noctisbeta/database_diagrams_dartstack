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

  Future<User?> getUser() async {
    final User? user = await _authSecureStorage.getUser();
    return user;
  }

  Future<bool> isAuthenticated() async {
    final JWToken? token = await _authSecureStorage.getJWToken();

    return token?.isValid() ?? false;
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
        final User user = loginResponse.user;
        await _authSecureStorage.saveAuthData(
          email: user.email,
          displayName: user.displayName,
          token: user.jwToken,
          refreshTokenWrapper: user.refreshTokenWrapper,
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
        final User user = registerResponse.user;
        await _authSecureStorage.saveAuthData(
          email: user.email,
          displayName: user.displayName,
          token: user.jwToken,
          refreshTokenWrapper: user.refreshTokenWrapper,
        );
      case RegisterResponseError():
    }

    return registerResponse;
  }

  Future<({DateTime jwtExpiresAt, DateTime refreshExpiresAt})?>
  getTokenExpirations() async {
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
  }
}
