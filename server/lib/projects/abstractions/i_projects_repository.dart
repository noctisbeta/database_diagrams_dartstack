import 'package:common/er/projects/create_project_request.dart';
import 'package:common/er/projects/create_project_response.dart';
import 'package:common/er/projects/get_projects_response.dart';

abstract interface class IProjectsRepository {
  Future<GetProjectsResponse> getProjects(int userId);

  Future<CreateProjectResponse> createProject({
    required CreateProjectRequest request,
    required int userId,
  });
}
