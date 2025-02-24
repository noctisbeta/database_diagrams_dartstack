import 'package:database_diagrams/authentication/sign_in_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Login button.
class SignInButton extends HookWidget {
  /// Default constructor.
  const SignInButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isHovering = useState(false);

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => const Center(child: SignInDialog()),
        );
      },
      child: MouseRegion(
        onEnter: (event) {
          isHovering.value = true;
        },
        onExit: (event) {
          isHovering.value = false;
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: isHovering.value ? Colors.orange.shade900 : Colors.orange.shade700,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Sign in',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}
