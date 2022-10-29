import 'dart:developer';

import 'package:database_diagrams/collections/code_editor.dart';
import 'package:database_diagrams/collections/collection.dart';
import 'package:database_diagrams/collections/collection_store.dart';
import 'package:database_diagrams/collections/compiler_state.dart';
import 'package:database_diagrams/collections/schema.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Code editor compiler.
class Compiler extends StateNotifier<CompilerState> {
  /// Default constructor.
  Compiler(
    this.ref,
  ) : super(
          const CompilerState.initial(),
        );

  /// Provider.
  static final provider = StateNotifierProvider<Compiler, CompilerState>(
    Compiler.new,
  );

  /// Riverpod ref.
  final Ref ref;

  bool _isOverlayOpen = false;

  /// Current overlay entry.
  OverlayEntry? entry;

  Offset? _overlayOffset;

  /// Collections.
  List<Collection> get collections => compile();

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
        log('Build: _overlayOffset: $_overlayOffset');
        return Positioned(
          top: _overlayOffset != null
              ? _overlayOffset!.dy
              : details.globalPosition.dy == 45
                  ? details.localPosition.dy
                  : 45,
          left: _overlayOffset != null ? _overlayOffset!.dx : details.globalPosition.dx,
          child: Material(
            type: MaterialType.transparency,
            child: GestureDetector(
              onPanUpdate: (details) {
                log('here');
                _overlayOffset = Offset(
                  _overlayOffset!.dx + details.delta.dx,
                  _overlayOffset!.dy + details.delta.dy,
                );
                if (this.entry != null) {
                  this.entry!.markNeedsBuild();
                }
              },
              child: const CodeEditor(),
            ),
          ),
        );
      },
    );
    Overlay.of(context)?.insert(entry);
    _overlayOffset ??= details.globalPosition;
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

    compile().forEach((c) {
      ref.read(CollectionStore.provider.notifier).add(c);
    });
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

    String compileString = state.collections.replaceAll(' ', '').replaceAll('\n', '').replaceAll('\t', '');

    log('Compile string: $compileString');
    final leftCurlyCount = compileString.characters.where((p0) => p0 == '{').length;
    final rightCurlyCount = compileString.characters.where((p0) => p0 == '}').length;

    if (leftCurlyCount != rightCurlyCount) {
      log('Error: Curly braces mismatch');
      return [];
    }

    final collections = <Collection>[];

    while (compileString.contains('Collection')) {
      log('1');
      final collectionName = compileString.substring(compileString.indexOf('Collection') + 10, compileString.indexOf('{'));
      final collectionCode = compileString.substring(compileString.indexOf('{') + 1, compileString.indexOf('}'));

      log('2');
      log('collectionCode: $collectionCode');
      final schemaCompileString = collectionCode.split(',');
      log('schemaCompileString: $schemaCompileString');
      log('schemaCompileString length: ${schemaCompileString.length}');

      final schemaMap = <String, dynamic>{};

      for (final row in schemaCompileString) {
        if (row.isEmpty) {
          continue;
        }
        log('row: $row');
        final split_ = row.split(':');
        schemaMap[split_[0]] = split_[1];
      }

      log('3');

      final collection = Collection(
        name: collectionName,
        schema: Schema(
          schemaMap,
        ),
      );

      compileString = compileString.substring(compileString.indexOf('}') + 1);

      collections.add(collection);
    }

    // for (final word in state.collections.split(' ')) {
    //   if (word == 'Collection') {
    //     collections.add(
    //       Collection(
    //         name: 'test',
    //         schema: Schema({}),
    //       ),
    //     );
    //   }
    // }

    return collections;
  }
}
