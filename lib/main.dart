import 'package:database_diagrams/views/editor_view.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: InitWidget(),
      ),
    ),
  );
}

/// App entry point.
class InitWidget extends StatelessWidget {
  /// Default constructor.
  const InitWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const EditorView();
  }
}
