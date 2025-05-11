import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:client/diagrams/models/diagram_state.dart';
import 'package:client/diagrams/repositories/diagram_repository.dart';
import 'package:common/er/diagram.dart';
import 'package:common/er/diagrams/diagram_type.dart';
import 'package:common/er/diagrams/get_diagrams_response.dart';
import 'package:common/er/diagrams/save_diagram_request.dart';
import 'package:common/er/diagrams/save_diagram_response.dart';
import 'package:common/er/diagrams/share_diagram_request.dart';
import 'package:common/er/diagrams/share_diagram_response.dart';
import 'package:common/er/entity.dart';
import 'package:common/er/entity_position.dart';
import 'package:common/logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

part '../models/data_types.dart';

class DiagramCubit extends Cubit<DiagramState> {
  DiagramCubit({required DiagramRepository diagramRepository})
    : _diagramRepository = diagramRepository,
      _persistedState =
          const DiagramState.initial(), // Initialize persisted state
      super(const DiagramState.initial()) {
    unawaited(loadDiagramFromLocalStorage());
    // The stream listener for _saveDiagramToLocalStorage can remain
    // as it's for local caching of the current working state.
    stream.listen(_saveDiagramToLocalStorage);
  }

  final DiagramRepository _diagramRepository;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  DiagramState _persistedState;

  final GlobalKey canvasBoundaryKey = GlobalKey();
  static const String _localStorageKey = 'current_diagram_state_secure';

  // Getter for the SaveButton to check for unsaved changes
  bool get hasUnsavedChanges => state != _persistedState;

  Set<String>? get allowedDataTypes => switch (state.diagramType) {
    DiagramType.postgresql => _kPostgresDataTypes,
    DiagramType.firestore => _kFirestoreDataTypes,
    DiagramType.custom => null,
  };

  Future<String?> shareDiagram() async {
    await saveDiagram();

    final ShareDiagramRequest request = ShareDiagramRequest(
      diagramId: state.id!,
    );

    final ShareDiagramResponse response = await _diagramRepository.shareDiagram(
      request,
    );

    switch (response) {
      case ShareDiagramResponseSuccess():
        return response.shortcode;
      case ShareDiagramResponseError():
        LOG.e('Failed to share diagram: ${response.message}');
        return null;
    }
  }

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

  void loadDiagram(Diagram diagram) {
    final loadedState = DiagramState(
      id: diagram.id,
      name: diagram.name,
      entities: diagram.entities,
      entityPositions: diagram.entityPositions,
      diagramType: diagram.diagramType,
    );
    emit(loadedState);
    _persistedState = state; // Update persisted state to match server
  }

  Future<void> saveDiagram() async {
    final request = SaveDiagramRequest(
      id: state.id, // Use current state's id
      name: state.name,
      entities: state.entities,
      entityPositions: state.entityPositions,
      type: state.diagramType,
    );

    final SaveDiagramResponse response = await _diagramRepository.saveDiagram(
      request,
    );

    switch (response) {
      case SaveDiagramResponseSuccess():
        // Update current state with new ID if it was a new diagram
        emit(
          state.copyWith(idFn: state.isNewDiagram ? () => response.id : null),
        );
        _persistedState =
            state; // Update persisted state to the newly saved state
      case SaveDiagramResponseError():
        LOG.e('Failed to save diagram: ${response.message}');
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
    _persistedState = const DiagramState.initial(); // Reset persisted state
    unawaited(_clearDiagramFromLocalStorage());
  }

  void addEntity(Entity entity) {
    final int id =
        state.entities.isNotEmpty
            ? state.entities.map((e) => e.id).reduce((a, b) => a > b ? a : b) +
                1
            : 1;
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
    if (index == -1 || (positions[index].x == dx && positions[index].y == dy)) {
      return;
    }
    positions[index] = positions[index].copyWith(x: dx, y: dy);
    emit(state.copyWith(entityPositions: positions));
  }

  void updateEntity(int entityId, Entity updatedEntity) {
    bool changed = false;
    final List<Entity> updatedEntities =
        state.entities.map((entity) {
          if (entity.id == entityId) {
            if (entity != updatedEntity) {
              changed = true;
            }
            return updatedEntity;
          }
          return entity;
        }).toList();
    if (!changed) {
      return;
    }
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
    await _diagramRepository.deleteDiagram(diagramId);

    if (state.id == diagramId) {
      resetDiagram();
    }

    await getDiagrams();
  }

  void importDiagramFromMap(Map<String, dynamic> diagramMap) {
    try {
      final loadedDiagramState = DiagramState.validatedFromMap(diagramMap);
      emit(loadedDiagramState);
    } catch (e) {
      LOG.e('Error importing diagram into cubit: $e');
      throw Exception('Failed to process imported diagram data: $e');
    }
  }

  Future<void> processImportedFile(Uint8List fileBytes) async {
    try {
      final String jsonString = utf8.decode(fileBytes);
      final Map<String, dynamic> diagramMap =
          jsonDecode(jsonString) as Map<String, dynamic>;

      // Your existing importDiagramFromMap method already handles
      // state emission and its own error logging/throwing.
      importDiagramFromMap(diagramMap);
    } on Exception catch (e) {
      LOG.e('Error decoding or parsing JSON during file import: $e');
      // Re-throw a more specific exception or a generic one for the UI to catch
      throw Exception(
        'Failed to process imported file data. Invalid format or content.',
      );
    }
  }

  Future<void> loadDiagramFromLocalStorage() async {
    try {
      final String? diagramJson = await _secureStorage.read(
        key: _localStorageKey,
      );
      if (diagramJson != null) {
        final Map<String, dynamic> diagramMap =
            jsonDecode(diagramJson) as Map<String, dynamic>;
        final loadedState = DiagramState.validatedFromMap(diagramMap);
        emit(loadedState);
        _persistedState = loadedState;
      } else {
        _persistedState = state;
      }
    } on Exception catch (e) {
      LOG.e('Failed to load diagram from secure storage: $e');

      emit(const DiagramState.initial());
      _persistedState = const DiagramState.initial();
      await _secureStorage.delete(key: _localStorageKey);
    }
  }

  Future<void> _saveDiagramToLocalStorage(DiagramState stateToSave) async {
    try {
      // If the state to save is the initial state,
      // it implies we either reset the diagram or started fresh.
      // In this case, we should clear any existing diagram from local storage.
      if (stateToSave == const DiagramState.initial()) {
        // Only delete if it actually exists to avoid unnecessary operations
        final String? existingData = await _secureStorage.read(
          key: _localStorageKey,
        );
        if (existingData != null) {
          await _secureStorage.delete(key: _localStorageKey);
        }
      } else {
        final String diagramJson = jsonEncode(stateToSave.toMap());
        await _secureStorage.write(key: _localStorageKey, value: diagramJson);
      }
    } on Exception catch (e) {
      LOG.e('Failed to save diagram to secure storage: $e');
    }
  }

  Future<void> _clearDiagramFromLocalStorage() async {
    try {
      await _secureStorage.delete(key: _localStorageKey);
    } on Exception catch (e) {
      LOG.e('Failed to clear diagram from secure storage: $e');
    }
  }
}
