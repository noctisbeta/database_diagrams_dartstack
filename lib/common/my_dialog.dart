import 'package:database_diagrams/common/dialog_header.dart';
import 'package:database_diagrams/utilities/iterable_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// My dialog.
class MyDialog extends HookWidget {
  /// Default constructor.
  const MyDialog({
    required this.heading,
    required this.height,
    required this.width,
    required this.child,
    this.actions,
    super.key,
  });

  /// Heading.
  final String heading;

  /// Height.
  final double height;

  /// Width.
  final double width;

  /// Child.
  final Widget child;

  /// Actions.
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final offset = useState(Offset(width / 2, height / 2));

    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        onPanUpdate: (details) => offset.value += details.delta,
        child: Stack(
          children: [
            Positioned(
              left: offset.value.dx,
              top: offset.value.dy,
              child: Container(
                height: height,
                width: width,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DialogHeader(heading: heading),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: child,
                      ),
                    ),
                    if (actions != null)
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: actions!
                              .separatedBy(const SizedBox(width: 16))
                              .toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
