import 'package:client/projects/models/projects_event.dart';
import 'package:client/projects/models/projects_state.dart';
import 'package:client/projects/repositories/projects_repository.dart';
import 'package:common/er/projects/create_project_response.dart';
import 'package:common/er/projects/project.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProjectsBloc extends Bloc<ProjectsEvent, ProjectsState> {
  ProjectsBloc({required ProjectsRepository projectsRepository})
    : _projectsRepository = projectsRepository,
      super(const ProjectsStateInitial()) {
    on<ProjectsEvent>(
      (event, emit) async => switch (event) {
        ProjectsEventLoad() => await _onLoad(event, emit),
        ProjectsEventCreate() => await _onCreate(event, emit),
      },
    );
  }

  final ProjectsRepository _projectsRepository;

  Future<void> _onLoad(
    ProjectsEventLoad event,
    Emitter<ProjectsState> emit,
  ) async {
    try {
      emit(const ProjectsStateLoading());

      final List<Project> projects = await _projectsRepository.getProjects();

      emit(ProjectsStateLoaded(projects: projects));
    } on Exception catch (e) {
      emit(ProjectsStateError(message: e.toString()));
    }
  }

  Future<void> _onCreate(
    ProjectsEventCreate event,
    Emitter<ProjectsState> emit,
  ) async {
    try {
      emit(const ProjectsStateLoading());

      final CreateProjectResponse response = await _projectsRepository
          .createProject(event.request);

      switch (response) {
        case final CreateProjectResponseSuccess success:
          if (state case final ProjectsStateLoaded loaded) {
            emit(
              ProjectsStateLoaded(
                projects: [...loaded.projects, success.project],
              ),
            );
          } else {
            emit(ProjectsStateLoaded(projects: [success.project]));
          }
        case final CreateProjectResponseFailure failure:
          emit(ProjectsStateError(message: failure.message));
      }
    } on Exception catch (e) {
      emit(ProjectsStateError(message: e.toString()));
    }
  }
}
