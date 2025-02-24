import 'package:database_diagrams/main/editor_view.dart';
import 'package:database_diagrams/main/toolbar.dart';
import 'package:database_diagrams/overlay_manager/overlay_manager.dart';
import 'package:flutter/material.dart';

/// Main view.
class MainView extends StatelessWidget {
  /// Default constructor.
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Toolbar(),
          Expanded(
            key: OverlayManager.editorViewKey,
            child: const EditorView(),
          ),
        ],
      ),
    );
  }
}
