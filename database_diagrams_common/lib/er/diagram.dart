import 'package:database_diagrams_common/abstractions/models.dart';
import 'package:database_diagrams_common/er/entity.dart';
import 'package:database_diagrams_common/er/entity_position.dart';
import 'package:database_diagrams_common/er/relation.dart';
import 'package:database_diagrams_common/exceptions/bad_map_shape_exception.dart';
import 'package:meta/meta.dart';

@immutable
final class Diagram extends DataModel {
  const Diagram({
    required this.id,
    required this.name,
    required this.entities,
    required this.relations,
    required this.entityPositions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Diagram.validatedFromMap(Map<String, dynamic> map) => switch (map) {
    {
      'id': final String id,
      'name': final String name,
      'entities': final List<Map<String, dynamic>> entities,
      'relations': final List<Map<String, dynamic>> relations,
      'entity_positions': final List<Map<String, dynamic>> entityPositions,
      'created_at': final String createdAt,
      'updated_at': final String updatedAt,
    } =>
      Diagram(
        id: id,
        name: name,
        entities: entities.map(Entity.validatedFromMap).toList(),
        relations: relations.map(Relation.validatedFromMap).toList(),
        entityPositions:
            entityPositions.map(EntityPosition.validatedFromMap).toList(),
        createdAt: DateTime.parse(createdAt),
        updatedAt: DateTime.parse(updatedAt),
      ),
    _ => throw const BadMapShapeException('Bad map shape for Diagram'),
  };

  final String id;
  final String name;
  final List<Entity> entities;
  final List<Relation> relations;
  final List<EntityPosition> entityPositions;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'entities': entities.map((e) => e.toMap()).toList(),
    'relations': relations.map((r) => r.toMap()).toList(),
    'entity_positions': entityPositions.map((p) => p.toMap()).toList(),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  @override
  List<Object?> get props => [
    id,
    name,
    entities,
    relations,
    entityPositions,
    createdAt,
    updatedAt,
  ];

  @override
  Diagram copyWith({
    String? id,
    String? name,
    List<Entity>? entities,
    List<Relation>? relations,
    List<EntityPosition>? entityPositions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Diagram(
    id: id ?? this.id,
    name: name ?? this.name,
    entities: entities ?? this.entities,
    relations: relations ?? this.relations,
    entityPositions: entityPositions ?? this.entityPositions,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
