import 'package:shelf/shelf.dart';

abstract interface class IProjectsHandler {
  Future<Response> getProjects(Request request);
  Future<Response> createProject(Request request);
}
