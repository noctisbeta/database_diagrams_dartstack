import 'package:database_diagrams/authentication/components/profile_avatar.dart';
import 'package:database_diagrams/authentication/controllers/auth_store.dart';
import 'package:database_diagrams/authentication/sign_in_button.dart';
import 'package:database_diagrams/collections/controllers/compiler.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Toolbar.
class Toolbar extends HookConsumerWidget {
  /// Default constructor.
  const Toolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(AuthStore.provider);

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
          if (user != null) ...[
            const Icon(
              Icons.notifications,
              color: Colors.white,
            ),
            const SizedBox(
              width: 16,
            ),
          ],
          if (user == null)
            const SignInButton()
          else
            const ProfileAvatar(
              child: Text('JE'),
            ),
          const SizedBox(
            width: 16,
          ),
        ],
      ),
    );
  }
}
