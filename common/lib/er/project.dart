import 'package:common/abstractions/models.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:meta/meta.dart';

@immutable
final class Project extends DataModel {
  const Project({
    required this.id,
    required this.name,
    required this.description,
    required this.diagramIds,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Project.validatedFromMap(Map<String, dynamic> map) => switch (map) {
    {
      'id': final String id,
      'name': final String name,
      'description': final String description,
      'diagram_ids': final List<dynamic> diagramIds,
      'created_at': final String createdAt,
      'updated_at': final String updatedAt,
    } =>
      Project(
        id: id,
        name: name,
        description: description,
        diagramIds: diagramIds.cast<String>(),
        createdAt: DateTime.parse(createdAt),
        updatedAt: DateTime.parse(updatedAt),
      ),
    _ => throw const BadMapShapeException('Bad map shape for Project'),
  };

  final String id;
  final String name;
  final String description;
  final List<String> diagramIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'description': description,
    'diagram_ids': diagramIds,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    diagramIds,
    createdAt,
    updatedAt,
  ];

  @override
  Project copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? diagramIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Project(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    diagramIds: diagramIds ?? this.diagramIds,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
