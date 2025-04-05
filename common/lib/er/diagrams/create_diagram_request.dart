import 'package:common/abstractions/models.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:meta/meta.dart';

@immutable
final class CreateDiagramRequest extends RequestDTO {
  const CreateDiagramRequest({required this.name});

  factory CreateDiagramRequest.validatedFromMap(Map<String, dynamic> map) =>
      switch (map) {
        {'name': final String name} => CreateDiagramRequest(name: name),
        _ =>
          throw const BadMapShapeException(
            'Bad map shape for CreateDiagramRequest',
          ),
      };

  final String name;

  @override
  List<Object?> get props => [name];

  @override
  Map<String, dynamic> toMap() => {'name': name};

  @override
  CreateDiagramRequest copyWith({String? name}) =>
      CreateDiagramRequest(name: name ?? this.name);
}
