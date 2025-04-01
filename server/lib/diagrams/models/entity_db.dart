import 'package:common/abstractions/models.dart';
import 'package:common/annotations/throws.dart';
import 'package:meta/meta.dart';
import 'package:server/postgres/database_exception.dart';

@immutable
final class EntityDB extends DataModel {
  const EntityDB({
    required this.id,
    required this.name,
    required this.diagramId,
    required this.createdAt,
    required this.updatedAt,
  });

  @Throws([DBEbadSchema])
  factory EntityDB.validatedFromMap(Map<String, dynamic> map) => switch (map) {
    {
      'id': final int id,
      'name': final String name,
      'diagram_id': final int diagramId,
      'created_at': final DateTime createdAt,
      'updated_at': final DateTime updatedAt,
    } =>
      EntityDB(
        id: id,
        name: name,
        diagramId: diagramId,
        createdAt: createdAt,
        updatedAt: updatedAt,
      ),
    _ => throw const DBEbadSchema('Invalid shape for EntityDB.'),
  };

  final int id;
  final String name;
  final int diagramId;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [id, name, diagramId, createdAt, updatedAt];

  @override
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'diagram_id': diagramId,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  @override
  EntityDB copyWith({
    int? id,
    String? name,
    int? diagramId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => EntityDB(
    id: id ?? this.id,
    name: name ?? this.name,
    diagramId: diagramId ?? this.diagramId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
