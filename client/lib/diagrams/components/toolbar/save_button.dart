import 'dart:async';

import 'package:client/authentication/components/sign_in_dialog.dart';
import 'package:client/authentication/controllers/auth_bloc.dart';
import 'package:client/authentication/models/auth_state.dart';
import 'package:client/diagrams/controllers/diagram_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SaveButton extends StatelessWidget {
  const SaveButton({super.key});

  @override
  Widget build(BuildContext context) {
    final DiagramCubit diagramCubit = context.watch<DiagramCubit>();
    final bool showIndicator = diagramCubit.hasUnsavedChanges;

    Widget iconWidget = const Icon(Icons.save);

    if (showIndicator) {
      iconWidget = Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.save),
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.surface,
                  width: 1.5,
                ),
              ),
              constraints: const BoxConstraints(minWidth: 10, minHeight: 10),
            ),
          ),
        ],
      );
    }

    return IconButton(
      icon: iconWidget,
      onPressed: () => unawaited(_handleSavePressed(context)),
      tooltip: 'Save Diagram',
    );
  }
}

Future<void> _handleSavePressed(BuildContext context) async {
  final AuthState authState = context.read<AuthCubit>().state;

  if (authState is AuthStateAuthenticated) {
    await _saveDiagram(context);
  } else {
    await _showSignInPrompt(context);
  }
}

Future<void> _saveDiagram(BuildContext context) =>
    context.read<DiagramCubit>().saveDiagram();

Future<void> _showSignInPrompt(BuildContext context) async {
  await showDialog<void>(
    context: context,
    builder:
        (dialogContext) => AlertDialog(
          title: const Text('Sign In Required'),
          content: const Text(
            'You need to be signed in to save your diagram. '
            'Would you like to sign in now?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                unawaited(
                  showDialog<void>(
                    context: context,
                    builder:
                        (signInContext) => BlocProvider.value(
                          value: context.read<AuthCubit>(),
                          child: const SignInDialog(),
                        ),
                  ),
                );
              },
              child: const Text('Sign In'),
            ),
          ],
        ),
  );
}
