import 'package:database_diagrams/text_tool/my_text_item.dart';
import 'package:flutter/material.dart';

/// Text painter.
class MyTextPainter extends CustomPainter {
  /// Default constructor.
  MyTextPainter({
    required this.textItems,
  });

  /// Text spans.
  final List<MyTextItem> textItems;

  @override
  void paint(Canvas canvas, Size size) {
    for (final item in textItems) {
      final textSpan = TextSpan(
        text: item.text,
        style: TextStyle(
          color: Colors.white,
          fontSize: item.size,
        ),
      );

      TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )
        ..layout()
        ..paint(canvas, item.offset);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
