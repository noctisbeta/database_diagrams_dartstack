import 'dart:developer';

import 'package:database_diagrams/collections/smartline_anchor.dart';
import 'package:database_diagrams/collections/smartline_type.dart';
import 'package:flutter/material.dart';

/// SmartlinePainter.
class SmartlinePainter extends CustomPainter {
  /// Default constructor.
  const SmartlinePainter({
    required this.anchors,
  });

  /// Keys.
  final List<List<SmartlineAnchor>> anchors;

  @override
  void paint(Canvas canvas, Size size) {
    for (final pair in anchors) {
      log('pair: $pair');
      if (pair.length != 2) {
        log('Invalid pair: $pair');
        continue;
      }

      final first = pair.first.key.currentContext?.findRenderObject() as RenderBox?;
      final second = pair.last.key.currentContext?.findRenderObject() as RenderBox?;

      final paint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2;

      if (first != null && second != null) {
        log('none null, painting');
        // TODO(Janez): Separate card and attribute lines. Padding gets in the way (inside the card).
        const padding = 15;

        final firstRight = first.localToGlobal(first.size.center(Offset(padding + first.size.width / 2, 0)));
        final firstLeft = first.localToGlobal(first.size.center(Offset(-padding - first.size.width / 2, 0)));
        final firstTop = first.localToGlobal(first.size.center(Offset(0, -padding - first.size.height / 2)));
        final firstBottom = first.localToGlobal(first.size.center(Offset(0, padding + first.size.height / 2)));

        final secondRight = second.localToGlobal(second.size.center(Offset(padding + second.size.width / 2, 0)));
        final secondLeft = second.localToGlobal(second.size.center(Offset(-padding - second.size.width / 2, 0)));
        final secondTop = second.localToGlobal(second.size.center(Offset(0, -padding - second.size.height / 2)));
        final secondBottom = second.localToGlobal(second.size.center(Offset(0, padding + second.size.height / 2)));

        /// minimize distance between two points

        double minDist = double.infinity;
        Offset firstOffset = firstRight;
        Offset secondOffset = secondRight;
        for (final first in [firstRight, firstLeft, firstTop, firstBottom]) {
          for (final second in [secondRight, secondLeft, secondTop, secondBottom]) {
            final distance = (first.dx - second.dx).abs() + (first.dy - second.dy).abs();
            if (distance < minDist) {
              firstOffset = first;
              secondOffset = second;
              minDist = distance;
            }
          }
        }

        if (pair.first.type == SmartlineType.card || pair.last.type == SmartlineType.card) {
          log('connecting cards');
          canvas.drawLine(firstOffset, secondOffset, paint);
        } else {
          log('connecting attributes');
          final firstCenter = first.localToGlobal(first.size.center(Offset.zero));
          final secondCenter = second.localToGlobal(second.size.center(Offset.zero));

          final path = Path();

          // first left of second
          if (firstCenter.dx < secondCenter.dx) {
            log('first left of second');
            // first below second
            if (firstCenter.dy > secondCenter.dy) {
              log('first below second');
              // if big enough gap
              if (firstCenter.dy - secondCenter.dy > 30) {
                log('big enough gap');
                final firstRight = first.localToGlobal(first.size.center(Offset(padding + first.size.width / 2, 0)));
                final secondLeft = second.localToGlobal(second.size.center(Offset(-padding - second.size.width / 2, 0)));

                path
                  ..moveTo(firstRight.dx, firstRight.dy)
                  ..lineTo(-15 + firstRight.dx + (secondCenter.dx - firstCenter.dx) / 5, firstRight.dy)
                  ..arcToPoint(
                    Offset(firstRight.dx + (secondCenter.dx - firstCenter.dx) / 5, firstRight.dy - 15),
                    radius: const Radius.circular(20),
                    clockwise: false,
                    rotation: 90,
                  )
                  ..lineTo(firstRight.dx + (secondCenter.dx - firstCenter.dx) / 5, secondLeft.dy + 15)
                  ..arcToPoint(
                    Offset(15 + firstRight.dx + (secondCenter.dx - firstCenter.dx) / 5, secondLeft.dy),
                    radius: const Radius.circular(20),
                    rotation: 90,
                  )
                  ..lineTo(secondLeft.dx, secondLeft.dy);
              } else {
                log('not big enough gap');

                final firstRight = first.localToGlobal(first.size.center(Offset(padding + first.size.width / 2, 0)));
                final secondLeft = second.localToGlobal(second.size.center(Offset(-padding - second.size.width / 2, 0)));

                path
                  ..moveTo(firstRight.dx, firstRight.dy)
                  ..lineTo(-15 + firstRight.dx + (secondCenter.dx - firstCenter.dx) / 2, firstRight.dy)
                  ..arcToPoint(
                    Offset(firstRight.dx + (secondCenter.dx - firstCenter.dx) / 2, firstRight.dy - 15),
                    radius: const Radius.circular(20),
                    clockwise: false,
                    rotation: 90,
                  )
                  ..lineTo(firstRight.dx + (secondCenter.dx - firstCenter.dx) / 2, secondLeft.dy + 15)
                  ..arcToPoint(
                    Offset(15 + firstRight.dx + (secondCenter.dx - firstCenter.dx) / 2, secondLeft.dy),
                    radius: const Radius.circular(20),
                    rotation: 90,
                  )
                  ..lineTo(secondLeft.dx, secondLeft.dy);
              }
              // first above second
            } else {
              log('first above second');
            }
            // first right of second
          } else {
            log('first right of second');
          }
          canvas.drawPath(path, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant SmartlinePainter oldDelegate) {
    return true;
  }
}
