import 'package:database_diagrams_client/authentication/controllers/auth_bloc.dart';
import 'package:database_diagrams_client/authentication/models/auth_event.dart';
import 'package:database_diagrams_client/authentication/models/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignInDialog extends StatefulWidget {
  const SignInDialog({super.key});

  @override
  State<SignInDialog> createState() => _SignInDialogState();
}

class _SignInDialogState extends State<SignInDialog> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isObscured = true;
  bool _isRegistering = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocListener<AuthBloc, AuthState>(
    listener: (context, state) {
      if (state is AuthStateAuthenticated) {
        Navigator.pop(context);
      } else if (state is AuthStateError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.message)));
      }
    },
    child: AlertDialog(
      title: Text(_isRegistering ? 'Register' : 'Sign In'),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isObscured ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () => setState(() => _isObscured = !_isObscured),
                ),
              ),
              obscureText: _isObscured,
            ),
            if (_isRegistering) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscured ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () => setState(() => _isObscured = !_isObscured),
                  ),
                ),
                obscureText: _isObscured,
              ),
            ],
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => setState(() => _isRegistering = !_isRegistering),
              child: Text(
                _isRegistering
                    ? 'Already have an account? Sign in'
                    : "Don't have an account? Register",
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        BlocBuilder<AuthBloc, AuthState>(
          builder:
              (context, state) => FilledButton(
                onPressed:
                    state is AuthStateLoading
                        ? null
                        : () {
                          final String username = _usernameController.text;
                          final String password = _passwordController.text;

                          if (username.isEmpty || password.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill in all fields'),
                              ),
                            );
                            return;
                          }

                          if (_isRegistering) {
                            final String confirmPassword =
                                _confirmPasswordController.text;
                            if (password != confirmPassword) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Passwords do not match'),
                                ),
                              );
                              return;
                            }

                            context.read<AuthBloc>().add(
                              AuthEventRegister(
                                username: username,
                                password: password,
                              ),
                            );
                          } else {
                            context.read<AuthBloc>().add(
                              AuthEventLogin(
                                username: username,
                                password: password,
                              ),
                            );
                          }
                        },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (state is AuthStateLoading)
                      const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    Text(_isRegistering ? 'Register' : 'Sign In'),
                  ],
                ),
              ),
        ),
      ],
    ),
  );
}
