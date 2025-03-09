import 'dart:async';

import 'package:client/authentication/controllers/auth_bloc.dart';
import 'package:client/authentication/models/auth_event.dart';
import 'package:client/authentication/models/auth_state.dart';
import 'package:client/widgets/sign_in_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Toolbar extends StatelessWidget {
  const Toolbar({required this.onSave, super.key});

  final VoidCallback onSave;

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
        BlocBuilder<AuthBloc, AuthState>(
          builder:
              (context, state) => FilledButton.icon(
                onPressed:
                    state is AuthStateLoading
                        ? null
                        : () =>
                            state is AuthStateAuthenticated
                                ? context.read<AuthBloc>().add(
                                  const AuthEventLogout(),
                                )
                                : unawaited(
                                  showDialog<void>(
                                    context: context,
                                    builder:
                                        (dialogContext) => BlocProvider.value(
                                          value: context.read<AuthBloc>(),
                                          child: const SignInDialog(),
                                        ),
                                  ),
                                ),

                icon:
                    state is AuthStateLoading
                        ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : Icon(
                          state is AuthStateAuthenticated
                              ? Icons.logout
                              : Icons.login,
                        ),
                label: Text(
                  state is AuthStateLoading
                      ? 'Please wait...'
                      : state is AuthStateAuthenticated
                      ? 'Sign Out'
                      : 'Sign In',
                ),
              ),
        ),
      ],
    ),
  );
}
