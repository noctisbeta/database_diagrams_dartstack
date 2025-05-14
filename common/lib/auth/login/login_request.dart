import 'package:common/abstractions/models.dart';
import 'package:common/annotations/throws.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:meta/meta.dart';

@immutable
final class LoginRequest extends RequestDTO {
  const LoginRequest({required this.email, required this.password});

  @Throws([BadMapShapeException])
  factory LoginRequest.validatedFromMap(
    Map<String, dynamic> map,
  ) => switch (map) {
    {'email': final String email, 'password': final String password} =>
      LoginRequest(email: email, password: password),
    _ => throw const BadMapShapeException('Invalid map shape for LoginRequest'),
  };

  final String email;
  final String password;

  @override
  Map<String, dynamic> toMap() => {'email': email, 'password': password};

  @override
  List<Object?> get props => [email, password];

  @override
  LoginRequest copyWith({String? email, String? password}) => LoginRequest(
    email: email ?? this.email,
    password: password ?? this.password,
  );
}
