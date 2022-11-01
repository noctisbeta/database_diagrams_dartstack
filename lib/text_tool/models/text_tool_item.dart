import 'package:flutter/animation.dart';

/// MyText item.
class TextToolItem {
  /// Default constructor.
  TextToolItem({
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

  /// Copy with.
  TextToolItem copyWith({
    Offset? offset,
    String? text,
    double? size,
  }) {
    return TextToolItem(
      offset: offset ?? this.offset,
      text: text ?? this.text,
      size: size ?? this.size,
    );
  }
}
