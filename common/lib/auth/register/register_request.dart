import 'package:common/abstractions/models.dart';
import 'package:common/annotations/throws.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:meta/meta.dart';

@immutable
final class RegisterRequest extends RequestDTO {
  const RegisterRequest({
    required this.email,
    required this.displayName,
    required this.password,
  });

  @Throws([BadMapShapeException])
  factory RegisterRequest.validatedFromMap(
    Map<String, dynamic> map,
  ) => switch (map) {
    {
      'email': final String email,
      'displayName': final String displayName,
      'password': final String password,
    } =>
      RegisterRequest(
        email: email,
        displayName: displayName,
        password: password,
      ),
    _ =>
      throw const BadMapShapeException('Invalid map shape for RegisterRequest'),
  };

  final String email;
  final String displayName;
  final String password;

  @override
  Map<String, dynamic> toMap() => {
    'email': email,
    'displayName': displayName,
    'password': password,
  };
  @override
  List<Object?> get props => [email, displayName, password];

  @override
  RegisterRequest copyWith({
    String? email,
    String? displayName,
    String? password,
  }) => RegisterRequest(
    email: email ?? this.email,
    displayName: displayName ?? this.displayName,
    password: password ?? this.password,
  );
}
