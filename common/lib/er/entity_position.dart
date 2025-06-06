import 'package:common/abstractions/models.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:meta/meta.dart';

@immutable
final class EntityPosition extends DataModel {
  const EntityPosition({
    required this.entityId,
    required this.x,
    required this.y,
  });

  factory EntityPosition.validatedFromMap(
    Map<String, dynamic> map,
  ) => switch (map) {
    {'entity_id': final int entityId, 'x': final num x, 'y': final num y} =>
      EntityPosition(entityId: entityId, x: x.toDouble(), y: y.toDouble()),
    _ => throw const BadMapShapeException('Bad map shape for EntityPosition.'),
  };

  final int entityId;
  final double x;
  final double y;

  @override
  Map<String, dynamic> toMap() => {'entity_id': entityId, 'x': x, 'y': y};

  @override
  List<Object?> get props => [entityId, x, y];

  @override
  EntityPosition copyWith({int? entityId, double? x, double? y}) =>
      EntityPosition(
        entityId: entityId ?? this.entityId,
        x: x ?? this.x,
        y: y ?? this.y,
      );
}
