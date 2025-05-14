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
  static const String _emailKey = 'email';
  static const String _displayNameKey = 'display_name';
  static const String _jwTokenKey = 'jw_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _refreshTokenExpiresAtKey = 'refresh_token_expires_at';

  // Getters
  Future<String?> getEmail() => _storage.read(key: _emailKey);

  Future<String?> getDisplayName() => _storage.read(key: _displayNameKey);

  Future<JWToken?> getJWToken() async {
    final String? tokenString = await _storage.read(key: _jwTokenKey);
    if (tokenString == null) {
      return null;
    }
    return JWToken.fromJwtString(tokenString);
  }

  Future<User?> getUser() async {
    final String? email = await getEmail();
    final String? displayName = await getDisplayName();
    final JWToken? token = await getJWToken();
    final RefreshToken? refreshToken = await getRefreshToken();
    final DateTime? refreshTokenExpiresAt = await getRefreshTokenExpiresAt();

    if (displayName == null ||
        token == null ||
        refreshToken == null ||
        refreshTokenExpiresAt == null ||
        email == null) {
      return null;
    }

    return User(
      email: email,
      displayName: displayName,
      jwToken: token,
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
    required String email,
    required String displayName,
    required JWToken token,
    required RefreshTokenWrapper refreshTokenWrapper,
  }) async {
    await _storage.write(key: _emailKey, value: email);
    await _storage.write(key: _displayNameKey, value: displayName);
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
    await _storage.delete(key: _displayNameKey);
    await _storage.delete(key: _jwTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _refreshTokenExpiresAtKey);
  }
}
