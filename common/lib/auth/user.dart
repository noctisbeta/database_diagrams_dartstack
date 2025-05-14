import 'package:common/abstractions/models.dart';
import 'package:common/annotations/throws.dart';
import 'package:common/auth/tokens/jwtoken.dart';
import 'package:common/auth/tokens/refresh_token_wrapper.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:meta/meta.dart';

@immutable
final class User extends DataModel {
  const User({
    required this.email,
    required this.displayName,
    required this.jwToken,
    required this.refreshTokenWrapper,
  });

  @Throws([BadMapShapeException])
  factory User.validatedFromMap(Map<String, dynamic> map) => switch (map) {
    {
      'email': final String email,
      'display_name': final String displayName,
      'jw_token': final JWToken jwToken,
      'refresh_token_wrapper':
          final Map<String, dynamic> refreshTokenWrapperMap,
    } =>
      User(
        email: email,
        displayName: displayName,
        jwToken: jwToken,
        refreshTokenWrapper: RefreshTokenWrapper.validatedFromMap(
          refreshTokenWrapperMap,
        ),
      ),
    _ => throw const BadMapShapeException('Invalid map format for User'),
  };

  final String displayName;
  final String email;
  final JWToken jwToken;
  final RefreshTokenWrapper refreshTokenWrapper;

  @override
  Map<String, dynamic> toMap() => {
    'email': email,
    'display_name': displayName,
    'jw_token': jwToken,
    'refresh_token_wrapper': refreshTokenWrapper.toMap(),
  };

  @override
  List<Object?> get props => [email, displayName, jwToken, refreshTokenWrapper];

  @override
  User copyWith({
    String? email,
    String? displayName,
    JWToken? jwToken,
    RefreshTokenWrapper? refreshTokenWrapper,
  }) => User(
    email: email ?? this.email,
    displayName: displayName ?? this.displayName,
    jwToken: jwToken ?? this.jwToken,
    refreshTokenWrapper: refreshTokenWrapper ?? this.refreshTokenWrapper,
  );
}
