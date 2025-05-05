import 'package:common/abstractions/models.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:meta/meta.dart';

@immutable
final class ShareDiagramRequest extends RequestDTO {
  const ShareDiagramRequest({required this.diagramId});

  factory ShareDiagramRequest.validatedFromMap(
    Map<String, dynamic> map,
  ) => switch (map) {
    {'diagram_id': final int diagramId} => ShareDiagramRequest(
      diagramId: diagramId,
    ),
    _ =>
      throw const BadMapShapeException('Bad map shape for ShareDiagramRequest'),
  };

  final int diagramId;

  @override
  Map<String, dynamic> toMap() => {'diagram_id': diagramId};

  @override
  List<Object?> get props => [diagramId];

  @override
  ShareDiagramRequest copyWith({int? diagramId}) =>
      ShareDiagramRequest(diagramId: diagramId ?? this.diagramId);
}
