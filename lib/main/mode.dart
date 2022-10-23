/// Mode.
enum Mode {
  ///
  smartLine,

  ///
  drawing,

  ///
  polyline,

  ///
  none;

  /// Is undoable.
  bool get isUndoable => this == Mode.drawing || this == Mode.polyline || this == Mode.smartLine;
}
