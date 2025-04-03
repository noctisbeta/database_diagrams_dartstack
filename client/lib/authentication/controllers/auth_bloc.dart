import 'dart:async';

import 'package:client/authentication/models/auth_event.dart';
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

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AuthStateUnauthenticated()) {
    on<AuthEvent>(
      (event, emit) async => switch (event) {
        AuthEventLogin() => await login(event, emit),
        AuthEventRegister() => await register(event, emit),
        AuthEventLogout() => await logout(event, emit),
        AuthEventCheckAuth() => await checkAuth(event, emit),
        AuthEventTokenExpired() => await handleTokenExpired(event, emit),
        AuthEventRefreshToken() => await refreshToken(event, emit),
      },
    );

    // Store the subscription so we can cancel it later
    // _stateSubscription = stream.listen(_handleStateChanges);

    // Initial check if we're already authenticated
    add(const AuthEventCheckAuth());
  }

  final AuthRepository _authRepository;
  Timer? _tokenMonitorTimer;
  StreamSubscription<AuthState>? _stateSubscription;

  // Handle state changes to manage token monitor
  void _handleStateChanges(AuthState state) {
    if (state is AuthStateAuthenticated) {
      // User became authenticated, ensure timer is running
      _startTokenExpirationMonitor();
    } else if (state is AuthStateUnauthenticated ||
        state is AuthStateSessionExpired) {
      // User is not authenticated, ensure timer is stopped
      _stopTokenExpirationMonitor();
    }
  }

  void _startTokenExpirationMonitor() {
    // Cancel any existing timer first
    _stopTokenExpirationMonitor();

    LOG.i('Starting token expiration monitor');

    // Check token status every second
    _tokenMonitorTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => unawaited(_checkTokenExpiration()),
    );
  }

  void _stopTokenExpirationMonitor() {
    if (_tokenMonitorTimer != null) {
      LOG.i('Stopping token expiration monitor');
      _tokenMonitorTimer?.cancel();
      _tokenMonitorTimer = null;
    }
  }

  Future<void> _checkTokenExpiration() async {
    // Skip check if we're already in an unauthenticated state
    if (state is AuthStateUnauthenticated) {
      return;
    }

    try {
      final ({DateTime jwtExpiresAt, DateTime refreshExpiresAt})? tokenInfo =
          await _authRepository.getTokenExpirations();

      if (tokenInfo == null) {
        return;
      }

      final now = DateTime.now();

      // Check refresh token expiration first
      if (tokenInfo.refreshExpiresAt.isBefore(now)) {
        LOG.i('Refresh token expired, logging out user');
        add(const AuthEventTokenExpired());
        return;
      }

      // If JWT is already expired but refresh token is valid, try refresh
      if (tokenInfo.jwtExpiresAt.isBefore(now)) {
        LOG.i('JWT token expired, attempting refresh');
        add(const AuthEventRefreshToken());
        return;
      }
    } on Exception catch (e) {
      LOG.e('Error checking token expiration: $e');
    }
  }

  // Add this method to handle token expiration
  Future<void> handleTokenExpired(
    AuthEventTokenExpired event,
    Emitter<AuthState> emit,
  ) async {
    LOG.i('Token expired, logging out user');

    // First emit a special state indicating session expiry
    emit(
      const AuthStateSessionExpired(
        message: 'Your session has expired. Please log in again.',
      ),
    );

    // Then perform logout
    try {
      await _authRepository.logout();
      emit(const AuthStateUnauthenticated());
    } on Exception catch (e) {
      LOG.e('Error during automatic logout: $e');
      // Still mark as unauthenticated even if logout fails
      emit(const AuthStateUnauthenticated());
    }
  }

  // Add this method to handle refreshing the token
  Future<void> refreshToken(
    AuthEventRefreshToken event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.refreshJWToken();
    } on Exception catch (e) {
      LOG.e('Error refreshing token: $e');
      add(const AuthEventTokenExpired());
    }
  }

  @override
  Future<void> close() {
    _stopTokenExpirationMonitor();
    _stateSubscription?.cancel(); // Cancel the subscription when bloc is closed
    return super.close();
  }

  Future<void> checkAuth(
    AuthEventCheckAuth event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthStateLoading());

    final bool isAuthenticated = await _authRepository.isAuthenticated();

    if (isAuthenticated) {
      final User user = await _authRepository.getUser();
      emit(AuthStateAuthenticated(user: user));
      // Timer will be started by state change listener
    } else {
      emit(const AuthStateUnauthenticated());
      // Timer will be stopped by state change listener
    }
  }

  Future<void> logout(AuthEventLogout event, Emitter<AuthState> emit) async {
    emit(const AuthStateLoading());
    try {
      await _authRepository.logout();
      emit(const AuthStateUnauthenticated());
      // Timer will be stopped by state change listener
    } on Exception catch (e) {
      LOG.e('Unknown logout error: $e');
      emit(const AuthStateErrorUnknown(message: 'Error logging out'));
    }
  }

  Future<void> login(AuthEventLogin event, Emitter<AuthState> emit) async {
    emit(const AuthStateLoading());

    final LoginRequest loginRequest = LoginRequest(
      username: event.username,
      password: event.password,
    );

    final LoginResponse loginResponse = await _authRepository.login(
      loginRequest,
    );

    switch (loginResponse) {
      case LoginResponseSuccess():
        emit(AuthStateAuthenticated(user: loginResponse.user));
      // Timer will be started by state change listener
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

  Future<void> register(
    AuthEventRegister event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthStateLoading());

    final RegisterRequest registerRequest = RegisterRequest(
      username: event.username,
      password: event.password,
    );

    final RegisterResponse registerResponse = await _authRepository.register(
      registerRequest,
    );

    switch (registerResponse) {
      case RegisterResponseSuccess():
        emit(AuthStateAuthenticated(user: registerResponse.user));
      // Timer will be started by state change listener
      case RegisterResponseError():
        switch (registerResponse.error) {
          case RegisterError.usernameAlreadyExists:
            emit(
              const AuthStateErrorUsernameAlreadyExists(
                message: 'Username already taken',
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
