import 'package:database_diagrams/projects/models/project.dart';
import 'package:database_diagrams/projects/models/project_processing_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:functional/functional.dart';

/// Project state.
@immutable
class ProjectState {
  /// Default constructor.
  const ProjectState({
    required this.project,
    required this.processingState,
  });

  /// Initial state.
  const ProjectState.initial()
      : project = const None(),
        processingState = ProjectProcessingState.idle;

  /// Project.
  final Option<Project> project;

  /// Processing state.
  final ProjectProcessingState processingState;

  /// Copy with method.
  ProjectState copyWith({
    Option<Project>? project,
    ProjectProcessingState? processingState,
  }) {
    return ProjectState(
      project: project ?? this.project,
      processingState: processingState ?? this.processingState,
    );
  }
}
