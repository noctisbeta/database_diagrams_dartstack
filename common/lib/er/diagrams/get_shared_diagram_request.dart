import 'package:common/abstractions/models.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:meta/meta.dart';

@immutable
final class GetSharedDiagramRequest extends RequestDTO {
  const GetSharedDiagramRequest({required this.shortcode});

  factory GetSharedDiagramRequest.validatedFromMap(Map<String, dynamic> map) =>
      switch (map) {
        {'shortcode': final String shortcode} => GetSharedDiagramRequest(
          shortcode: shortcode,
        ),
        _ =>
          throw const BadMapShapeException(
            'Bad map shape for GetSharedDiagramRequest',
          ),
      };

  final String shortcode;

  @override
  Map<String, dynamic> toMap() => {'shortcode': shortcode};

  @override
  List<Object?> get props => [shortcode];

  @override
  GetSharedDiagramRequest copyWith({String? shortcode}) =>
      GetSharedDiagramRequest(shortcode: shortcode ?? this.shortcode);
}
