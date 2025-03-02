import 'package:database_diagrams_common/er/entity.dart';
import 'package:database_diagrams_common/er/entity_position.dart';

class DiagramState {
  const DiagramState({required this.entities, required this.entityPositions});

  final List<Entity> entities;
  final List<EntityPosition> entityPositions;

  DiagramState copyWith({
    List<Entity>? entities,
    List<EntityPosition>? entityPositions,
  }) => DiagramState(
    entities: entities ?? this.entities,
    entityPositions: entityPositions ?? this.entityPositions,
  );
}
