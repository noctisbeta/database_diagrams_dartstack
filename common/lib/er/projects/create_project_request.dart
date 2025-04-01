import 'package:common/abstractions/models.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:meta/meta.dart';

@immutable
final class CreateProjectRequest extends RequestDTO {
  const CreateProjectRequest({required this.name, this.description});

  factory CreateProjectRequest.validatedFromMap(Map<String, dynamic> map) =>
      switch (map) {
        {'name': final String name, 'description': final String? description} =>
          CreateProjectRequest(name: name, description: description),
        _ =>
          throw const BadMapShapeException(
            'Invalid map format for CreateProjectRequest',
          ),
      };

  final String name;
  final String? description;

  @override
  Map<String, dynamic> toMap() => {'name': name, 'description': description};

  @override
  List<Object?> get props => [name, description];

  @override
  CreateProjectRequest copyWith({String? name, String? description}) =>
      CreateProjectRequest(
        name: name ?? this.name,
        description: description ?? this.description,
      );
}
