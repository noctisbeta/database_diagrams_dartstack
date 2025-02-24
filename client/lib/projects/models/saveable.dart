/// Saveable interface.
abstract class Saveable {
  /// Serializes the save data to a json string.
  Object serialize();

  /// Deserializes the save data from a map.
  Object deserialize(Object data);
}
