import 'package:functional/functional.dart';

/// Saveable interface.
abstract class Saveable {
  /// Serializes the save data to a json string.
  String serialize();
}
