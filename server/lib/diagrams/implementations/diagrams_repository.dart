import 'package:common/er/diagram.dart';
import 'package:common/er/diagrams/get_diagrams_request.dart';
import 'package:common/er/diagrams/get_diagrams_response.dart';
import 'package:common/er/diagrams/save_diagram_request.dart';
import 'package:common/er/diagrams/save_diagram_response.dart';
import 'package:meta/meta.dart';
import 'package:server/diagrams/abstractions/i_diagams_repository.dart';
import 'package:server/diagrams/abstractions/i_diagrams_data_source.dart';
import 'package:server/diagrams/models/diagram_db.dart';

@immutable
final class DiagramsRepository implements IDiagramsRepository {
  const DiagramsRepository({required IDiagramsDataSource diagramsDataSource})
    : _diagramsDataSource = diagramsDataSource;

  final IDiagramsDataSource _diagramsDataSource;

  @override
  Future<GetDiagramsResponse> getDiagrams(
    GetDiagramsRequest request,
    int userId,
  ) async {
    final List<Diagram> res = await _diagramsDataSource.getDiagrams(userId);

    return GetDiagramsResponse(diagrams: res);
  }

  @override
  Future<SaveDiagramResponse> saveDiagram(
    SaveDiagramRequest request,
    int userId,
  ) async {
    final DiagramDB diagramDB = await _diagramsDataSource.createDiagram(
      request,
      userId,
    );

    return SaveDiagramResponse(id: diagramDB.id);
  }

  @override
  Future<SaveDiagramResponse> updateDiagram(
    SaveDiagramRequest request,
    int userId,
    int diagramId,
  ) async {
    // Update the diagram
    final DiagramDB updatedDiagram = await _diagramsDataSource.updateDiagram(
      request,
      userId,
    );

    return SaveDiagramResponse(id: updatedDiagram.id);
  }
}
