import 'dart:convert';
import 'dart:io';

import 'package:database_diagrams_common/exceptions/throws.dart';
import 'package:database_diagrams_server/util/context_key.dart';
import 'package:shelf/shelf.dart';

extension RequestExtension on Request {
  bool validateContentType(String mime) =>
      headers[HttpHeaders.contentTypeHeader]?.contains(mime) ?? false;

  @Throws([FormatException])
  Future<Map<String, dynamic>> json() async {
    final String body = await readAsString();
    return jsonDecode(body) as Map<String, dynamic>;
  }

  int getUserId() {
    final userId = context[ContextKey.userId.keyString] as int?;
    if (userId == null) {
      throw StateError('userId not found in request context');
    }
    return userId;
  }

  T getFromContext<T>(ContextKey contextKey) {
    final value = context[contextKey.keyString] as T?;
    if (value == null) {
      throw StateError('${contextKey.keyString} not found in request context');
    }
    return value;
  }

  Request addToContext<T>(ContextKey contextKey, T value) =>
      change(context: {...context, contextKey.keyString: value});
}
