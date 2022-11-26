import 'package:database_diagrams/authentication/models/auth_processing_state.dart';
import 'package:database_diagrams/authentication/models/login/login_data.dart';
import 'package:database_diagrams/authentication/models/login/login_data_errors.dart';

/// Login state.
class LoginState {
  /// Default constructor.
  LoginState({
    required this.loginData,
    required this.loginDataErrors,
    required this.processingState,
  });

  /// Empty constructor.
  LoginState.empty()
      : loginData = LoginData.empty(),
        loginDataErrors = LoginDataErrors.empty(),
        processingState = AuthProcessingState.idle;

  /// Registration data.
  final LoginData loginData;

  /// Registration data errors.
  final LoginDataErrors loginDataErrors;

  /// Processing state.
  final AuthProcessingState processingState;

  /// True if the google sign in is loading.
  bool get googleInProgress =>
      processingState == AuthProcessingState.googleLoading;

  /// True if the login is loading.
  bool get isLoading => processingState == AuthProcessingState.loginLoading;

  /// Copy with method.
  LoginState copyWith({
    LoginData? loginData,
    LoginDataErrors? loginDataErrors,
    AuthProcessingState? processingState,
  }) {
    return LoginState(
      loginData: loginData ?? this.loginData,
      loginDataErrors: loginDataErrors ?? this.loginDataErrors,
      processingState: processingState ?? this.processingState,
    );
  }
}
