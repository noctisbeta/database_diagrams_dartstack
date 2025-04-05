import 'package:client/diagrams/diagram_data_provider.dart';
import 'package:common/er/diagrams/get_diagrams_response.dart';
import 'package:common/er/diagrams/save_diagram_request.dart';
import 'package:common/er/diagrams/save_diagram_response.dart';
import 'package:meta/meta.dart';

@immutable
final class DiagramRepository {
  const DiagramRepository({required DiagramDataProvider dataProvider})
    : _dataProvider = dataProvider;

  final DiagramDataProvider _dataProvider;

  Future<SaveDiagramResponse> saveDiagram(SaveDiagramRequest request) async {
    final SaveDiagramResponse saveDiagramResponse = await _dataProvider
        .saveDiagram(request);

    return saveDiagramResponse;
  }

  Future<GetDiagramsResponse> getDiagrams() async {
    final GetDiagramsResponse getDiagramsResponse =
        await _dataProvider.getDiagrams();

    return getDiagramsResponse;
  }

  Future<void> deleteDiagram(int diagramId) async {
    await _dataProvider.deleteDiagram(diagramId);
  }
}
