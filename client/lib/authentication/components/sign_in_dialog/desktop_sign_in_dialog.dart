import 'dart:async';

import 'package:client/authentication/controllers/auth_bloc.dart';
import 'package:client/authentication/models/auth_state.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class DesktopSignInDialog extends StatefulWidget {
  const DesktopSignInDialog({super.key});

  @override
  State<DesktopSignInDialog> createState() => _DesktopSignInDialogState();
}

class _DesktopSignInDialogState extends State<DesktopSignInDialog> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isObscured = true;
  bool _isRegistering = false;
  String? _errorMessage;
  bool _agreedToTerms = false; // New state variable for terms agreement

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final String username = _usernameController.text;
      final String password = _passwordController.text;

      if (_isRegistering) {
        if (!_agreedToTerms) {
          // Check for terms agreement
          setState(() {
            _errorMessage =
                'You must agree to the Terms of Service and '
                'Privacy Policy to register.';
          });
          return;
        }

        await context.read<AuthCubit>().register(username, password);
      } else {
        await context.read<AuthCubit>().login(username, password);
      }
    }
  }

  @override
  Widget build(BuildContext context) => BlocListener<AuthCubit, AuthState>(
    listener: (context, state) {
      if (state is AuthStateAuthenticated) {
        Navigator.pop(context);
      } else if (state is AuthStateError) {
        setState(() {
          _errorMessage = state.message;
        });
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
                onFieldSubmitted: (_) async {
                  if (!_isRegistering) {
                    await _submitForm();
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
                  onFieldSubmitted: (_) => unawaited(_submitForm()),
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
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: [
                        const TextSpan(text: 'I agree to the '),
                        TextSpan(
                          text: 'Terms of Service',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer:
                              TapGestureRecognizer()
                                ..onTap = () async {
                                  final Uri url = Uri.parse(
                                    'https://diagrams.fractalfable.com/terms-of-service.html',
                                  );
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(
                                      url,
                                      webOnlyWindowName: '_blank',
                                    ); // Opens in a new tab
                                  } else {
                                    // Handle error: could not launch URL
                                    if (!context.mounted) {
                                      return;
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Could not open Terms of Service.',
                                        ),
                                      ),
                                    );
                                  }
                                },
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer:
                              TapGestureRecognizer()
                                ..onTap = () async {
                                  final Uri url = Uri.parse(
                                    'https://diagrams.fractalfable.com/privacy-policy.html',
                                  );
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(
                                      url,
                                      webOnlyWindowName: '_blank',
                                    ); // Opens in a new tab
                                  } else {
                                    // Handle error
                                    if (!context.mounted) {
                                      return;
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Could not open Privacy Policy.',
                                        ),
                                      ),
                                    );
                                  }
                                },
                        ),
                        const TextSpan(text: '.'),
                      ],
                    ),
                  ),
                  value: _agreedToTerms,
                  onChanged: (bool? newValue) {
                    setState(() {
                      _agreedToTerms = newValue ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  subtitle:
                      !_agreedToTerms &&
                              _formKey.currentState?.validate() == false &&
                              _errorMessage != null &&
                              _errorMessage!.contains('You must agree')
                          ? Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'This field is required.',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 12,
                              ),
                            ),
                          )
                          : null,
                ),
              ],
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isRegistering = !_isRegistering;
                    _errorMessage = null; // Clear error message
                    _agreedToTerms = false; // Reset terms agreement
                    _formKey.currentState?.reset(); // Reset form validation
                  });
                },
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
        BlocBuilder<AuthCubit, AuthState>(
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
