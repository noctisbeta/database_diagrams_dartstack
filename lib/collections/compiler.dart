import 'dart:developer';

import 'package:database_diagrams/collections/code_editor.dart';
import 'package:database_diagrams/collections/collection.dart';
import 'package:database_diagrams/collections/compiler_state.dart';
import 'package:database_diagrams/collections/schema.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Code editor compiler.
class Compiler extends StateNotifier<CompilerState> {
  /// Default constructor.
  Compiler()
      : super(
          const CompilerState.initial(),
        );

  /// Provider.
  static final provider = StateNotifierProvider<Compiler, CompilerState>(
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
          child: const Material(
            type: MaterialType.transparency,
            child: CodeEditor(),
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

  /// Save collections.
  void saveCollections(String code) {
    state = state.copyWith(
      collections: code,
    );
  }

  /// Save relations.
  void saveRelations(String code) {
    state = state.copyWith(
      relations: code,
    );
  }

  /// Compile.
  List<Collection> compile() {
    if (state.collections.isEmpty) {
      return [];
    }

    final collections = <Collection>[];

    for (final word in state.collections.split(' ')) {
      if (word == 'Collection') {
        collections.add(
          Collection(
            name: 'test',
            schema: Schema({}),
          ),
        );
      }
    }

    return collections;
  }
}
