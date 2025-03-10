import 'package:common/er/diagram.dart';
import 'package:common/er/diagrams/get_diagrams_request.dart';
import 'package:common/er/diagrams/get_diagrams_response.dart';
import 'package:common/er/diagrams/save_diagram_request.dart';
import 'package:common/er/diagrams/save_diagram_response.dart';
import 'package:meta/meta.dart';
import 'package:server/diagrams/abstractions/i_diagams_repository.dart';
import 'package:server/diagrams/abstractions/i_diagrams_data_source.dart';

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
    await _diagramsDataSource.saveDiagram(request, userId);

    return const SaveDiagramResponse();
  }
}
