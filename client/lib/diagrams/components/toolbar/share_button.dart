import 'dart:async';

import 'package:client/authentication/controllers/auth_bloc.dart';
import 'package:client/authentication/models/auth_state.dart';
import 'package:client/diagrams/controllers/diagram_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ShareButton extends StatelessWidget {
  const ShareButton({super.key});

  Future<void> _showLoginGuard(BuildContext context) => showDialog(
    context: context,
    builder:
        (dialogContext) => AlertDialog(
          title: const Text('Login Required'),
          content: const Text(
            'You must be logged in to share diagrams. Consider '
            'exporting instead.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
  );

  Future<void> _handleTap(BuildContext context) async {
    final AuthState authState = context.read<AuthCubit>().state;

    if (authState is! AuthStateAuthenticated) {
      return _showLoginGuard(context);
    }

    final String? shortcode = await context.read<DiagramCubit>().shareDiagram();

    void onSuccess() {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Shareable shortcode copied to clipboard!'),
        ),
      );
    }

    void onError() {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to generate shareable shortcode.'),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (shortcode != null) {
      await Clipboard.setData(ClipboardData(text: shortcode));
      if (!context.mounted) {
        return;
      }
      onSuccess();
    } else if (context.mounted) {
      onError();
    }
  }

  @override
  Widget build(BuildContext context) => IconButton(
    icon: const Icon(Icons.share),
    tooltip: 'Share Diagram',
    onPressed: () => unawaited(_handleTap(context)),
  );
}
