import 'package:common/abstractions/models.dart';
import 'package:common/annotations/throws.dart';
import 'package:common/er/attribute.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:meta/meta.dart';

@immutable
final class Entity extends DataModel {
  const Entity({
    required this.id,
    required this.name,
    required this.attributes,
  });

  @Throws([BadMapShapeException])
  factory Entity.validatedFromMap(Map<String, dynamic> map) => switch (map) {
    {
      'id': final int id,
      'name': final String name,
      'attributes': final List<dynamic> attributes,
    } =>
      Entity(
        id: id,
        name: name,
        attributes:
            attributes.map((attr) => Attribute.validatedFromMap(attr)).toList(),
      ),
    _ => throw const BadMapShapeException('Bad map shape for Entity'),
  };

  final int id;
  final String name;
  final List<Attribute> attributes;

  @override
  Entity copyWith({int? id, String? name, List<Attribute>? attributes}) =>
      Entity(
        id: id ?? this.id,
        name: name ?? this.name,
        attributes: attributes ?? this.attributes,
      );

  @override
  List<Object?> get props => [id, name, attributes];

  @override
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'attributes': attributes.map((attribute) => attribute.toMap()).toList(),
  };
}
