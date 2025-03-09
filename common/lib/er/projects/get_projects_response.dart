import 'package:common/abstractions/models.dart';
import 'package:common/er/projects/get_projects_error.dart';
import 'package:common/er/projects/project.dart';
import 'package:meta/meta.dart';

@immutable
sealed class GetProjectsResponse extends ResponseDTO {
  const GetProjectsResponse();
}

final class GetProjectsResponseSuccess extends GetProjectsResponse {
  const GetProjectsResponseSuccess({required this.projects});

  GetProjectsResponseSuccess.validatedFromMap(Map<String, dynamic> map)
    : projects = List<Project>.from(
        (map['projects'] as List).map(
          (e) => Project.validatedFromMap(e as Map<String, dynamic>),
        ),
      );

  final List<Project> projects;

  @override
  List<Object?> get props => [projects];

  @override
  GetProjectsResponseSuccess copyWith({List<Project>? projects}) =>
      GetProjectsResponseSuccess(projects: projects ?? this.projects);

  @override
  Map<String, dynamic> toMap() => {
    'projects': projects.map((e) => e.toMap()).toList(),
  };
}

final class GetProjectsResponseFailure extends GetProjectsResponse {
  const GetProjectsResponseFailure({
    required this.error,
    required this.message,
  });

  final String message;
  final GetProjectsError error;

  @override
  List<Object?> get props => [message, error];

  @override
  GetProjectsResponseFailure copyWith({
    GetProjectsError? error,
    String? message,
  }) => GetProjectsResponseFailure(
    error: error ?? this.error,
    message: message ?? this.message,
  );

  @override
  Map<String, dynamic> toMap() => {
    'error': error.toString(),
    'message': message,
  };
}
