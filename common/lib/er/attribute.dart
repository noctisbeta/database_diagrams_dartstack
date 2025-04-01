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
    this.isPrimaryKey = false,
    this.isForeignKey = false,
    this.isNullable = false,
    this.referencedEntityId,
    this.order = 0, // Add this field
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
      'referenced_entity_id': final int? referencedEntityId,
      'order': final int order, // Add this
    } =>
      Attribute(
        id: id,
        name: name,
        dataType: dataType,
        isPrimaryKey: isPrimaryKey,
        isForeignKey: isForeignKey,
        isNullable: isNullable,
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
  final int? referencedEntityId;

  @override
  Attribute copyWith({
    int? id,
    String? name,
    String? dataType,
    bool? isPrimaryKey,
    bool? isForeignKey,
    bool? isNullable,
    int? Function()? referencedEntityIdFactory,
    int? order,
  }) => Attribute(
    id: id ?? this.id,
    name: name ?? this.name,
    dataType: dataType ?? this.dataType,
    isPrimaryKey: isPrimaryKey ?? this.isPrimaryKey,
    isForeignKey: isForeignKey ?? this.isForeignKey,
    isNullable: isNullable ?? this.isNullable,
    referencedEntityId: referencedEntityIdFactory?.call() ?? referencedEntityId,
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
    'referenced_entity_id': referencedEntityId,
    'order': order,
  };
}
