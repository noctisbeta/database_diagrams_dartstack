import 'package:common/er/projects/project.dart';
import 'package:meta/meta.dart';

@immutable
sealed class ProjectsState {
  const ProjectsState();
}

class ProjectsStateInitial extends ProjectsState {
  const ProjectsStateInitial();
}

class ProjectsStateLoading extends ProjectsState {
  const ProjectsStateLoading();
}

class ProjectsStateLoaded extends ProjectsState {
  const ProjectsStateLoaded({required this.projects});

  final List<Project> projects;
}

class ProjectsStateError extends ProjectsState {
  const ProjectsStateError({required this.message});

  final String message;
}
