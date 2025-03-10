import 'package:common/abstractions/models.dart';
import 'package:common/er/entity.dart';
import 'package:common/er/entity_position.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:meta/meta.dart';

@immutable
final class SaveDiagramRequest extends DataModel {
  const SaveDiagramRequest({
    required this.name,
    required this.entities,
    required this.entityPositions,
  });

  factory SaveDiagramRequest.validatedFromMap(
    Map<String, dynamic> map,
  ) => switch (map) {
    {
      'name': final String name,
      'entities': final List<dynamic> entities,
      'entity_positions': final List<dynamic> entityPositions,
    } =>
      SaveDiagramRequest(
        name: name,
        entities: entities.map((e) => Entity.validatedFromMap(e)).toList(),
        entityPositions:
            entityPositions
                .map((p) => EntityPosition.validatedFromMap(p))
                .toList(),
      ),
    _ =>
      throw const BadMapShapeException('Bad map shape for SaveDiagramRequest'),
  };

  final String name;
  final List<Entity> entities;
  final List<EntityPosition> entityPositions;

  @override
  Map<String, dynamic> toMap() => {
    'name': name,
    'entities': entities.map((e) => e.toMap()).toList(),
    'entity_positions': entityPositions.map((p) => p.toMap()).toList(),
  };

  @override
  List<Object?> get props => [name, entities, entityPositions];

  @override
  SaveDiagramRequest copyWith({
    String? name,
    List<Entity>? entities,
    List<EntityPosition>? entityPositions,
  }) => SaveDiagramRequest(
    name: name ?? this.name,
    entities: entities ?? this.entities,
    entityPositions: entityPositions ?? this.entityPositions,
  );
}
