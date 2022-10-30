import 'package:database_diagrams/main/mode.dart';
import 'package:database_diagrams/main/mode_controller.dart';
import 'package:database_diagrams/text/my_text_controller.dart';
import 'package:database_diagrams/text/my_text_item.dart';
import 'package:database_diagrams/text/text_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Text painter.
class MyTextPainterContainer extends HookConsumerWidget {
  /// Default constructor.
  const MyTextPainterContainer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(ModeController.provider);
    final textController = ref.watch(MyTextController.provider);

    final textField = useState<TextField?>(null);
    final coordinate = useState<Offset?>(null);
    final focusNode = useState<FocusNode?>(null);

    void handleEditTap(TapUpDetails details) {
      coordinate.value = details.localPosition;

      focusNode.value = FocusNode();

      textField.value = TextField(
        focusNode: focusNode.value,
        onSubmitted: (value) {
          textController.addTextItem(
            MyTextItem(
              offset: details.localPosition,
              size: textController.size,
              text: value,
            ),
          );
          coordinate.value = null;
          textField.value = null;
        },
        cursorColor: Colors.orange.shade700,
        autofocus: true,
        style: TextStyle(
          color: Colors.red,
          fontSize: textController.size,
        ),
        decoration: const InputDecoration.collapsed(
          hintText: '',
        ),
      );

      focusNode.value?.addListener(() {
        if (!focusNode.value!.hasFocus) {
          coordinate.value = null;
          textField.value = null;
        }
      });
    }

    return Positioned.fill(
      child: AbsorbPointer(
        absorbing: mode != Mode.text,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (details) {
            if (textController.mode == TextMode.edit) {
              handleEditTap(details);
            }
            switch (textController.mode) {
              case TextMode.edit:
                handleEditTap(details);
                break;
              case TextMode.move:
                break;
            }
          },
          child: Stack(
            children: [
              // CustomPaint(
              //   painter: MyTextPainter(
              //     textItems: textController.textItems,
              //   ),
              // ),
              ...textController.textItems.asMap().entries.map(
                (entry) {
                  final item = entry.value;

                  return Positioned(
                    left: item.offset.dx,
                    top: item.offset.dy,
                    child: Draggable(
                      onDragUpdate: (details) {
                        textController.updateTextItem(
                          textController.textItems.indexOf(item),
                          details.localPosition,
                        );
                      },
                      childWhenDragging: const SizedBox.shrink(),
                      feedback: Material(
                        type: MaterialType.transparency,
                        child: Text(
                          item.text,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: item.size,
                          ),
                        ),
                      ),
                      child: Text(
                        item.text,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: item.size,
                        ),
                      ),
                    ),
                  );
                },
              ),
              if (textField.value != null)
                Positioned(
                  left: coordinate.value?.dx,
                  top: coordinate.value?.dy,
                  child: SizedBox(
                    width: 3000,
                    child: textField.value,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
