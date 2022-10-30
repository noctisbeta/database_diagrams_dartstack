import 'package:database_diagrams/text/my_text_item.dart';
import 'package:database_diagrams/text/text_mode.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// MyText controller.
class MyTextController extends ChangeNotifier {
  /// Provider.
  static final provider = ChangeNotifierProvider<MyTextController>(
    (ref) => MyTextController(),
  );

  final List<MyTextItem> _textItems = [];

  final List<MyTextItem> _textRedoStack = [];

  double _size = 20;

  /// Size.
  double get size => _size;

  /// Text spans.
  List<MyTextItem> get textItems => _textItems;

  TextMode _mode = TextMode.edit;

  /// Text mode.
  TextMode get mode => _mode;

  /// Set mode.
  void setMode(TextMode mode) {
    if (mode == _mode) {
      return;
    }

    _mode = mode;
    notifyListeners();
  }

  /// Add text item.
  void addTextItem(MyTextItem textItem) {
    _textItems.add(textItem);
    notifyListeners();
  }

  /// Set size.
  void setSize(double size) {
    _size = size;
    notifyListeners();
  }

  /// Undo text.
  void undo() {
    if (_textItems.isEmpty) {
      return;
    }
    _textRedoStack.add(_textItems.last);
    _textItems.removeLast();
    notifyListeners();
  }

  /// Redo text.
  void redo() {
    if (_textRedoStack.isEmpty) {
      return;
    }
    _textItems.add(_textRedoStack.last);
    _textRedoStack.removeLast();
    notifyListeners();
  }

  /// Update text item.
  void updateTextItem(int index, Offset offset) {
    if (_textItems.length <= index || index < 0) {
      return;
    }
    final item = _textItems.elementAt(index).copyWith(offset: offset);
    _textItems[index] = item;
    notifyListeners();
  }
}
