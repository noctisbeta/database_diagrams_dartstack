import 'package:client/diagrams/repositories/shared_diagram_data_provider.dart';
import 'package:common/er/diagrams/get_shared_diagram_request.dart';
import 'package:common/er/diagrams/get_shared_diagram_response.dart';
import 'package:meta/meta.dart';

@immutable
final class SharedDiagramRepository {
  const SharedDiagramRepository({
    required SharedDiagramDataProvider dataProvider,
  }) : _dataProvider = dataProvider;

  final SharedDiagramDataProvider _dataProvider;

  Future<GetSharedDiagramResponse> getSharedDiagram(
    GetSharedDiagramRequest request,
  ) async {
    final GetSharedDiagramResponse response = await _dataProvider
        .getSharedDiagram(request);

    return response;
  }
}
