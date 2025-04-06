import 'package:common/auth/tokens/jwtoken.dart';
import 'package:common/auth/tokens/refresh_token.dart';
import 'package:common/auth/tokens/refresh_token_wrapper.dart';
import 'package:common/auth/user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthSecureStorage {
  const AuthSecureStorage({required FlutterSecureStorage storage})
    : _storage = storage;

  final FlutterSecureStorage _storage;

  // Storage keys
  static const String _usernameKey = 'username';
  static const String _jwTokenKey = 'jw_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _refreshTokenExpiresAtKey = 'refresh_token_expires_at';

  // Getters
  Future<String?> getUsername() => _storage.read(key: _usernameKey);

  Future<JWToken?> getJWToken() async {
    final String? tokenString = await _storage.read(key: _jwTokenKey);
    if (tokenString == null) {
      return null;
    }
    return JWToken.fromJwtString(tokenString);
  }

  Future<User?> getUser() async {
    final String? username = await getUsername();
    final JWToken? token = await getJWToken();
    final RefreshToken? refreshToken = await getRefreshToken();
    final DateTime? refreshTokenExpiresAt = await getRefreshTokenExpiresAt();

    if (username == null ||
        token == null ||
        refreshToken == null ||
        refreshTokenExpiresAt == null) {
      return null;
    }

    return User(
      username: username,
      token: token,
      refreshTokenWrapper: RefreshTokenWrapper(
        refreshToken: refreshToken,
        refreshTokenExpiresAt: refreshTokenExpiresAt,
      ),
    );
  }

  Future<RefreshToken?> getRefreshToken() async {
    final String? tokenString = await _storage.read(key: _refreshTokenKey);
    if (tokenString == null) {
      return null;
    }
    return RefreshToken.fromRefreshTokenString(tokenString);
  }

  Future<DateTime?> getRefreshTokenExpiresAt() async {
    final String? expiresAtString = await _storage.read(
      key: _refreshTokenExpiresAtKey,
    );
    if (expiresAtString == null) {
      return null;
    }
    return DateTime.parse(expiresAtString);
  }

  // Save methods
  Future<void> saveAuthData({
    required String username,
    required JWToken token,
    required RefreshTokenWrapper refreshTokenWrapper,
  }) async {
    await _storage.write(key: _usernameKey, value: username);
    await _storage.write(key: _jwTokenKey, value: token.value);
    await _storage.write(
      key: _refreshTokenKey,
      value: refreshTokenWrapper.refreshToken.value,
    );
    await _storage.write(
      key: _refreshTokenExpiresAtKey,
      value: refreshTokenWrapper.refreshTokenExpiresAt.toIso8601String(),
    );
  }

  // Update methods
  Future<void> saveTokens({
    required JWToken jwToken,
    required RefreshTokenWrapper refreshTokenWrapper,
  }) async {
    await _storage.write(key: _jwTokenKey, value: jwToken.value);
    await _storage.write(
      key: _refreshTokenKey,
      value: refreshTokenWrapper.refreshToken.value,
    );
    await _storage.write(
      key: _refreshTokenExpiresAtKey,
      value: refreshTokenWrapper.refreshTokenExpiresAt.toIso8601String(),
    );
  }

  // Delete methods
  Future<void> clearAuthData() async {
    await _storage.delete(key: _usernameKey);
    await _storage.delete(key: _jwTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _refreshTokenExpiresAtKey);
  }
}
