import 'package:client/diagrams/models/attribute_error.dart';
import 'package:client/diagrams/models/entity_editor_state.dart';
import 'package:client/util/list_extension.dart';
import 'package:common/er/attribute.dart';
import 'package:common/er/entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final class EntityEditorCubit extends Cubit<EntityEditorState> {
  EntityEditorCubit() : super(const EntityEditorState.empty());

  void setAttributes(List<Attribute> attributes) {
    emit(state.copyWith(attributes: attributes));
  }

  bool validateEntity(Set<String>? allowedDataTypes) {
    final String? nameError =
        state.name.isEmpty ? 'Name cannot be empty' : null;

    final List<AttributeError> attributesErrors = [];

    AttributeError? attributeError;

    for (final Attribute attribute in state.attributes) {
      attributeError = const AttributeError.empty();

      if (attribute.name.isEmpty) {
        attributeError = attributeError.copyWith(
          nameErrorFn: () => 'Name cannot be empty',
        );
      }

      if (attribute.dataType.isEmpty) {
        attributeError = attributeError.copyWith(
          typeErrorFn: () => 'Type cannot be empty',
        );
      }

      if (allowedDataTypes != null &&
          !allowedDataTypes.contains(attribute.dataType)) {
        attributeError = attributeError.copyWith(
          typeErrorFn: () => 'Invalid data type',
        );
      }

      if (attributeError.nameError != null ||
          attributeError.typeError != null) {
        attributesErrors.add(
          attributeError.copyWith(orderFn: () => attribute.order),
        );
      }
    }

    emit(
      state.copyWith(
        nameErrorFn: () => nameError,
        attributesErrors: attributesErrors,
      ),
    );

    if (nameError != null || attributesErrors.isNotEmpty) {
      return false;
    }
    return true;
  }

  void setName(String name) {
    emit(state.copyWith(name: name));
  }

  void removeAttribute(int order) {
    final List<Attribute> newAttributes = [
      for (final attribute in state.attributes)
        if (attribute.order != order) attribute,
    ];

    emit(state.copyWith(attributes: newAttributes));
  }

  void addAttribute() {
    final int newOrder = state.attributes.length;
    final int uniqueId =
        -DateTime.now().millisecondsSinceEpoch - state.attributes.length;
    final Attribute newAttribute = Attribute(
      id: uniqueId,
      order: newOrder,
      name: '',
      dataType: '',
    );

    emit(state.copyWith(attributes: [...state.attributes, newAttribute]));
  }

  void updateAttribute({
    required int id,
    String? name,
    String? dataType,
    bool? isPrimaryKey,
    bool? isForeignKey,
    bool? isNullable,
    int? referencedEntityId,
  }) {
    final List<Attribute> newAttributes = [
      for (final attribute in state.attributes)
        if (attribute.id == id)
          attribute.copyWith(
            name: name,
            dataType: dataType,
            isPrimaryKey: isPrimaryKey,
            isForeignKey: isForeignKey,
            isNullable: isNullable,
            referencedEntityIdFn:
                referencedEntityId == null ? null : () => referencedEntityId,
          )
        else
          attribute,
    ];

    emit(state.copyWith(attributes: newAttributes));
  }

  void loadEntity(Entity entity) {
    final int? primaryKeyId = entity.attributes.firstIndexWhereOrNull(
      (attr) => attr.isPrimaryKey,
    );

    emit(
      EntityEditorState(
        id: entity.id,
        name: entity.name,
        attributes: List.from(entity.attributes),
        primaryKeyId: primaryKeyId,
      ),
    );
  }
}
