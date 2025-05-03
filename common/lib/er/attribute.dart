import 'package:common/abstractions/models.dart';
import 'package:common/annotations/throws.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:meta/meta.dart';

@immutable
final class Attribute extends DataModel {
  const Attribute({
    required this.id,
    required this.name,
    required this.dataType,
    required this.order,
    this.isPrimaryKey = false,
    this.isForeignKey = false,
    this.isNullable = false,
    this.isIdentity = false,
    this.referencedEntityId,
  });

  @Throws([BadMapShapeException])
  factory Attribute.validatedFromMap(Map<String, dynamic> map) => switch (map) {
    {
      'id': final int id,
      'name': final String name,
      'data_type': final String dataType,
      'is_primary_key': final bool isPrimaryKey,
      'is_foreign_key': final bool isForeignKey,
      'is_nullable': final bool isNullable,
      'is_identity': final bool isIdentity,
      'referenced_entity_id': final int? referencedEntityId,
      'order': final int order,
    } =>
      Attribute(
        id: id,
        name: name,
        dataType: dataType,
        isPrimaryKey: isPrimaryKey,
        isForeignKey: isForeignKey,
        isNullable: isNullable,
        isIdentity: isIdentity,
        referencedEntityId: referencedEntityId,
        order: order,
      ),
    _ => throw const BadMapShapeException('Bad map shape for Attribute'),
  };

  final int order;
  final int id;
  final String name;
  final String dataType;
  final bool isPrimaryKey;
  final bool isForeignKey;
  final bool isNullable;
  final bool isIdentity;
  final int? referencedEntityId;

  @override
  Attribute copyWith({
    int? id,
    String? name,
    String? dataType,
    bool? isPrimaryKey,
    bool? isForeignKey,
    bool? isNullable,
    bool? isIdentity,
    int? Function()? referencedEntityIdFn,
    int? order,
  }) => Attribute(
    id: id ?? this.id,
    name: name ?? this.name,
    dataType: dataType ?? this.dataType,
    isPrimaryKey: isPrimaryKey ?? this.isPrimaryKey,
    isForeignKey: isForeignKey ?? this.isForeignKey,
    isNullable: isNullable ?? this.isNullable,
    isIdentity: isIdentity ?? this.isIdentity,
    referencedEntityId:
        referencedEntityIdFn != null
            ? referencedEntityIdFn()
            : referencedEntityId,
    order: order ?? this.order,
  );

  @override
  List<Object?> get props => [
    id,
    name,
    dataType,
    isPrimaryKey,
    isForeignKey,
    isNullable,
    isIdentity,
    referencedEntityId,
    order,
  ];

  @override
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'data_type': dataType,
    'is_primary_key': isPrimaryKey,
    'is_foreign_key': isForeignKey,
    'is_nullable': isNullable,
    'is_identity': isIdentity,
    'referenced_entity_id': referencedEntityId,
    'order': order,
  };
}
