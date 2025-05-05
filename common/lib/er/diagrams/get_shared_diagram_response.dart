import 'package:common/abstractions/models.dart';
import 'package:common/er/diagram.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:meta/meta.dart';

sealed class GetSharedDiagramResponse extends ResponseDTO {
  const GetSharedDiagramResponse();
}

@immutable
final class GetSharedDiagramResponseSuccess extends GetSharedDiagramResponse {
  const GetSharedDiagramResponseSuccess({required this.diagram});

  factory GetSharedDiagramResponseSuccess.validatedFromMap(
    Map<String, dynamic> map,
  ) => switch (map) {
    {'diagram': final Diagram diagram} => GetSharedDiagramResponseSuccess(
      diagram: diagram,
    ),
    _ =>
      throw const BadMapShapeException(
        'Bad map shape for GetSharedDiagramResponseSuccess',
      ),
  };

  final Diagram diagram;

  @override
  GetSharedDiagramResponseSuccess copyWith({Diagram? diagram}) =>
      GetSharedDiagramResponseSuccess(diagram: diagram ?? this.diagram);

  @override
  List<Object?> get props => [diagram];

  @override
  Map<String, dynamic> toMap() => {'diagram': diagram.toMap()};
}

@immutable
final class GetSharedDiagramResponseError extends GetSharedDiagramResponse {
  const GetSharedDiagramResponseError({required this.message});

  factory GetSharedDiagramResponseError.validatedFromMap(
    Map<String, dynamic> map,
  ) => switch (map) {
    {'message': final String errorMessage} => GetSharedDiagramResponseError(
      message: errorMessage,
    ),
    _ =>
      throw const BadMapShapeException(
        'Bad map shape for ShareDiagramResponse',
      ),
  };

  final String message;

  @override
  GetSharedDiagramResponseError copyWith({String? message}) =>
      GetSharedDiagramResponseError(message: message ?? this.message);

  @override
  List<Object?> get props => [message];

  @override
  Map<String, dynamic> toMap() => {'error': message};
}
