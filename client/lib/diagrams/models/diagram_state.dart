import 'package:common/er/entity.dart';
import 'package:common/er/entity_position.dart';
import 'package:meta/meta.dart';

@immutable
class DiagramState {
  const DiagramState({
    required this.name,
    required this.entities,
    required this.entityPositions,
    this.id,
  });

  const DiagramState.initial()
    : id = null,
      name = 'Untitled Diagram',
      entities = const [],
      entityPositions = const [];

  final int? id; // Add ID to track existing diagrams
  final String name;
  final List<Entity> entities;
  final List<EntityPosition> entityPositions;

  DiagramState copyWith({
    int? Function()? idFn,
    String? name,
    List<Entity>? entities,
    List<EntityPosition>? entityPositions,
  }) => DiagramState(
    id: idFn?.call() ?? id,
    name: name ?? this.name,
    entities: entities ?? this.entities,
    entityPositions: entityPositions ?? this.entityPositions,
  );

  // Helper to check if this is a new diagram or existing one
  bool get isNewDiagram => id == null;
}
