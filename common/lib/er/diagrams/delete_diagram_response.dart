import 'package:common/abstractions/models.dart';
import 'package:common/annotations/throws.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:meta/meta.dart';

@immutable
sealed class DeleteDiagramResponse extends RequestDTO {
  const DeleteDiagramResponse();
}

@immutable
final class DeleteDiagramResponseSuccess extends DeleteDiagramResponse {
  const DeleteDiagramResponseSuccess({required this.id});

  @Throws([BadMapShapeException])
  factory DeleteDiagramResponseSuccess.validatedFromMap(
    Map<String, dynamic> map,
  ) => switch (map) {
    {'id': final int id} => DeleteDiagramResponseSuccess(id: id),
    _ =>
      throw const BadMapShapeException(
        'Bad map shape for DeleteDiagramRequestSuccess',
      ),
  };

  final int id;

  @override
  List<Object?> get props => [id];

  @override
  Map<String, dynamic> toMap() => {'id': id};

  @override
  DeleteDiagramResponseSuccess copyWith({int? id}) =>
      DeleteDiagramResponseSuccess(id: id ?? this.id);
}

@immutable
final class DeleteDiagramResponseError extends DeleteDiagramResponse {
  const DeleteDiagramResponseError({required this.message});

  @Throws([BadMapShapeException])
  factory DeleteDiagramResponseError.validatedFromMap(
    Map<String, dynamic> map,
  ) => switch (map) {
    {'error': final String errorMessage} => DeleteDiagramResponseError(
      message: errorMessage,
    ),
    _ =>
      throw const BadMapShapeException(
        'Bad map shape for DeleteDiagramRequestError',
      ),
  };

  final String message;

  @override
  DeleteDiagramResponseError copyWith({String? errorMessage}) =>
      DeleteDiagramResponseError(message: errorMessage ?? message);

  @override
  List<Object?> get props => [message];

  @override
  Map<String, dynamic> toMap() => {'error': message};
}
