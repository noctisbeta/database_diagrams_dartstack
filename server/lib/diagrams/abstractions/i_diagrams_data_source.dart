import 'package:common/er/diagram.dart';
import 'package:common/er/diagrams/save_diagram_request.dart';
import 'package:meta/meta.dart';
import 'package:server/diagrams/diagram_db.dart';

@immutable
abstract interface class IDiagramsDataSource {
  Future<List<Diagram>> getDiagrams(int userId);
  Future<DiagramDB> saveDiagram(SaveDiagramRequest request, int userId);
}
