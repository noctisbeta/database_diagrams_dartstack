import 'package:common/er/diagram.dart';
import 'package:meta/meta.dart';

@immutable
abstract interface class IDiagramsRepository {
  Future<List<Diagram>> getDiagrams(int projectId);
  Future<Diagram> createDiagram(Diagram diagram);
  Future<Diagram> updateDiagram(int diagramId);
  Future<void> deleteDiagram(int diagramId);
  Future<Diagram> getDiagramById(int diagramId);
}
