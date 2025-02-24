import 'package:database_diagrams/overlay_manager/overlay_label.dart';
import 'package:flutter/widgets.dart';

/// Overlay state item.
class OverlayStateItem {
  /// Default constructor.
  const OverlayStateItem({
    required this.label,
    required this.widget,
  });

  /// Label that identifies the overlay.
  final OverlayLabel label;

  /// Overlay entry.
  final Widget widget;
}
