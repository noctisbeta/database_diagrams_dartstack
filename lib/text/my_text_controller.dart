import 'package:database_diagrams/text/my_text_item.dart';
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

  double _size = 10;

  /// Size.
  double get size => _size;

  /// Text spans.
  List<MyTextItem> get textItems => _textItems;

  /// Add text span.
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
}
