import 'package:meta/meta.dart';
import 'package:server/diagrams/diagram_db.dart';

@immutable
abstract interface class IDiagramsDataSource {
  Future<List<DiagramDB>> getDiagrams(int projectId);
  Future<DiagramDB> createDiagram(DiagramDB diagram);
  Future<DiagramDB> updateDiagram(int diagramId);
  Future<void> deleteDiagram(int diagramId);
  Future<DiagramDB> getDiagramById(int id);
}
