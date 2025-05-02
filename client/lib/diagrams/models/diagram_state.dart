import 'package:common/er/diagrams/diagram_type.dart';
import 'package:common/er/entity.dart';
import 'package:common/er/entity_position.dart';
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

  // Helper to check if this is a new diagram or existing one
  bool get isNewDiagram => id == null;
}
