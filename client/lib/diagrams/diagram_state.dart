import 'package:common/er/entity.dart';
import 'package:common/er/entity_position.dart';

class DiagramState {
  const DiagramState({
    required this.name,
    required this.entities,
    required this.entityPositions,
  });

  const DiagramState.initial()
    : name = 'New Diagram',
      entities = const [],
      entityPositions = const [];

  final String name;
  final List<Entity> entities;
  final List<EntityPosition> entityPositions;

  DiagramState copyWith({
    String? name,
    List<Entity>? entities,
    List<EntityPosition>? entityPositions,
  }) => DiagramState(
    name: name ?? this.name,
    entities: entities ?? this.entities,
    entityPositions: entityPositions ?? this.entityPositions,
  );
}
