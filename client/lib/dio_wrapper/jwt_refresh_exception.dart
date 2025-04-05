import 'package:dio/dio.dart';

final class JWTRefreshException extends DioException {
  JWTRefreshException({required super.message, required super.requestOptions});

  @override
  String toString() => 'RefreshException: $message';
}
