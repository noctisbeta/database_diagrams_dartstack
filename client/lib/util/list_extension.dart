extension ListExtension<T> on List<T> {
  int? firstIndexWhereOrNull(bool Function(T element) test) {
    for (int i = 0; i < length; i++) {
      if (test(this[i])) {
        return i;
      }
    }
    return null;
  }
}
