import 'package:common/er/diagram.dart';
import 'package:common/er/diagrams/get_diagrams_request.dart';
import 'package:common/er/diagrams/get_diagrams_response.dart';
import 'package:common/er/diagrams/get_shared_diagram_request.dart';
import 'package:common/er/diagrams/get_shared_diagram_response.dart';
import 'package:common/er/diagrams/save_diagram_request.dart';
import 'package:common/er/diagrams/save_diagram_response.dart';
import 'package:common/er/diagrams/share_diagram_request.dart';
import 'package:common/er/diagrams/share_diagram_response.dart';
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

    return GetDiagramsResponseSuccess(diagrams: res);
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

    return SaveDiagramResponseSuccess(id: diagramDB.id);
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

    return SaveDiagramResponseSuccess(id: updatedDiagram.id);
  }

  @override
  Future<void> deleteDiagram(int diagramId, int userId) async {
    await _diagramsDataSource.deleteDiagram(diagramId, userId);
  }

  @override
  Future<ShareDiagramResponse> shareDiagram(
    ShareDiagramRequest request,
    int userId,
  ) async {
    final int diagramId = request.diagramId;

    final bool hasOwnership = await _diagramsDataSource.checkDiagramOwnership(
      diagramId,
      userId,
    );

    if (!hasOwnership) {
      return const ShareDiagramResponseError(
        message: 'You do not own this diagram',
        errorType: ShareDiagramError.userNotOwner,
      );
    }

    final String shortcode = await _diagramsDataSource.shareDiagram(diagramId);

    return ShareDiagramResponseSuccess(shortcode: shortcode);
  }

  @override
  Future<GetSharedDiagramResponse> getSharedDiagram(
    GetSharedDiagramRequest request,
  ) async {
    final String shortcode = request.shortcode;

    final Diagram diagram = await _diagramsDataSource.getSharedDiagram(
      shortcode,
    );

    return GetSharedDiagramResponseSuccess(diagram: diagram);
  }
}
