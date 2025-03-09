import 'package:common/er/projects/create_project_request.dart';
import 'package:flutter/widgets.dart';

@immutable
sealed class ProjectsEvent {}

@immutable
class ProjectsEventLoad extends ProjectsEvent {}

class ProjectsEventCreate extends ProjectsEvent {
  ProjectsEventCreate({required this.request});

  final CreateProjectRequest request;
}
