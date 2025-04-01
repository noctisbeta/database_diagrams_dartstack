import 'package:common/abstractions/models.dart';
import 'package:common/annotations/throws.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:meta/meta.dart';

@immutable
final class SaveDiagramResponse extends ResponseDTO {
  const SaveDiagramResponse({required this.id});

  @Throws([BadMapShapeException])
  factory SaveDiagramResponse.validatedFromMap(
    Map<String, dynamic> map,
  ) => switch (map) {
    {'id': final int id} => SaveDiagramResponse(id: id),
    _ =>
      throw const BadMapShapeException('Bad map shape for SaveDiagramResponse'),
  };

  final int id;

  @override
  SaveDiagramResponse copyWith({int? id}) =>
      SaveDiagramResponse(id: id ?? this.id);

  @override
  List<Object?> get props => [id];

  @override
  Map<String, dynamic> toMap() => {'id': id};
}
