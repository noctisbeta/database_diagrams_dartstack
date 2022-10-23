import 'package:flutter/animation.dart';

/// MyText item.
class MyTextItem {
  /// Default constructor.
  MyTextItem({
    required this.offset,
    required this.text,
    required this.size,
  });

  /// Offset.
  final Offset offset;

  /// Text.
  final String text;

  /// Size.
  final double size;
}
