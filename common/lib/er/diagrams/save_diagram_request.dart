import 'package:common/abstractions/models.dart';
import 'package:common/er/diagrams/diagram_type.dart';
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
    required this.type,
    required this.id,
  });

  factory SaveDiagramRequest.validatedFromMap(
    Map<String, dynamic> map,
  ) => switch (map) {
    {
      'id': final int? id,
      'name': final String name,
      'entities': final List<dynamic> entities,
      'entity_positions': final List<dynamic> entityPositions,
      'type': final String type,
    } =>
      SaveDiagramRequest(
        id: id,
        name: name,
        entities: entities.map((e) => Entity.validatedFromMap(e)).toList(),
        entityPositions:
            entityPositions
                .map((p) => EntityPosition.validatedFromMap(p))
                .toList(),
        type: DiagramType.fromString(type),
      ),
    _ =>
      throw const BadMapShapeException('Bad map shape for SaveDiagramRequest'),
  };

  final int? id;
  final String name;
  final List<Entity> entities;
  final List<EntityPosition> entityPositions;
  final DiagramType type;

  @override
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'entities': entities.map((e) => e.toMap()).toList(),
    'entity_positions': entityPositions.map((p) => p.toMap()).toList(),
    'type': type.name,
  };

  @override
  List<Object?> get props => [id, name, entities, entityPositions];

  @override
  SaveDiagramRequest copyWith({
    int? Function()? idFn,
    String? name,
    List<Entity>? entities,
    List<EntityPosition>? entityPositions,
  }) => SaveDiagramRequest(
    id: idFn?.call() ?? id,
    name: name ?? this.name,
    entities: entities ?? this.entities,
    entityPositions: entityPositions ?? this.entityPositions,
    type: type,
  );
}
