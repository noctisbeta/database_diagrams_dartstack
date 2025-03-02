import 'package:database_diagrams_client/state/diagram_state.dart';
import 'package:database_diagrams_common/er/entity.dart';
import 'package:database_diagrams_common/er/entity_position.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DiagramCubit extends Cubit<DiagramState> {
  DiagramCubit() : super(const DiagramState(entities: [], entityPositions: []));

  void addEntity(Entity entity) {
    final String id = (state.entities.length + 1).toString();

    final Entity newEntity = entity.copyWith(id: id);
    final newPosition = EntityPosition(entityId: id, x: 200, y: 200);

    emit(
      state.copyWith(
        entities: [...state.entities, newEntity],
        entityPositions: [...state.entityPositions, newPosition],
      ),
    );
  }

  void updateEntityPosition(String entityId, double dx, double dy) {
    final List<EntityPosition> positions = [...state.entityPositions];
    final int index = positions.indexWhere((pos) => pos.entityId == entityId);

    if (index == -1) {
      return;
    }

    // Directly set the new position instead of adding to it
    positions[index] = positions[index].copyWith(x: dx, y: dy);

    emit(state.copyWith(entityPositions: positions));
  }
}
