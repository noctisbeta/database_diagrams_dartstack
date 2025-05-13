import 'dart:async';

import 'package:client/authentication/components/sign_in_dialog/sign_in_dialog.dart';
import 'package:client/authentication/controllers/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignInSection extends StatelessWidget {
  const SignInSection({super.key});

  void _showSignInDialog(BuildContext context) {
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder:
            (dialogContext) => BlocProvider.value(
              value: context.read<AuthCubit>(),
              child: const SignInDialog(),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Text(
            'Access Your Diagrams',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'Sign in to save and access your diagrams across devices',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _showSignInDialog(context),
            icon: const Icon(Icons.login),
            label: const Text('Sign In or Create Account'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    ),
  );
}
