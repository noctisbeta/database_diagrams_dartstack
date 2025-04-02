import 'package:meta/meta.dart';
import 'package:shelf/shelf.dart';

@immutable
abstract interface class IDiagramsHandler {
  Future<Response> getDiagrams(Request request);
  Future<Response> saveDiagram(Request request);
  Future<Response> updateDiagram(Request request, String id);
  Future<Response> deleteDiagram(Request request, String id); // Add this method
}
