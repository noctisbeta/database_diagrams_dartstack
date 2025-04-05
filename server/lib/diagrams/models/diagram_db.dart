import 'package:common/abstractions/models.dart';
import 'package:common/annotations/throws.dart';
import 'package:meta/meta.dart';
import 'package:server/postgres/database_exception.dart';

@immutable
final class DiagramDB extends DataModel {
  const DiagramDB({
    required this.id,
    required this.name,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  @Throws([DBEbadSchema])
  factory DiagramDB.validatedFromMap(Map<String, dynamic> map) => switch (map) {
    {
      'id': final int id,
      'name': final String name,
      'user_id': final int userId,
      'created_at': final DateTime createdAt,
      'updated_at': final DateTime updatedAt,
    } =>
      DiagramDB(
        id: id,
        name: name,
        userId: userId,
        createdAt: createdAt,
        updatedAt: updatedAt,
      ),
    _ => throw const DBEbadSchema('Invalid shape for DiagramDB.'),
  };

  final int id;
  final String name;
  final int userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [id, name, userId, createdAt, updatedAt];

  @override
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'user_id': userId,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  @override
  DiagramDB copyWith({
    int? id,
    String? name,
    int? Function()? userIdFn,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DiagramDB(
    id: id ?? this.id,
    name: name ?? this.name,
    userId: userIdFn?.call() ?? userId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
