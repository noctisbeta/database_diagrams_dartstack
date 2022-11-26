/// Extension
extension IterableExtension<T> on Iterable<T> {
  /// Separated by.
  Iterable<T> separatedBy(T separator) sync* {
    final iterator = this.iterator;
    if (iterator.moveNext()) {
      yield iterator.current;
      while (iterator.moveNext()) {
        yield separator;
        yield iterator.current;
      }
    }
  }

  /// Separated by to list.
  List<T> separatedByToList(T separator) => separatedBy(separator).toList();
}
