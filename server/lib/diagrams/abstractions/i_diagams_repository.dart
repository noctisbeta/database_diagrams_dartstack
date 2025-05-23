import 'package:common/er/diagrams/get_diagrams_request.dart';
import 'package:common/er/diagrams/get_diagrams_response.dart';
import 'package:common/er/diagrams/get_shared_diagram_response.dart';
import 'package:common/er/diagrams/save_diagram_request.dart';
import 'package:common/er/diagrams/save_diagram_response.dart';
import 'package:common/er/diagrams/share_diagram_request.dart';
import 'package:common/er/diagrams/share_diagram_response.dart';
import 'package:meta/meta.dart';

@immutable
abstract interface class IDiagramsRepository {
  Future<SaveDiagramResponse> saveDiagram(
    SaveDiagramRequest request,
    int userId,
  );
  Future<GetDiagramsResponse> getDiagrams(
    GetDiagramsRequest request,
    int userId,
  );
  Future<SaveDiagramResponse> updateDiagram(
    SaveDiagramRequest request,
    int userId,
    int diagramId,
  );

  Future<void> deleteDiagram(int diagramId, int userId);

  Future<ShareDiagramResponse> shareDiagram(
    ShareDiagramRequest request,
    int userId,
  );

  Future<GetSharedDiagramResponse> getSharedDiagram(String shortcode);
}
