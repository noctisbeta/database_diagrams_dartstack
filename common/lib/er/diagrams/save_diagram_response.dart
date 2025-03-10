import 'package:common/abstractions/models.dart';
import 'package:meta/meta.dart';

@immutable
final class SaveDiagramResponse extends ResponseDTO {
  const SaveDiagramResponse();

  factory SaveDiagramResponse.validatedFromMap() => const SaveDiagramResponse();

  @override
  SaveDiagramResponse copyWith() => const SaveDiagramResponse();

  @override
  List<Object?> get props => [];

  @override
  Map<String, dynamic> toMap() => {};
}
