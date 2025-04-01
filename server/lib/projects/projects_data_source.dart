import 'package:common/annotations/propagates.dart';
import 'package:common/annotations/throws.dart';
import 'package:postgres/postgres.dart';
import 'package:server/postgres/database_exception.dart';
import 'package:server/postgres/postgres_service.dart';
import 'package:server/projects/project_db.dart';

final class ProjectsDataSource {
  const ProjectsDataSource(this._db);

  final PostgresService _db;

  @Throws([DBEemptyResult, DBEbadSchema])
  @Propagates([DatabaseException])
  Future<List<ProjectDB>> getProjects(int userId) async {
    @Throws([DatabaseException])
    final Result res = await _db.execute(
      Sql.named('''
        SELECT p.* 
        FROM projects p
        JOIN project_members pm ON p.id = pm.project_id
        WHERE pm.user_id = @userId
      '''),
      parameters: {'userId': userId},
    );

    return res
        .map((row) => ProjectDB.validatedFromMap(row.toColumnMap()))
        .toList();
  }

  @Throws([DBEemptyResult, DBEbadSchema])
  @Propagates([DatabaseException])
  Future<ProjectDB> createProject(
    String name,
    String? description,
    int userId,
  ) async {
    @Throws([DatabaseException])
    final Result projectRes = await _db.execute(
      Sql.named('''
        INSERT INTO projects (name, description)
        VALUES (@name, @description)
        RETURNING *
      '''),
      parameters: {'name': name, 'description': description},
    );

    if (projectRes.isEmpty) {
      throw const DBEemptyResult('Failed to create project.');
    }

    final ProjectDB project = ProjectDB.validatedFromMap(
      projectRes.first.toColumnMap(),
    );

    @Throws([DatabaseException])
    final Result memberRes = await _db.execute(
      Sql.named('''
        INSERT INTO project_members (project_id, user_id, role)
        VALUES (@projectId, @userId, 'owner')
        RETURNING *
      '''),
      parameters: {'projectId': project.id, 'userId': userId},
    );

    if (memberRes.isEmpty) {
      throw const DBEemptyResult('Failed to create project membership.');
    }

    return project;
  }
}
