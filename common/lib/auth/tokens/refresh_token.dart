extension type RefreshToken._(String value) {
  RefreshToken.fromRefreshTokenString(String refreshTokenString)
    : value = refreshTokenString;

  static const expirationDuration = Duration(days: 7);
}
