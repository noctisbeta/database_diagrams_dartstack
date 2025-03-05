import 'dart:async';

import 'package:database_diagrams_client/widgets/sign_in_dialog.dart';
import 'package:flutter/material.dart';

class Toolbar extends StatelessWidget {
  const Toolbar({required this.onSave, required this.onSignIn, super.key});

  final VoidCallback onSave;
  final VoidCallback onSignIn;

  Future<void> _showSignInDialog(BuildContext context) async {
    final Map<String, String>? result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const SignInDialog(),
    );

    if (result != null) {
      onSignIn();
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    height: 60,
    color: Colors.grey[200],
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        IconButton(
          icon: const Icon(Icons.save),
          onPressed: onSave,
          tooltip: 'Save Diagram',
        ),
        const Spacer(),
        FilledButton.icon(
          onPressed: () => unawaited(_showSignInDialog(context)),
          icon: const Icon(Icons.login),
          label: const Text('Sign In'),
        ),
      ],
    ),
  );
}
