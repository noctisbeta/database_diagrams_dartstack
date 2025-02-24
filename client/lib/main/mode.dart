/// Mode.
enum Mode {
  ///
  smartLine,

  ///
  drawing,

  ///
  polyline,

  ///
  text,

  ///
  none;

  /// Is undoable.
  bool get isUndoable => this == Mode.drawing || this == Mode.polyline || this == Mode.smartLine || this == Mode.text;
}
