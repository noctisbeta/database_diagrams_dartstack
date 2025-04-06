import 'package:client/diagrams/models/diagram_state.dart';
import 'package:client/diagrams/repositories/diagram_repository.dart';
import 'package:common/er/diagram.dart';
import 'package:common/er/diagrams/get_diagrams_response.dart';
import 'package:common/er/diagrams/save_diagram_request.dart';
import 'package:common/er/diagrams/save_diagram_response.dart';
import 'package:common/er/entity.dart';
import 'package:common/er/entity_position.dart';
import 'package:common/logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DiagramCubit extends Cubit<DiagramState> {
  DiagramCubit({required DiagramRepository diagramRepository})
    : _diagramRepository = diagramRepository,
      super(const DiagramState.initial());

  final DiagramRepository _diagramRepository;

  final GlobalKey canvasBoundaryKey = GlobalKey();

  Future<List<Diagram>> getDiagrams() async {
    final GetDiagramsResponse response = await _diagramRepository.getDiagrams();

    switch (response) {
      case GetDiagramsResponseSuccess():
        return response.diagrams;
      case GetDiagramsResponseError():
        LOG.e('Failed to get diagrams: ${response.message}');
        return [];
    }
  }

  void loadDiagram(Diagram diagram) => emit(
    DiagramState(
      id: diagram.id,
      name: diagram.name,
      entities: diagram.entities,
      entityPositions: diagram.entityPositions,
    ),
  );

  Future<void> saveDiagram() async {
    final request = SaveDiagramRequest(
      id: state.id,
      name: state.name,
      entities: state.entities,
      entityPositions: state.entityPositions,
    );

    final SaveDiagramResponse response = await _diagramRepository.saveDiagram(
      request,
    );

    switch (response) {
      case SaveDiagramResponseSuccess():
        if (state.isNewDiagram) {
          emit(state.copyWith(idFn: () => response.id));
        }
      case SaveDiagramResponseError():
        return;
    }
  }

  Future<void> updateDiagramTitle(String title) async {
    if (state.name == title) {
      return;
    }

    emit(state.copyWith(name: title));
  }

  void resetDiagram() {
    emit(const DiagramState.initial());
  }

  void addEntity(Entity entity) {
    final int id = state.entities.length + 1;

    final Entity newEntity = entity.copyWith(id: id);
    final newPosition = EntityPosition(entityId: id, x: 200, y: 200);

    emit(
      state.copyWith(
        entities: [...state.entities, newEntity],
        entityPositions: [...state.entityPositions, newPosition],
      ),
    );
  }

  void updateEntityPosition(int entityId, double dx, double dy) {
    final List<EntityPosition> positions = [...state.entityPositions];
    final int index = positions.indexWhere((pos) => pos.entityId == entityId);

    if (index == -1) {
      return;
    }

    positions[index] = positions[index].copyWith(x: dx, y: dy);

    emit(state.copyWith(entityPositions: positions));
  }

  void updateEntity(int entityId, Entity updatedEntity) {
    final List<Entity> updatedEntities =
        state.entities.map((entity) {
          if (entity.id == entityId) {
            return updatedEntity;
          }
          return entity;
        }).toList();

    emit(state.copyWith(entities: updatedEntities));
  }

  void deleteEntity(int entityId) {
    emit(
      state.copyWith(
        entities: [
          for (final e in state.entities)
            if (e.id != entityId) e,
        ],
      ),
    );
  }

  Future<void> deleteDiagram(int diagramId) async {
    try {
      await _diagramRepository.deleteDiagram(diagramId);

      if (state.id == diagramId) {
        resetDiagram();
      }
    } on Exception catch (e) {
      LOG.e('Failed to delete diagram: $e');
    }
  }
}
