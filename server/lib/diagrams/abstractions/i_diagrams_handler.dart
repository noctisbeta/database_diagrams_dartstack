import 'package:meta/meta.dart';
import 'package:shelf/shelf.dart';

@immutable
abstract interface class IDiagramsHandler {
  Future<Response> saveDiagram(Request request);
  Future<Response> getDiagrams(Request request);
}
