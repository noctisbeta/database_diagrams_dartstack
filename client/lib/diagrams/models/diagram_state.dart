import 'package:common/er/diagrams/diagram_type.dart';
import 'package:common/er/entity.dart';
import 'package:common/er/entity_position.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:meta/meta.dart';

@immutable
class DiagramState {
  const DiagramState({
    required this.name,
    required this.entities,
    required this.entityPositions,
    required this.diagramType,
    this.id,
  });

  const DiagramState.initial()
    : id = null,
      name = 'Untitled Diagram',
      entities = const [],
      entityPositions = const [],
      diagramType = DiagramType.custom;

  factory DiagramState.validatedFromMap(Map<String, dynamic> map) =>
      switch (map) {
        {
          'id': final int? id,
          'name': final String name,
          'entities': final List<dynamic> entities,
          'entity_positions': final List<dynamic> entityPositions,
          'diagram_type': final String diagramType,
        } =>
          DiagramState(
            id: id,
            name: name,
            entities: entities.map((e) => Entity.validatedFromMap(e)).toList(),
            entityPositions:
                entityPositions
                    .map((e) => EntityPosition.validatedFromMap(e))
                    .toList(),
            diagramType: DiagramType.fromString(diagramType),
          ),
        _ => throw const BadMapShapeException('Bad map shape for DiagramState'),
      };

  final int? id;
  final String name;
  final List<Entity> entities;
  final List<EntityPosition> entityPositions;
  final DiagramType diagramType;

  DiagramState copyWith({
    int? Function()? idFn,
    String? name,
    List<Entity>? entities,
    List<EntityPosition>? entityPositions,
    DiagramType? diagramType,
  }) => DiagramState(
    id: idFn != null ? idFn() : id,
    name: name ?? this.name,
    entities: entities ?? this.entities,
    entityPositions: entityPositions ?? this.entityPositions,
    diagramType: diagramType ?? this.diagramType,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'entities': entities.map((e) => e.toMap()).toList(),
    'entity_positions': entityPositions.map((e) => e.toMap()).toList(),
    'diagram_type': diagramType.name,
  };

  // Helper to check if this is a new diagram or existing one
  bool get isNewDiagram => id == null;
}
