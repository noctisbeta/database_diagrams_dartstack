/// Saveable interface.
abstract class Saveable {
  /// Serializes the save data to a json string.
 dynamic serialize();

  /// Deserializes the save data from a map.
  Object deserialize(String data);
}
