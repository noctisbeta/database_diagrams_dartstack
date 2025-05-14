import 'dart:async';

import 'package:client/authentication/models/auth_state.dart';
import 'package:client/authentication/repositories/auth_repository.dart';
import 'package:common/auth/login/login_error.dart';
import 'package:common/auth/login/login_request.dart';
import 'package:common/auth/login/login_response.dart';
import 'package:common/auth/register/register_error.dart';
import 'package:common/auth/register/register_request.dart';
import 'package:common/auth/register/register_response.dart';
import 'package:common/auth/user.dart';
import 'package:common/logger/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AuthStateUnauthenticated()) {
    _stateSubscription = stream.listen(_handleStateChanges);
  }

  final AuthRepository _authRepository;

  Timer? _tokenMonitorTimer;
  StreamSubscription<AuthState>? _stateSubscription;

  void _handleStateChanges(AuthState state) {
    if (state is AuthStateAuthenticated) {
      _startTokenExpirationMonitor();
    } else {
      _stopTokenExpirationMonitor();
    }
  }

  void _startTokenExpirationMonitor() {
    _stopTokenExpirationMonitor();

    _tokenMonitorTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => unawaited(_checkTokenExpiration()),
    );
  }

  void _stopTokenExpirationMonitor() {
    if (_tokenMonitorTimer != null) {
      _tokenMonitorTimer?.cancel();
      _tokenMonitorTimer = null;
    }
  }

  Future<void> _checkTokenExpiration() async {
    if (state is! AuthStateAuthenticated) {
      return;
    }

    final ({DateTime jwtExpiresAt, DateTime refreshExpiresAt})? tokenInfo =
        await _authRepository.getTokenExpirations();

    if (tokenInfo == null) {
      return;
    }

    final now = DateTime.now();

    if (tokenInfo.refreshExpiresAt.isBefore(now)) {
      LOG.i('Refresh token expired, logging out user');
      await logout();
      return;
    }

    if (tokenInfo.jwtExpiresAt.isBefore(now)) {
      LOG.i('JWT token expired, attempting refresh');
      await refreshToken();
      return;
    }
  }

  Future<void> refreshToken() async {
    await _authRepository.refreshJWToken();
  }

  @override
  Future<void> close() {
    _stopTokenExpirationMonitor();
    _stateSubscription?.cancel();
    return super.close();
  }

  Future<void> checkAuth() async {
    emit(const AuthStateLoading());

    final bool isAuthenticated = await _authRepository.isAuthenticated();

    switch (isAuthenticated) {
      case true:
        final User? user = await _authRepository.getUser();

        final AuthState newState = switch (user) {
          User() => AuthStateAuthenticated(user: user),
          null => const AuthStateUnauthenticated(),
        };

        emit(newState);
      case false:
        emit(const AuthStateUnauthenticated());
    }
  }

  Future<void> logout() async {
    emit(const AuthStateLoading());
    await _authRepository.logout();
    emit(const AuthStateUnauthenticated());
  }

  Future<void> login(String email, String password) async {
    emit(const AuthStateLoading());

    final LoginRequest loginRequest = LoginRequest(
      email: email,
      password: password,
    );

    final LoginResponse loginResponse = await _authRepository.login(
      loginRequest,
    );

    switch (loginResponse) {
      case LoginResponseSuccess():
        emit(AuthStateAuthenticated(user: loginResponse.user));
      case LoginResponseError():
        switch (loginResponse.error) {
          case LoginError.wrongPassword:
            emit(const AuthStateErrorWrongPassword(message: 'Wrong password'));
          case LoginError.unknownLoginError:
            emit(const AuthStateErrorUnknown(message: 'Error logging in user'));
          case LoginError.userNotFound:
            emit(const AuthStateErrorUserNotFound(message: 'User not found'));
        }
    }
  }

  Future<void> register({
    required String email,
    required String displayName,
    required String password,
  }) async {
    emit(const AuthStateLoading());

    final RegisterRequest registerRequest = RegisterRequest(
      email: email,
      displayName: displayName,
      password: password,
    );

    final RegisterResponse registerResponse = await _authRepository.register(
      registerRequest,
    );

    switch (registerResponse) {
      case RegisterResponseSuccess():
        emit(AuthStateAuthenticated(user: registerResponse.user));
      case RegisterResponseError():
        switch (registerResponse.error) {
          case RegisterError.emailAlreadyTaken:
            emit(
              const AuthStateErrorEmailAlreadyTaken(
                message: 'Email already taken',
              ),
            );
          case RegisterError.unknownRegisterError:
            emit(
              const AuthStateErrorUnknown(message: 'Error registering user'),
            );
        }
    }
  }
}
