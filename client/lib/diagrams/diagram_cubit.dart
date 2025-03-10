import 'package:client/diagrams/diagram_repository.dart';
import 'package:client/diagrams/diagram_state.dart';
import 'package:common/er/diagrams/save_diagram_request.dart';
import 'package:common/er/entity.dart';
import 'package:common/er/entity_position.dart';
import 'package:common/logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DiagramCubit extends Cubit<DiagramState> {
  DiagramCubit({required DiagramRepository diagramRepository})
    : _diagramRepository = diagramRepository,
      super(const DiagramState(entities: [], entityPositions: []));

  final DiagramRepository _diagramRepository;

  final GlobalKey canvasBoundaryKey = GlobalKey();

  Future<void> saveDiagram() async {
    final request = SaveDiagramRequest(
      entities: state.entities,
      name: 'New Diagram',
      relations: const [],
      entityPositions: state.entityPositions,
    );
    try {
      await _diagramRepository.saveDiagram(request);
    } on Exception catch (e) {
      LOG.e('Failed to save diagram $e');
    }
  }

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
