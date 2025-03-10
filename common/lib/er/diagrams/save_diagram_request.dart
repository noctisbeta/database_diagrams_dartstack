import 'package:common/abstractions/models.dart';
import 'package:common/er/entity.dart';
import 'package:common/er/entity_position.dart';
import 'package:common/er/relation.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:meta/meta.dart';

@immutable
final class SaveDiagramRequest extends DataModel {
  const SaveDiagramRequest({
    required this.name,
    required this.entities,
    required this.relations,
    required this.entityPositions,
  });

  factory SaveDiagramRequest.validatedFromMap(
    Map<String, dynamic> map,
  ) => switch (map) {
    {
      'name': final String name,
      'entities': final List<Map<String, dynamic>> entities,
      'relations': final List<Map<String, dynamic>> relations,
      'entity_positions': final List<Map<String, dynamic>> entityPositions,
    } =>
      SaveDiagramRequest(
        name: name,
        entities: entities.map(Entity.validatedFromMap).toList(),
        relations: relations.map(Relation.validatedFromMap).toList(),
        entityPositions:
            entityPositions.map(EntityPosition.validatedFromMap).toList(),
      ),
    _ =>
      throw const BadMapShapeException('Bad map shape for SaveDiagramRequest'),
  };

  final String name;
  final List<Entity> entities;
  final List<Relation> relations;
  final List<EntityPosition> entityPositions;

  @override
  Map<String, dynamic> toMap() => {
    'name': name,
    'entities': entities.map((e) => e.toMap()).toList(),
    'relations': relations.map((r) => r.toMap()).toList(),
    'entity_positions': entityPositions.map((p) => p.toMap()).toList(),
  };

  @override
  List<Object?> get props => [name, entities, relations, entityPositions];

  @override
  SaveDiagramRequest copyWith({
    String? name,
    List<Entity>? entities,
    List<Relation>? relations,
    List<EntityPosition>? entityPositions,
  }) => SaveDiagramRequest(
    name: name ?? this.name,
    entities: entities ?? this.entities,
    relations: relations ?? this.relations,
    entityPositions: entityPositions ?? this.entityPositions,
  );
}
