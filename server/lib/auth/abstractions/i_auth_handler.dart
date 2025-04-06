import 'package:server/util/json_response.dart';
import 'package:shelf/shelf.dart';

abstract interface class IAuthHandler {
  Future<JsonResponse> refreshJWToken(Request request);
  Future<JsonResponse> login(Request request);
  Future<JsonResponse> register(Request request);
}
