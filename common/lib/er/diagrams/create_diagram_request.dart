import 'package:common/abstractions/models.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:meta/meta.dart';

@immutable
final class CreateDiagramRequest extends RequestDTO {
  const CreateDiagramRequest({required this.name, required this.projectId});

  factory CreateDiagramRequest.validatedFromMap(Map<String, dynamic> map) =>
      switch (map) {
        {'name': final String name, 'project_id': final int projectId} =>
          CreateDiagramRequest(name: name, projectId: projectId),
        _ =>
          throw const BadMapShapeException(
            'Bad map shape for CreateDiagramRequest',
          ),
      };

  final String name;
  final int projectId;

  @override
  List<Object?> get props => [name, projectId];

  @override
  Map<String, dynamic> toMap() => {'name': name, 'project_id': projectId};

  @override
  CreateDiagramRequest copyWith({String? name, int? projectId}) =>
      CreateDiagramRequest(
        name: name ?? this.name,
        projectId: projectId ?? this.projectId,
      );
}
