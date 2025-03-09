import 'package:common/abstractions/models.dart';
import 'package:common/er/projects/create_project_error.dart';
import 'package:common/er/projects/project.dart';
import 'package:meta/meta.dart';

@immutable
sealed class CreateProjectResponse extends ResponseDTO {
  const CreateProjectResponse();
}

@immutable
final class CreateProjectResponseSuccess extends CreateProjectResponse {
  const CreateProjectResponseSuccess({required this.project});

  CreateProjectResponseSuccess.validatedFromMap(Map<String, dynamic> map)
    : project = Project.validatedFromMap(
        map['project'] as Map<String, dynamic>,
      );

  final Project project;

  @override
  List<Object?> get props => [project];

  @override
  CreateProjectResponseSuccess copyWith({Project? project}) =>
      CreateProjectResponseSuccess(project: project ?? this.project);

  @override
  Map<String, dynamic> toMap() => {'project': project.toMap()};
}

final class CreateProjectResponseFailure extends CreateProjectResponse {
  const CreateProjectResponseFailure({
    required this.error,
    required this.message,
  });

  final CreateProjectError error;
  final String message;

  @override
  List<Object?> get props => [error, message];

  @override
  CreateProjectResponseFailure copyWith({
    CreateProjectError? error,
    String? message,
  }) => CreateProjectResponseFailure(
    error: error ?? this.error,
    message: message ?? this.message,
  );

  @override
  Map<String, dynamic> toMap() => {
    'error': error.toString(),
    'message': message,
  };
}
