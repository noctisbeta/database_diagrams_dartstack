import 'dart:developer';

import 'package:database_diagrams/collections/compiler.dart';
import 'package:database_diagrams/collections/rich_text_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Code editor.
class CodeEditor extends HookConsumerWidget {
  /// Default constructor.
  const CodeEditor({
    required this.onClose,
    required this.onSave,
    super.key,
  });

  /// on close.
  final void Function() onClose;

  /// on save.
  final void Function(String) onSave;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(Compiler.provider);

    final textController = useTextEditingController();

    final richTextController = useState(
      RichTextController(
        stringMatchMap: <String, TextStyle>{
          'Collection': const TextStyle(color: Colors.blue),
        },
        onMatch: (match) {
          log(match.toString());
        },
      ),
    );

    final focusNode = useFocusNode();

    useEffect(
      () {
        textController.text = state;
        richTextController.value.text = state;

        return;
      },
      [state],
    );

    final tabController = useTabController(initialLength: 1);

    return DefaultTabController(
      length: 2,
      child: Stack(
        children: [
          Container(
            width: 400,
            height: 500,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(50, 50, 50, 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: 'Collections'),
                    Tab(text: 'Relations'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      TextField(
                        focusNode: focusNode,
                        controller: richTextController.value,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        cursorColor: Colors.white,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        decoration: const InputDecoration.collapsed(
                          hintText: '',
                        ),
                      ),
                      TextField(
                        focusNode: focusNode,
                        controller: richTextController.value,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        cursorColor: Colors.white,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        decoration: const InputDecoration.collapsed(
                          hintText: '',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: onClose,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // save button
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                onSave(textController.text);
                log('ontap');
              },
              child: Container(
                width: 100,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.orange.shade700,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


/*

Collection users {
  id:                 int,
  name:            string,
  email:           string,
  password:        string,
  created_at:    datetime,
  updated_at:     datetime,
}

Collection users:
  id: int,
  name: string,
  email: string,
  password: string,
  created_at: datetime,
  updated_at: datetime,



Relation<users, posts>:
  user_id: int,
  post_id: int,


*/
