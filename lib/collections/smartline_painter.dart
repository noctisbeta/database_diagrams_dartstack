import 'dart:developer';

import 'package:database_diagrams/collections/smartline_anchor.dart';
import 'package:database_diagrams/collections/smartline_type.dart';
import 'package:database_diagrams/main/canvas_controller.dart';
import 'package:database_diagrams/main/editor_view.dart';
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
      if (pair.length != 2) {
        continue;
      }

      final first = pair.first.key.currentContext?.findRenderObject() as RenderBox?;
      final second = pair.last.key.currentContext?.findRenderObject() as RenderBox?;

      if (first == null || second == null) {
        continue;
      }

      final ancestor = CanvasController.canvasContainerKey.currentContext?.findRenderObject() as RenderBox?;

      log('render box: ${first.localToGlobal(Offset.zero, ancestor: ancestor)}');
      log('render box: ${first.localToGlobal(Offset.zero)}');
      log('render box: ${first.globalToLocal(Offset.zero)}');
      log('render box: ${first.parent}');

      final paint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2;

      // TODO(Janez): Separate card and attribute lines. Padding gets in the way (inside the card).
      const padding = 15;

      final firstCenter = first.localToGlobal(first.size.center(Offset.zero), ancestor: ancestor);
      final secondCenter = second.localToGlobal(second.size.center(Offset.zero), ancestor: ancestor);

      final firstLeft = first.localToGlobal(first.size.center(Offset(-padding - first.size.width / 2, 0)), ancestor: ancestor);
      final firstRight = first.localToGlobal(first.size.center(Offset(padding + first.size.width / 2, 0)), ancestor: ancestor);
      final firstTop = first.localToGlobal(first.size.center(Offset(0, -padding - first.size.height / 2)), ancestor: ancestor);
      final firstBottom = first.localToGlobal(first.size.center(Offset(0, padding + first.size.height / 2)), ancestor: ancestor);

      final secondLeft = second.localToGlobal(second.size.center(Offset(-padding - second.size.width / 2, 0)), ancestor: ancestor);
      final secondRight = second.localToGlobal(second.size.center(Offset(padding + second.size.width / 2, 0)), ancestor: ancestor);
      final secondTop = second.localToGlobal(second.size.center(Offset(0, -padding - second.size.height / 2)), ancestor: ancestor);
      final secondBottom = second.localToGlobal(second.size.center(Offset(0, padding + second.size.height / 2)), ancestor: ancestor);

      /// minimize distance between two points
      if (pair.first.type == SmartlineType.card || pair.last.type == SmartlineType.card) {
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
        canvas.drawLine(firstOffset, secondOffset, paint);
        continue;
      }

      final path = Path();

      const gap = 30;

      /// First left
      if (firstRight.dx < secondLeft.dx) {
        // if vgap or hgap too small
        if ((secondLeft.dx - firstRight.dx).abs() < gap || (firstCenter.dy - secondCenter.dy).abs() < gap) {
          flgs(path, firstRight, secondLeft, canvas, paint);
          continue;
        }

        // if first is above second
        if (firstCenter.dy < secondCenter.dy) {
          log('here');
          flgbfa(path, firstRight, secondLeft, canvas, paint);
          continue;
          // if first is below second
        } else {
          flgbfb(path, firstRight, secondLeft, canvas, paint);
          continue;
        }

        // First right
      } else if (firstLeft.dx > secondRight.dx) {
        // if vgap or hgap too small
        if ((secondRight.dx - firstLeft.dx).abs() < gap || (firstCenter.dy - secondCenter.dy).abs() < gap) {
          frgs(path, secondRight, firstLeft, canvas, paint);
          continue;
        }

        // if first is above second
        if (firstCenter.dy < secondCenter.dy) {
          log('here');
          frgbfa(path, secondRight, firstLeft, canvas, paint);
          continue;
          // if first is below second
        } else {
          frgbfb(path, secondRight, firstLeft, canvas, paint);
          continue;
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant SmartlinePainter oldDelegate) => true;

  /// First left of second, gap too small.
  void flgs(Path path, Offset firstRight, Offset secondLeft, Canvas canvas, Paint paint) {
    path
      ..moveTo(firstRight.dx, firstRight.dy)
      ..cubicTo(
        firstRight.dx + 10,
        firstRight.dy,
        secondLeft.dx - 10,
        secondLeft.dy,
        secondLeft.dx,
        secondLeft.dy,
      )
      ..lineTo(secondLeft.dx, secondLeft.dy);
    canvas.drawPath(path, paint);
  }

  /// First left of second, first above second, gap big enough.
  void flgbfa(Path path, Offset firstRight, Offset secondLeft, Canvas canvas, Paint paint) {
    path
      ..moveTo(firstRight.dx, firstRight.dy)
      ..lineTo(-15 + firstRight.dx + (secondLeft.dx - firstRight.dx) / 2, firstRight.dy)
      ..arcToPoint(
        Offset(firstRight.dx + (secondLeft.dx - firstRight.dx) / 2, firstRight.dy + 15),
        radius: const Radius.circular(20),
        rotation: 90,
      )
      ..lineTo(firstRight.dx + (secondLeft.dx - firstRight.dx) / 2, secondLeft.dy - 15)
      ..arcToPoint(
        Offset(15 + firstRight.dx + (secondLeft.dx - firstRight.dx) / 2, secondLeft.dy),
        radius: const Radius.circular(20),
        clockwise: false,
        rotation: 90,
      )
      ..lineTo(secondLeft.dx, secondLeft.dy);
    canvas.drawPath(path, paint);
  }

  /// First left of second, first below second, gap big enough.
  void flgbfb(Path path, Offset firstRight, Offset secondLeft, Canvas canvas, Paint paint) {
    path
      ..moveTo(firstRight.dx, firstRight.dy)
      ..lineTo(-15 + firstRight.dx + (secondLeft.dx - firstRight.dx) / 2, firstRight.dy)
      ..arcToPoint(
        Offset(firstRight.dx + (secondLeft.dx - firstRight.dx) / 2, firstRight.dy - 15),
        radius: const Radius.circular(20),
        clockwise: false,
        rotation: 90,
      )
      ..lineTo(firstRight.dx + (secondLeft.dx - firstRight.dx) / 2, secondLeft.dy + 15)
      ..arcToPoint(
        Offset(15 + firstRight.dx + (secondLeft.dx - firstRight.dx) / 2, secondLeft.dy),
        radius: const Radius.circular(20),
        rotation: 90,
      )
      ..lineTo(secondLeft.dx, secondLeft.dy);
    canvas.drawPath(path, paint);
  }

  /// First right of second, gap too small.
  void frgs(Path path, Offset secondRight, Offset firstLeft, Canvas canvas, Paint paint) {
    path
      ..moveTo(secondRight.dx, secondRight.dy)
      ..cubicTo(
        secondRight.dx + 10,
        secondRight.dy,
        firstLeft.dx - 10,
        firstLeft.dy,
        firstLeft.dx,
        firstLeft.dy,
      )
      ..lineTo(firstLeft.dx, firstLeft.dy);
    canvas.drawPath(path, paint);
  }

  /// First right of second, first above second, gap big enough.
  void frgbfa(Path path, Offset secondRight, Offset firstLeft, Canvas canvas, Paint paint) {
    path
      ..moveTo(secondRight.dx, secondRight.dy)
      ..lineTo(-15 + secondRight.dx + (firstLeft.dx - secondRight.dx) / 2, secondRight.dy)
      ..arcToPoint(
        Offset(secondRight.dx + (firstLeft.dx - secondRight.dx) / 2, secondRight.dy - 15),
        radius: const Radius.circular(20),
        clockwise: false,
        rotation: 90,
      )
      ..lineTo(secondRight.dx + (firstLeft.dx - secondRight.dx) / 2, firstLeft.dy + 15)
      ..arcToPoint(
        Offset(15 + secondRight.dx + (firstLeft.dx - secondRight.dx) / 2, firstLeft.dy),
        radius: const Radius.circular(20),
        rotation: 90,
      )
      ..lineTo(firstLeft.dx, firstLeft.dy);
    canvas.drawPath(path, paint);
  }

  /// First right of second, first below second, gap big enough.
  void frgbfb(Path path, Offset secondRight, Offset firstLeft, Canvas canvas, Paint paint) {
    path
      ..moveTo(secondRight.dx, secondRight.dy)
      ..lineTo(-15 + secondRight.dx + (firstLeft.dx - secondRight.dx) / 2, secondRight.dy)
      ..arcToPoint(
        Offset(secondRight.dx + (firstLeft.dx - secondRight.dx) / 2, secondRight.dy + 15),
        radius: const Radius.circular(20),
        rotation: 90,
      )
      ..lineTo(secondRight.dx + (firstLeft.dx - secondRight.dx) / 2, firstLeft.dy - 15)
      ..arcToPoint(
        Offset(15 + secondRight.dx + (firstLeft.dx - secondRight.dx) / 2, firstLeft.dy),
        radius: const Radius.circular(20),
        clockwise: false,
        rotation: 90,
      )
      ..lineTo(firstLeft.dx, firstLeft.dy);
    canvas.drawPath(path, paint);
  }
}
