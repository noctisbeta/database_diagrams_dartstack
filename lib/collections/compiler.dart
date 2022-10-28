import 'dart:developer';

import 'package:database_diagrams/collections/code_editor.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Code editor compiler.
class Compiler extends StateNotifier<String> {
  /// Default constructor.
  Compiler() : super('');

  /// Provider.
  static final provider = StateNotifierProvider<Compiler, String>(
    (ref) => Compiler(),
  );

  bool _isOverlayOpen = false;

  /// Current overlay entry.
  OverlayEntry? entry;

  /// Toggle overlay.
  void toggleOverlay(TapUpDetails details, BuildContext context) {
    if (_isOverlayOpen) {
      // Navigator.of(context).pop();
      entry?.remove();
      _isOverlayOpen = false;
      entry = null;
    } else {
      openOverlay(details, context);
      _isOverlayOpen = true;
    }
  }

  /// open overlay
  void openOverlay(TapUpDetails details, BuildContext context) {
    final entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: details.globalPosition.dy == 45 ? details.localPosition.dy : 45,
          left: details.globalPosition.dx,
          child: Material(
            type: MaterialType.transparency,
            child: CodeEditor(
              onClose: closeOverlay,
              onSave: saveState,
            ),
          ),
        );
      },
    );
    Overlay.of(context)?.insert(entry);
    this.entry = entry;
  }

  /// close overlay.
  void closeOverlay() {
    entry?.remove();
    _isOverlayOpen = false;
    entry = null;
  }

  /// save state.
  void saveState(String state) {
    log(state);
    this.state = state.trim();
  }
}
