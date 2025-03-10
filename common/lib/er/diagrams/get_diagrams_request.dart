import 'package:common/abstractions/models.dart';
import 'package:meta/meta.dart';

@immutable
final class GetDiagramsRequest extends RequestDTO {
  const GetDiagramsRequest();

  factory GetDiagramsRequest.validatedFromMap() => const GetDiagramsRequest();

  @override
  GetDiagramsRequest copyWith() => const GetDiagramsRequest();

  @override
  List<Object?> get props => [];

  @override
  Map<String, dynamic> toMap() => {};
}
