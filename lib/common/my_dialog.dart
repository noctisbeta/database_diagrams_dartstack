import 'package:database_diagrams/common/dialog_header.dart';
import 'package:database_diagrams/logging/log_profile.dart';
import 'package:database_diagrams/overlay_manager/overlay_label.dart';
import 'package:database_diagrams/overlay_manager/overlay_manager.dart';
import 'package:database_diagrams/utilities/iterable_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// My dialog.
class OverlayDialog extends HookWidget {
  /// Default constructor.
  const OverlayDialog({
    required this.heading,
    required this.height,
    required this.width,
    required this.child,
    required this.label,
    this.actions,
    super.key,
  });

  /// Heading.
  final String heading;

  /// Height factor between 0 and 1.
  final double height;

  /// Width factor between 0 and 1.
  final double width;

  /// Child.
  final Widget child;

  /// Actions.
  final List<Widget>? actions;

  /// Overlay label.
  final OverlayLabel label;

  @override
  Widget build(BuildContext context) {
    final evkey = OverlayManager.editorViewKey;

    final x = evkey.currentContext?.findRenderObject() as RenderBox?;

    final evsize = x!.size;

    final evtopleft = x.localToGlobal(Offset.zero);

    final screenSize = MediaQuery.of(context).size;

    myLog.i('screenSize: $screenSize');
    myLog.i('evsize: $evsize');

    // myLog.i('evtopleft: $evtopleft');

    final offset = useState(
      Offset(
        evtopleft.dx + (evsize.width - width * evsize.width) / 2,
        (evsize.height - height * evsize.height) / 2,
      ),
    );

    // myLog.i('offset: ${offset.value}');

    const dragPadding = 16.0;

    return Positioned(
      left: offset.value.dx,
      top: offset.value.dy,
      child: Container(
        height: height * evsize.height,
        width: width * evsize.width,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onPanUpdate: (details) {
                final newOffset = offset.value + details.delta;

                if (newOffset.dx - dragPadding >= 0 &&
                    newOffset.dx + width * evsize.width + dragPadding <=
                        evsize.width &&
                    newOffset.dy - dragPadding >= 0 &&
                    newOffset.dy + height * evsize.height + dragPadding <=
                        evsize.height) {
                  offset.value = newOffset;
                }
              },
              child: OverlayDialogHeader(
                label: label,
                heading: heading,
              ),
            ),
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
                  children:
                      actions!.separatedBy(const SizedBox(width: 16)).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
