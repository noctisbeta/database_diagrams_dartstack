import 'package:common/er/projects/create_project_error.dart';
import 'package:common/er/projects/create_project_request.dart';
import 'package:common/er/projects/create_project_response.dart';
import 'package:common/er/projects/get_projects_error.dart';
import 'package:common/er/projects/get_projects_response.dart';
import 'package:common/er/projects/project.dart';
import 'package:common/exceptions/propagates.dart';
import 'package:server/postgres/exceptions/database_exception.dart';
import 'package:server/projects/project_db.dart';
import 'package:server/projects/projects_data_source.dart';

final class ProjectsRepository {
  const ProjectsRepository({required ProjectsDataSource projectsDataSource})
    : _projectsDataSource = projectsDataSource;

  final ProjectsDataSource _projectsDataSource;

  @Propagates([DatabaseException])
  Future<GetProjectsResponse> getProjects(int userId) async {
    try {
      final List<ProjectDB> projects = await _projectsDataSource.getProjects(
        userId,
      );

      return GetProjectsResponseSuccess(
        projects:
            projects
                .map(
                  (p) => Project(
                    id: p.id,
                    name: p.name,
                    description: p.description,
                    createdAt: p.createdAt,
                    updatedAt: p.updatedAt,
                    diagramIds: const [],
                  ),
                )
                .toList(),
      );
    } on DatabaseException catch (e) {
      return GetProjectsResponseFailure(
        message: e.message,
        error: GetProjectsError.databaseError,
      );
    }
  }

  @Propagates([DatabaseException])
  Future<CreateProjectResponse> createProject({
    required CreateProjectRequest request,
    required int userId,
  }) async {
    try {
      final ProjectDB projectDB = await _projectsDataSource.createProject(
        request.name,
        request.description,
        userId,
      );

      final Project project = Project(
        id: projectDB.id,
        name: projectDB.name,
        description: projectDB.description,
        createdAt: projectDB.createdAt,
        updatedAt: projectDB.updatedAt,
        diagramIds: const [],
      );

      return CreateProjectResponseSuccess(project: project);
    } on DatabaseException catch (e) {
      return CreateProjectResponseFailure(
        message: e.message,
        error: CreateProjectError.databaseError,
      );
    }
  }
}
