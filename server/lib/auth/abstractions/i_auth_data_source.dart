import 'package:common/auth/tokens/refresh_token.dart';
import 'package:server/auth/models/refresh_token_db.dart';
import 'package:server/auth/models/user_db.dart';

abstract interface class IAuthDataSource {
  Future<RefreshTokenDB> getRefreshToken(RefreshToken token);
  Future<RefreshTokenDB> storeRefreshToken({
    required int userId,
    required String? userAgent,
    required String? ipAddress,
  });
  Future<UserDB> login(String email);
  Future<UserDB> register(
    String email,
    String displayName,
    String hashedPassword,
    String salt,
  );
  Future<bool> isUniqueEmail(String email);
  Future<RefreshTokenDB> rotateRefreshToken({
    required RefreshToken oldToken,
    required int userId,
    String? ipAddress,
    String? userAgent,
  });
  Future<void> revokeAllUserTokens(int userId, {String? reason});
}
