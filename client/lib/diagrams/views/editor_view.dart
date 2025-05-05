import 'dart:async';

import 'package:client/diagrams/components/add_entity_dialog.dart';
import 'package:client/diagrams/components/diagram_canvas.dart';
import 'package:client/diagrams/components/toolbar.dart';
import 'package:client/diagrams/controllers/diagram_cubit.dart';
import 'package:client/diagrams/models/diagram_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditorView extends StatefulWidget {
  const EditorView({super.key});

  @override
  State<EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView> {
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  void _showAddEntityDialog(BuildContext context) => unawaited(
    showDialog(
      context: context,
      builder:
          (dialogContext) => BlocProvider.value(
            value: context.read<DiagramCubit>(),
            child: const AddEntityDialog(),
          ),
    ),
  );

  void _showTutorialOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            bottom: 80, // Position above the FAB
            right: 25, // Align with the FAB
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(204),
                  borderRadius: BorderRadius.circular(8),
                ),
                width: 200,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Tap here to add your first entity!',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    // Animated bouncing arrow
                    AnimatedArrow(),
                  ],
                ),
              ),
            ),
          ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        _showAddEntityDialog(context);
        _overlayEntry?.remove();
        _overlayEntry = null;
      },
      child: const Icon(Icons.add),
    ),
    body: Column(
      children: [
        const Toolbar(),

        BlocBuilder<DiagramCubit, DiagramState>(
          builder: (context, state) {
            // Show tutorial overlay when there are no entities
            if (state.entities.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _showTutorialOverlay();
                }
              });
            } else {
              // Remove overlay if entities exist
              _overlayEntry?.remove();
              _overlayEntry = null;
            }

            return Expanded(
              child: DiagramCanvas(
                entities: state.entities,
                entityPositions: state.entityPositions,
                onEntityMoved: (entityId, offset) {
                  context.read<DiagramCubit>().updateEntityPosition(
                    entityId,
                    offset.dx,
                    offset.dy,
                  );
                },
              ),
            );
          },
        ),
      ],
    ),
  );
}

class AnimatedArrow extends StatefulWidget {
  const AnimatedArrow({super.key});

  @override
  State<AnimatedArrow> createState() => _AnimatedArrowState();
}

class _AnimatedArrowState extends State<AnimatedArrow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();

    // Create animation controller with duration
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true); // Repeat animation with reverse

    // Create bouncing animation
    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1), // Move up by 6 pixels
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SlideTransition(
    position: _animation,
    child: CustomPaint(size: const Size(20, 10), painter: ArrowPainter()),
  );
}

class ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.black.withAlpha(204)
          ..style = PaintingStyle.fill;

    final path =
        Path()
          ..moveTo(0, 0)
          ..lineTo(size.width, 0)
          ..lineTo(size.width / 2, size.height)
          ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
