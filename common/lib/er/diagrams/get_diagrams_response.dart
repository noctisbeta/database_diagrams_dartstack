import 'package:common/abstractions/models.dart';
import 'package:common/er/diagram.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:meta/meta.dart';

@immutable
final class GetDiagramsResponse extends ResponseDTO {
  const GetDiagramsResponse({required this.diagrams});

  factory GetDiagramsResponse.validatedFromMap(
    Map<String, dynamic> map,
  ) => switch (map) {
    {'diagrams': final List<Map<String, dynamic>> diagrams} =>
      GetDiagramsResponse(
        diagrams: diagrams.map(Diagram.validatedFromMap).toList(),
      ),
    _ =>
      throw const BadMapShapeException('Bad map shape for GetDiagramsResponse'),
  };

  final List<Diagram> diagrams;

  @override
  GetDiagramsResponse copyWith({List<Diagram>? diagrams}) =>
      GetDiagramsResponse(diagrams: diagrams ?? this.diagrams);

  @override
  List<Object?> get props => [diagrams];

  @override
  Map<String, dynamic> toMap() => {
    'diagrams': diagrams.map((diagram) => diagram.toMap()).toList(),
  };
}
