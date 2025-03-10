import 'package:client/dio_wrapper/dio_wrapper.dart';
import 'package:common/er/diagrams/get_diagrams_response.dart';
import 'package:common/er/diagrams/save_diagram_request.dart';
import 'package:common/er/diagrams/save_diagram_response.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

@immutable
final class DiagramRepository {
  const DiagramRepository({required DioWrapper dio}) : _dio = dio;

  final DioWrapper _dio;

  Future<SaveDiagramResponse> saveDiagram(SaveDiagramRequest request) async {
    try {
      await _dio.post('/diagrams', data: request.toMap());
      return SaveDiagramResponse.validatedFromMap();
    } catch (e) {
      rethrow;
    }
  }

  Future<GetDiagramsResponse> getDiagrams() async {
    try {
      final Response response = await _dio.get('/diagrams');

      final GetDiagramsResponse getDiagramsResponse =
          GetDiagramsResponse.validatedFromMap(response.data);

      return getDiagramsResponse;
    } catch (e) {
      rethrow;
    }
  }
}
