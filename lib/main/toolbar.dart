import 'package:database_diagrams/authentication/login_button.dart';
import 'package:database_diagrams/collections/compiler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Toolbar.
class Toolbar extends HookConsumerWidget {
  /// Default constructor.
  const Toolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 40,
      color: Colors.orange.shade700,
      child: Row(
        children: [
          const SizedBox(
            width: 16,
          ),
          const Text(
            'Save',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          const SizedBox(
            width: 16,
          ),
          const Text(
            'Export',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          const SizedBox(
            width: 16,
          ),
          GestureDetector(
            onTapUp: (details) {
              ref.read(Compiler.provider.notifier).toggleOverlay(details, context);
            },
            child: const Text(
              'Code editor',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
          const Spacer(),
          const LoginButton(),
          const SizedBox(
            width: 16,
          ),
        ],
      ),
    );
  }
}
