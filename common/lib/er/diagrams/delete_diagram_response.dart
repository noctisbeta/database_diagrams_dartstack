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
  const DeleteDiagramResponseSuccess();

  @Throws([BadMapShapeException])
  factory DeleteDiagramResponseSuccess.validatedFromMap(
    Map<String, dynamic> _,
  ) => const DeleteDiagramResponseSuccess();

  @override
  List<Object?> get props => [];

  @override
  Map<String, dynamic> toMap() => {};

  @override
  DeleteDiagramResponseSuccess copyWith() =>
      const DeleteDiagramResponseSuccess();
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
