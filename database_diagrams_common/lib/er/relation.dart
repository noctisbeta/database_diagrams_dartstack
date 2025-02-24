import 'package:database_diagrams_common/abstractions/models.dart';
import 'package:database_diagrams_common/er/relation_type.dart';
import 'package:database_diagrams_common/exceptions/bad_map_shape_exception.dart';
import 'package:meta/meta.dart';

@immutable
final class Relation extends DataModel {
  const Relation({
    required this.id,
    required this.name,
    required this.sourceEntityId,
    required this.targetEntityId,
    required this.type,
    this.isIdentifying = false,
  });

  factory Relation.validatedFromMap(Map<String, dynamic> map) => switch (map) {
    {
      'id': final String id,
      'name': final String name,
      'source_entity_id': final String sourceEntityId,
      'target_entity_id': final String targetEntityId,
      'type': final String type,
      'is_identifying': final bool isIdentifying,
    } =>
      Relation(
        id: id,
        name: name,
        sourceEntityId: sourceEntityId,
        targetEntityId: targetEntityId,
        type: RelationType.values.byName(type),
        isIdentifying: isIdentifying,
      ),
    _ => throw const BadMapShapeException('Bad map shape for Relation'),
  };

  final String id;
  final String name;
  final String sourceEntityId;
  final String targetEntityId;
  final RelationType type;
  final bool isIdentifying;

  @override
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'source_entity_id': sourceEntityId,
    'target_entity_id': targetEntityId,
    'type': type.name,
    'is_identifying': isIdentifying,
  };

  @override
  Relation copyWith({
    String? id,
    String? name,
    String? sourceEntityId,
    String? targetEntityId,
    RelationType? type,
    bool? isIdentifying,
  }) => Relation(
    id: id ?? this.id,
    name: name ?? this.name,
    sourceEntityId: sourceEntityId ?? this.sourceEntityId,
    targetEntityId: targetEntityId ?? this.targetEntityId,
    type: type ?? this.type,
    isIdentifying: isIdentifying ?? this.isIdentifying,
  );

  @override
  List<Object?> get props => [
    id,
    name,
    sourceEntityId,
    targetEntityId,
    type,
    isIdentifying,
  ];
}
