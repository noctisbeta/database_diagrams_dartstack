import 'package:common/abstractions/models.dart';
import 'package:common/exceptions/throws.dart';
import 'package:meta/meta.dart';
import 'package:server/postgres/exceptions/database_exception.dart';

@immutable
final class DiagramDB extends DataModel {
  const DiagramDB({
    required this.id,
    required this.name,
    required this.projectId,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  @Throws([DBEbadSchema])
  factory DiagramDB.validatedFromMap(Map<String, dynamic> map) => switch (map) {
    {
      'id': final int id,
      'name': final String name,
      'project_id': final int projectId,
      'created_by': final int createdBy,
      'created_at': final DateTime createdAt,
      'updated_at': final DateTime updatedAt,
    } =>
      DiagramDB(
        id: id,
        name: name,
        projectId: projectId,
        createdBy: createdBy,
        createdAt: createdAt,
        updatedAt: updatedAt,
      ),
    _ => throw const DBEbadSchema('Invalid shape for DiagramDB.'),
  };

  final int id;
  final String name;
  final int projectId;
  final int createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
    id,
    name,
    projectId,
    createdBy,
    createdAt,
    updatedAt,
  ];

  @override
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'project_id': projectId,
    'created_by': createdBy,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  @override
  DiagramDB copyWith({
    int? id,
    String? name,
    int? projectId,
    int? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DiagramDB(
    id: id ?? this.id,
    name: name ?? this.name,
    projectId: projectId ?? this.projectId,
    createdBy: createdBy ?? this.createdBy,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
