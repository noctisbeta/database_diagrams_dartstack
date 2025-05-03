import 'package:common/abstractions/models.dart';
import 'package:common/er/diagrams/diagram_type.dart';
import 'package:common/er/entity.dart';
import 'package:common/er/entity_position.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:meta/meta.dart';

@immutable
final class Diagram extends DataModel {
  const Diagram({
    required this.name,
    required this.entities,
    required this.entityPositions,
    required this.createdAt,
    required this.updatedAt,
    required this.diagramType,
    required this.id,
  });

  Diagram.initial(String name, DiagramType diagramType)
    : this(
        id: null,
        name: name,
        entities: const [],
        entityPositions: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        diagramType: diagramType,
      );

  factory Diagram.validatedFromMap(Map<String, dynamic> map) => switch (map) {
    {
      'id': final int? id,
      'name': final String name,
      'entities': final List<dynamic> entities,
      'entity_positions': final List<dynamic> entityPositions,
      'created_at': final String createdAt,
      'updated_at': final String updatedAt,
      'diagram_type': final String type,
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
        diagramType: DiagramType.fromString(type),
      ),
    {
      'id': final int? id,
      'name': final String name,
      'entities': final List<dynamic> entities,
      'entity_positions': final List<dynamic> entityPositions,
      'created_at': final DateTime createdAt,
      'updated_at': final DateTime updatedAt,
      'diagram_type': final String type,
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
        diagramType: DiagramType.fromString(type),
      ),
    _ => throw const BadMapShapeException('Bad map shape for Diagram.'),
  };

  final int? id;
  final String name;
  final List<Entity> entities;
  final List<EntityPosition> entityPositions;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DiagramType diagramType;

  @override
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'entities': entities.map((e) => e.toMap()).toList(),
    'entity_positions': entityPositions.map((p) => p.toMap()).toList(),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'diagram_type': diagramType.name,
  };

  @override
  List<Object?> get props => [
    id,
    name,
    entities,
    entityPositions,
    createdAt,
    updatedAt,
    diagramType,
  ];

  @override
  Diagram copyWith({
    int? id,
    String? name,
    List<Entity>? entities,
    List<EntityPosition>? entityPositions,
    DateTime? createdAt,
    DateTime? updatedAt,
    DiagramType? diagramType,
  }) => Diagram(
    id: id ?? this.id,
    name: name ?? this.name,
    entities: entities ?? this.entities,
    entityPositions: entityPositions ?? this.entityPositions,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    diagramType: diagramType ?? this.diagramType,
  );
}
