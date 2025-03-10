import 'package:common/abstractions/models.dart';
import 'package:common/er/entity.dart';
import 'package:common/er/entity_position.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:meta/meta.dart';

@immutable
final class Diagram extends DataModel {
  const Diagram({
    required this.id,
    required this.name,
    required this.entities,
    required this.entityPositions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Diagram.validatedFromMap(Map<String, dynamic> map) => switch (map) {
    {
      'id': final String id,
      'name': final String name,
      'entities': final List<dynamic> entities,
      'entity_positions': final List<dynamic> entityPositions,
      'created_at': final String createdAt,
      'updated_at': final String updatedAt,
    } =>
      Diagram(
        id: id,
        name: name,
        entities:
            entities
                .map((e) => Entity.validatedFromMap(e as Map<String, dynamic>))
                .toList(),
        entityPositions:
            entityPositions
                .map(
                  (p) => EntityPosition.validatedFromMap(
                    p as Map<String, dynamic>,
                  ),
                )
                .toList(),
        createdAt: DateTime.parse(createdAt),
        updatedAt: DateTime.parse(updatedAt),
      ),
    {
      'id': final String id,
      'name': final String name,
      'entities': final List<dynamic> entities,
      'entity_positions': final List<dynamic> entityPositions,
      'created_at': final DateTime createdAt,
      'updated_at': final DateTime updatedAt,
    } =>
      Diagram(
        id: id,
        name: name,
        entities:
            entities
                .map((e) => Entity.validatedFromMap(e as Map<String, dynamic>))
                .toList(),
        entityPositions:
            entityPositions
                .map(
                  (p) => EntityPosition.validatedFromMap(
                    p as Map<String, dynamic>,
                  ),
                )
                .toList(),
        createdAt: createdAt,
        updatedAt: updatedAt,
      ),
    _ => throw const BadMapShapeException('Bad map shape for Diagram'),
  };

  final String id;
  final String name;
  final List<Entity> entities;
  final List<EntityPosition> entityPositions;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'entities': entities.map((e) => e.toMap()).toList(),
    'entity_positions': entityPositions.map((p) => p.toMap()).toList(),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  @override
  List<Object?> get props => [
    id,
    name,
    entities,
    entityPositions,
    createdAt,
    updatedAt,
  ];

  @override
  Diagram copyWith({
    String? id,
    String? name,
    List<Entity>? entities,
    List<EntityPosition>? entityPositions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Diagram(
    id: id ?? this.id,
    name: name ?? this.name,
    entities: entities ?? this.entities,
    entityPositions: entityPositions ?? this.entityPositions,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
