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
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(Compiler.provider);
    final controller = ref.watch(Compiler.provider.notifier);

    final collectionsTextCtl = useState(
      RichTextController(
        stringMatchMap: <String, TextStyle>{
          'Collection': TextStyle(color: Colors.orange.shade700),
        },
        onMatch: (match) {},
      ),
    );

    final relationsTextCtl = useState(
      RichTextController(
        stringMatchMap: <String, TextStyle>{
          'Relation': TextStyle(color: Colors.orange.shade700),
        },
        onMatch: (match) {},
      ),
    );

    final tabController = useTabController(initialLength: 2);

    useEffect(
      () {
        final prevSelectionColl = collectionsTextCtl.value.selection;
        final prevSelectionRel = relationsTextCtl.value.selection;

        collectionsTextCtl.value.text = state.collections;
        relationsTextCtl.value.text = state.relations;

        if (prevSelectionColl.isValid) {
          collectionsTextCtl.value.selection = prevSelectionColl;
        }

        if (prevSelectionRel.isValid) {
          relationsTextCtl.value.selection = prevSelectionRel;
        }

        return;
      },
      [state],
    );

    return Stack(
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
              TabBar(
                controller: tabController,
                indicatorColor: Colors.orange.shade700,
                labelStyle: const TextStyle(
                  fontSize: 18,
                ),
                tabs: const [
                  Tab(text: 'Collections'),
                  Tab(text: 'Relations'),
                ],
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(40, 40, 40, 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TabBarView(
                    controller: tabController,
                    children: [
                      TextField(
                        controller: collectionsTextCtl.value,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        cursorColor: Colors.white,
                        style: const TextStyle(
                          color: Colors.white,
                          height: 1.5,
                        ),
                        decoration: const InputDecoration.collapsed(
                          hintText: '',
                        ),
                      ),
                      TextField(
                        controller: relationsTextCtl.value,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        cursorColor: Colors.white,
                        style: const TextStyle(
                          color: Colors.white,
                          height: 1.5,
                        ),
                        decoration: const InputDecoration.collapsed(
                          hintText: '',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              GestureDetector(
                onTap: () {
                  tabController.index == 0
                      ? controller.saveCollections(collectionsTextCtl.value.text)
                      : controller.saveRelations(
                          relationsTextCtl.value.text,
                        );
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
            ],
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(
            onTap: controller.closeOverlay,
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
      ],
    );
  }
}


/*

Collection users {
  id                  int,
  name             string,
  email            string,
  password         string,
  created_at     datetime,
  updated_at     datetime,
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
