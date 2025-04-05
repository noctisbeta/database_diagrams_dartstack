import 'package:common/abstractions/models.dart';
import 'package:common/annotations/throws.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:meta/meta.dart';

@immutable
sealed class SaveDiagramResponse extends ResponseDTO {
  const SaveDiagramResponse();
}

@immutable
final class SaveDiagramResponseSuccess extends SaveDiagramResponse {
  const SaveDiagramResponseSuccess({required this.id});

  @Throws([BadMapShapeException])
  factory SaveDiagramResponseSuccess.validatedFromMap(
    Map<String, dynamic> map,
  ) => switch (map) {
    {'id': final int id} => SaveDiagramResponseSuccess(id: id),
    _ =>
      throw const BadMapShapeException(
        'Bad map shape for SaveDiagramResponseSuccess',
      ),
  };

  final int id;

  @override
  SaveDiagramResponseSuccess copyWith({int? id}) =>
      SaveDiagramResponseSuccess(id: id ?? this.id);

  @override
  List<Object?> get props => [id];

  @override
  Map<String, dynamic> toMap() => {'id': id};
}

@immutable
final class SaveDiagramResponseError extends SaveDiagramResponse {
  const SaveDiagramResponseError({required this.message});

  @Throws([BadMapShapeException])
  factory SaveDiagramResponseError.validatedFromMap(Map<String, dynamic> map) =>
      switch (map) {
        {'error': final String errorMessage} => SaveDiagramResponseError(
          message: errorMessage,
        ),
        _ =>
          throw const BadMapShapeException(
            'Bad map shape for SaveDiagramResponseError',
          ),
      };

  final String message;

  @override
  SaveDiagramResponseError copyWith({String? errorMessage}) =>
      SaveDiagramResponseError(message: errorMessage ?? message);

  @override
  List<Object?> get props => [message];

  @override
  Map<String, dynamic> toMap() => {'error': message};
}
