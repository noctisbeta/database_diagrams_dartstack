import 'package:database_diagrams/authentication/controllers/login_controller.dart';
import 'package:database_diagrams/main/my_text_field.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sign_in_button/sign_in_button.dart';

/// Sign in dialog.
class SignInDialog extends ConsumerWidget {
  /// Default constructor.
  const SignInDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 16,
            ),
            const Text(
              'Sign in',
              style: TextStyle(
                fontSize: 24,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            const MyTextField(label: 'Email'),
            const SizedBox(
              height: 16,
            ),
            const MyTextField(label: 'Password'),
            const SizedBox(
              height: 16,
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 1,
                    color: Colors.black.withOpacity(0.3),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'OR',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 1,
                    color: Colors.black.withOpacity(0.3),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            SignInButton(
              Buttons.googleDark,
              onPressed: () => ref
                  .read(LoginController.provider.notifier)
                  .signInWithGoogle(),
            )
          ],
        ),
      ),
    );
  }
}
