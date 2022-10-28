import 'package:database_diagrams/main/zoom_controller.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Editor buttons.
class ZoomButtons extends HookConsumerWidget {
  /// Default constructor.
  const ZoomButtons({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zoomController = ref.watch(ZoomController.provider.notifier);

    return Row(
      children: [
        FloatingActionButton(
          backgroundColor: Colors.orange.shade700,
          hoverColor: Colors.orange.shade800,
          onPressed: zoomController.zoomIn,
          child: const Icon(
            Icons.zoom_in,
          ),
        ),
        const SizedBox(
          width: 16,
        ),
        FloatingActionButton(
          backgroundColor: Colors.orange.shade700,
          hoverColor: Colors.orange.shade800,
          onPressed: zoomController.zoomOut,
          child: const Icon(
            Icons.zoom_out,
          ),
        ),
      ],
    );
  }
}
