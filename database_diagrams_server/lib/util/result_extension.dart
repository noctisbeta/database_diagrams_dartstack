import 'package:database_diagrams_server/postgres/exceptions/database_exception.dart';
import 'package:postgres/postgres.dart';

extension ResultExtension on Result {
  void assertNotEmpty() {
    if (isEmpty) {
      throw const DBEemptyResult('Result is empty');
    }
  }
}
