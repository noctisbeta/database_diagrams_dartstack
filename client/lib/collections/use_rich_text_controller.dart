// import 'package:database_diagrams/collections/rich_text_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_hooks/flutter_hooks.dart';

// class _RichTextControllerHookCreator {
//   const _RichTextControllerHookCreator();

//   RichTextController call({String? text, List<Object?>? keys}) {
//     return use(_RichTextControllerHook(text, keys));
//   }

//   /// Creates a [TextEditingController] from the initial [value] that will
//   /// be disposed automatically.
//   TextEditingController fromValue(
//     TextEditingValue value, [
//     List<Object?>? keys,
//   ]) {
//     return use(_RichTextControllerHook.fromValue(value, keys));
//   }
// }

// const useTextEditingController = _RichTextControllerHookCreator();

// class _RichTextControllerHook extends Hook<TextEditingController> {
//   const _RichTextControllerHook(
//     this.initialText, [
//     List<Object?>? keys,
//   ])  : initialValue = null,
//         super(keys: keys);

//   const _RichTextControllerHook.fromValue(
//     TextEditingValue this.initialValue, [
//     List<Object?>? keys,
//   ])  : initialText = null,
//         super(keys: keys);

//   final String? initialText;
//   final TextEditingValue? initialValue;

//   @override
//   _RichTextControllerHookState createState() {
//     return _RichTextControllerHookState();
//   }
// }

// class _RichTextControllerHookState extends HookState<TextEditingController, _RichTextControllerHook> {
//   late final _controller =
//       hook.initialValue != null ? TextEditingController.fromValue(hook.initialValue) : TextEditingController(text: hook.initialText);

//   @override
//   TextEditingController build(BuildContext context) => _controller;

//   @override
//   void dispose() => _controller.dispose();

//   @override
//   String get debugLabel => 'useTextEditingController';
// }
