import 'package:database_diagrams/overlay_manager/overlay_label.dart';
import 'package:database_diagrams/overlay_manager/overlay_state_item.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Manages opening and closing of overlays.
class OverlayManager extends StateNotifier<List<OverlayStateItem>> {
  /// Default constructor.
  OverlayManager(super.state);

  /// Key to the editor view.
  static final GlobalKey editorViewKey = GlobalKey();

  /// Provider
  static final provider =
      StateNotifierProvider<OverlayManager, List<OverlayStateItem>>(
    (ref) => OverlayManager([]),
  );

  /// Opens an overlay.
  void open(OverlayLabel label, Widget widget) =>
      state.any((stateItem) => stateItem.label == label)
          ? null
          : state = [
              ...state,
              OverlayStateItem(
                label: label,
                widget: widget,
              )
            ];

  /// Closes an overlay.
  void close(OverlayLabel label) => state = [
        ...state.where((stateItem) => stateItem.label != label),
      ];
}
