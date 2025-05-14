import 'package:common/abstractions/models.dart';
import 'package:common/annotations/throws.dart';
import 'package:meta/meta.dart';
import 'package:server/postgres/database_exception.dart';

@immutable
final class UserDB extends DataModel {
  const UserDB({
    required this.id,
    required this.email,
    required this.displayName,
    required this.hashedPassword,
    required this.salt,
    required this.createdAt,
    required this.updatedAt,
  });

  @Throws([DBEbadSchema])
  factory UserDB.validatedFromMap(Map<String, dynamic> map) => switch (map) {
    {
      'id': final int id,
      'email': final String email,
      'display_name': final String displayName,
      'hashed_password': final String hashedPassword,
      'salt': final String salt,
      'created_at': final DateTime createdAt,
      'updated_at': final DateTime updatedAt,
    } =>
      UserDB(
        id: id,
        email: email,
        displayName: displayName,
        hashedPassword: hashedPassword,
        salt: salt,
        createdAt: createdAt,
        updatedAt: updatedAt,
      ),
    _ => throw const DBEbadSchema('Invalid shape for UserDB.'),
  };

  final int id;
  final String email;
  final String displayName;
  final String hashedPassword;
  final String salt;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
    id,
    email,
    displayName,
    hashedPassword,
    salt,
    createdAt,
    updatedAt,
  ];

  @override
  bool get stringify => true;

  @override
  Map<String, dynamic> toMap() => {
    'id': id,
    'email': email,
    'display_name': displayName,
    'hashed_password': hashedPassword,
    'salt': salt,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  @override
  UserDB copyWith({
    int? id,
    String? email,
    String? displayName,
    String? hashedPassword,
    String? salt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => UserDB(
    id: id ?? this.id,
    email: email ?? this.email,
    displayName: displayName ?? this.displayName,
    hashedPassword: hashedPassword ?? this.hashedPassword,
    salt: salt ?? this.salt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
