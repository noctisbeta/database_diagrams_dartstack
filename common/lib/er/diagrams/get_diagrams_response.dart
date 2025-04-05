import 'package:common/abstractions/models.dart';
import 'package:common/er/diagram.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:meta/meta.dart';

@immutable
sealed class GetDiagramsResponse extends ResponseDTO {
  const GetDiagramsResponse();
}

@immutable
final class GetDiagramsResponseSuccess extends GetDiagramsResponse {
  const GetDiagramsResponseSuccess({required this.diagrams});

  factory GetDiagramsResponseSuccess.validatedFromMap(
    Map<String, dynamic> map,
  ) => switch (map) {
    {'diagrams': final List<dynamic> diagrams} => GetDiagramsResponseSuccess(
      diagrams:
          diagrams.map((diagram) => Diagram.validatedFromMap(diagram)).toList(),
    ),
    _ =>
      throw const BadMapShapeException(
        'Bad map shape for GetDiagramsResponseSuccess',
      ),
  };

  final List<Diagram> diagrams;

  @override
  GetDiagramsResponseSuccess copyWith({List<Diagram>? diagrams}) =>
      GetDiagramsResponseSuccess(diagrams: diagrams ?? this.diagrams);

  @override
  List<Object?> get props => [diagrams];

  @override
  Map<String, dynamic> toMap() => {
    'diagrams': diagrams.map((diagram) => diagram.toMap()).toList(),
  };
}

@immutable
final class GetDiagramsResponseError extends GetDiagramsResponse {
  const GetDiagramsResponseError({required this.message});

  factory GetDiagramsResponseError.validatedFromMap(Map<String, dynamic> map) =>
      switch (map) {
        {'error': final String errorMessage} => GetDiagramsResponseError(
          message: errorMessage,
        ),
        _ =>
          throw const BadMapShapeException(
            'Bad map shape for GetDiagramsResponseError',
          ),
      };

  final String message;

  @override
  List<Object?> get props => [message];

  @override
  Map<String, dynamic> toMap() => {'error': message};

  @override
  DataModel copyWith() => GetDiagramsResponseError(message: message);
}
