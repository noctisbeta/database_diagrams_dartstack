import 'dart:io';

import 'package:client/dio_wrapper/dio_wrapper.dart';
import 'package:common/er/projects/create_project_error.dart';
import 'package:common/er/projects/create_project_request.dart';
import 'package:common/er/projects/create_project_response.dart';
import 'package:common/er/projects/get_projects_response.dart';
import 'package:common/er/projects/project.dart';
import 'package:dio/dio.dart';

class ProjectsRepository {
  const ProjectsRepository({required DioWrapper dio}) : _dio = dio;

  final DioWrapper _dio;

  Future<List<Project>> getProjects() async {
    try {
      final Response response = await _dio.get('/api/v1/projects');

      final GetProjectsResponseSuccess success =
          GetProjectsResponseSuccess.validatedFromMap(response.data);

      return success.projects;
    } on DioException catch (e) {
      if (e.response?.statusCode == HttpStatus.notFound) {
        return const [];
      }
      throw Exception(e.message.toString());
    }
  }

  Future<CreateProjectResponse> createProject(
    CreateProjectRequest request,
  ) async {
    try {
      final Response response = await _dio.post(
        '/api/v1/projects',
        data: request.toMap(),
      );

      final CreateProjectResponseSuccess success =
          CreateProjectResponseSuccess.validatedFromMap(
            (response.data as Map<String, dynamic>)['project']
                as Map<String, dynamic>,
          );

      return success;
    } on DioException catch (e) {
      return CreateProjectResponseFailure(
        error: CreateProjectError.databaseError,
        message: e.message.toString(),
      );
    }
  }
}
