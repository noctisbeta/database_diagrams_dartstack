import 'package:database_diagrams_common/auth/login/login_request.dart';
import 'package:database_diagrams_common/auth/login/login_response.dart';
import 'package:database_diagrams_common/auth/register/register_request.dart';
import 'package:database_diagrams_common/auth/register/register_response.dart';
import 'package:database_diagrams_common/auth/tokens/refresh_token_request.dart';
import 'package:database_diagrams_common/auth/tokens/refresh_token_response.dart';

abstract interface class IAuthRepository {
  Future<RefreshTokenResponse> refreshToken(
    RefreshTokenRequest refreshTokenRequest,
  );

  Future<LoginResponse> login(LoginRequest loginRequest);

  Future<RegisterResponse> register(RegisterRequest registerRequest);
}
