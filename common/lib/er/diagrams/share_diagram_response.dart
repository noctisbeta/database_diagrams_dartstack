import 'package:common/abstractions/models.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:meta/meta.dart';

sealed class ShareDiagramResponse extends ResponseDTO {
  const ShareDiagramResponse();
}

@immutable
final class ShareDiagramResponseSuccess extends ShareDiagramResponse {
  const ShareDiagramResponseSuccess({required this.shortcode});

  factory ShareDiagramResponseSuccess.validatedFromMap(
    Map<String, dynamic> map,
  ) => switch (map) {
    {'shortcode': final String shortcode} => ShareDiagramResponseSuccess(
      shortcode: shortcode,
    ),
    _ =>
      throw const BadMapShapeException(
        'Bad map shape for ShareDiagramResponse',
      ),
  };

  final String shortcode;

  @override
  ShareDiagramResponseSuccess copyWith({String? shortcode}) =>
      ShareDiagramResponseSuccess(shortcode: shortcode ?? this.shortcode);

  @override
  List<Object?> get props => [shortcode];

  @override
  Map<String, dynamic> toMap() => {'shortcode': shortcode};
}

@immutable
final class ShareDiagramResponseError extends ShareDiagramResponse {
  const ShareDiagramResponseError({
    required this.message,
    required this.errorType,
  });

  factory ShareDiagramResponseError.validatedFromMap(
    Map<String, dynamic> map,
  ) => switch (map) {
    {
      'message': final String errorMessage,
      'error_type': final ShareDiagramError errorType,
    } =>
      ShareDiagramResponseError(message: errorMessage, errorType: errorType),
    _ =>
      throw const BadMapShapeException(
        'Bad map shape for ShareDiagramResponse',
      ),
  };

  final String message;
  final ShareDiagramError errorType;

  @override
  ShareDiagramResponseError copyWith({
    String? message,
    ShareDiagramError? errorType,
  }) => ShareDiagramResponseError(
    message: message ?? this.message,
    errorType: errorType ?? this.errorType,
  );

  @override
  List<Object?> get props => [message, errorType];

  @override
  Map<String, dynamic> toMap() => {
    'error': message,
    'error_type': errorType.name,
  };
}

enum ShareDiagramError { userNotOwner, notAuthorized }
