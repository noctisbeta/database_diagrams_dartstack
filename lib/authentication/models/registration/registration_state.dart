import 'package:database_diagrams/authentication/models/auth_processing_state.dart';
import 'package:database_diagrams/authentication/models/registration/registration_data.dart';
import 'package:database_diagrams/authentication/models/registration/registration_data_errors.dart';

/// Registration state.
class RegistrationState {
  /// Default constructor.
  RegistrationState({
    required this.registrationData,
    required this.registrationDataErrors,
    required this.processingState,
  });

  /// Empty constructor.
  RegistrationState.empty()
      : registrationData = RegistrationData.empty(),
        registrationDataErrors = RegistrationDataErrors.empty(),
        processingState = AuthProcessingState.idle;

  /// Registration data.
  final RegistrationData registrationData;

  /// Registration data errors.
  final RegistrationDataErrors registrationDataErrors;

  /// Processing state.
  final AuthProcessingState processingState;

  /// True if the google sign in is loading.
  bool get googleInProgress =>
      processingState == AuthProcessingState.googleLoading;

  /// True if the state is loading.
  bool get isLoading =>
      processingState == AuthProcessingState.registrationLoading;

  /// Copy with method.
  RegistrationState copyWith({
    RegistrationData? registrationData,
    RegistrationDataErrors? registrationDataErrors,
    AuthProcessingState? processingState,
  }) {
    return RegistrationState(
      registrationData: registrationData ?? this.registrationData,
      registrationDataErrors:
          registrationDataErrors ?? this.registrationDataErrors,
      processingState: processingState ?? this.processingState,
    );
  }
}
