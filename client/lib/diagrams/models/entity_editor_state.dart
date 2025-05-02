import 'package:client/diagrams/models/attribute_error.dart';
import 'package:common/er/attribute.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
final class EntityEditorState extends Equatable {
  const EntityEditorState({
    required this.id,
    required this.name,
    required this.attributes,
    required this.primaryKeyId,
    this.nameError,
    this.attributesErrors = const [],
  });

  const EntityEditorState.empty()
    : id = null,
      name = '',
      attributes = const [Attribute(id: 0, name: '', dataType: '', order: 0)],
      primaryKeyId = null,
      nameError = null,
      attributesErrors = const [];

  final int? id;
  final String name;
  final List<Attribute> attributes;
  final int? primaryKeyId;

  final String? nameError;
  final List<AttributeError> attributesErrors;

  EntityEditorState copyWith({
    int? Function()? idFn,
    String? name,
    List<Attribute>? attributes,
    int? Function()? primaryKeyIdFn,
    String? Function()? nameErrorFn,
    List<AttributeError>? attributesErrors,
  }) => EntityEditorState(
    id: idFn != null ? idFn() : id,
    name: name ?? this.name,
    attributes: attributes ?? this.attributes,
    primaryKeyId: primaryKeyIdFn != null ? primaryKeyIdFn() : primaryKeyId,
    nameError: nameErrorFn != null ? nameErrorFn() : nameError,
    attributesErrors: attributesErrors ?? this.attributesErrors,
  );

  @override
  List<Object?> get props => [
    id,
    name,
    attributes,
    primaryKeyId,
    nameError,
    attributesErrors,
  ];
}
