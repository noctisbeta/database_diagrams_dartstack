import 'package:client/authentication/controllers/auth_bloc.dart';
import 'package:client/authentication/models/auth_event.dart';
import 'package:client/authentication/models/auth_state.dart';
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
  final _formKey = GlobalKey<FormState>();
  bool _isObscured = true;
  bool _isRegistering = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final String username = _usernameController.text;
      final String password = _passwordController.text;

      if (username.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all fields')),
        );
        return;
      }

      if (_isRegistering) {
        final String confirmPassword = _confirmPasswordController.text;
        if (password != confirmPassword) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Passwords do not match')),
          );
          return;
        }

        context.read<AuthBloc>().add(
          AuthEventRegister(username: username, password: password),
        );
      } else {
        context.read<AuthBloc>().add(
          AuthEventLogin(username: username, password: password),
        );
      }
    }
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
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
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
                textInputAction:
                    _isRegistering
                        ? TextInputAction.next
                        : TextInputAction.done,
                onFieldSubmitted: (_) {
                  if (!_isRegistering) {
                    _submitForm();
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
              ),
              if (_isRegistering) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscured ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed:
                          () => setState(() => _isObscured = !_isObscured),
                    ),
                  ),
                  obscureText: _isObscured,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submitForm(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 16),
              TextButton(
                onPressed:
                    () => setState(() => _isRegistering = !_isRegistering),
                child: Text(
                  _isRegistering
                      ? 'Already have an account? Sign in'
                      : "Don't have an account? Register",
                ),
              ),
            ],
          ),
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
                onPressed: state is AuthStateLoading ? null : _submitForm,
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
