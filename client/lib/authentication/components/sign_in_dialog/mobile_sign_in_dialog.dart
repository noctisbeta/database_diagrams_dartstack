import 'dart:async';

import 'package:client/authentication/controllers/auth_bloc.dart';
import 'package:client/authentication/models/auth_state.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class MobileSignInDialog extends StatefulWidget {
  const MobileSignInDialog({super.key});

  @override
  State<MobileSignInDialog> createState() => _MobileSignInDialogState();
}

class _MobileSignInDialogState extends State<MobileSignInDialog> {
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
                'You must agree to the Terms of Service and'
                ' Privacy Policy to register.';
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
  Widget build(BuildContext context) => Dialog.fullscreen(
    child: Scaffold(
      appBar: AppBar(
        title: Text(_isRegistering ? 'Register' : 'Sign In'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthStateAuthenticated) {
            Navigator.pop(context); // Close the dialog on successful auth
          } else if (state is AuthStateError) {
            setState(() {
              _errorMessage = state.message;
            });
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Welcome',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
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
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscured
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed:
                              () => setState(() => _isObscured = !_isObscured),
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
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscured
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed:
                                () =>
                                    setState(() => _isObscured = !_isObscured),
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
                      const SizedBox(
                        height: 16,
                      ), // Add spacing before the checkbox
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
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Could not open Terms'
                                                ' of Service.',
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
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Could not open Privacy '
                                                'Policy.',
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
                        controlAffinity:
                            ListTileControlAffinity
                                .leading, // Places checkbox first
                        dense: true,
                        contentPadding: EdgeInsets.zero, // Remove extra padding
                        subtitle:
                            !_agreedToTerms &&
                                    _formKey.currentState?.validate() ==
                                        false &&
                                    _errorMessage != null &&
                                    _errorMessage!.contains('You must agree')
                                ? Padding(
                                  // Show error only if this
                                  // specific validation fails
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'This field is required.',
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.error,
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
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isRegistering = !_isRegistering;
                          _errorMessage = null;
                          _agreedToTerms = false; // Reset terms
                          // agreement when switching modes
                          _formKey.currentState?.reset();
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
            // Actions at the bottom
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('CANCEL'),
                  ),
                  const SizedBox(width: 8),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder:
                        (context, state) => FilledButton(
                          onPressed:
                              state is AuthStateLoading ? null : _submitForm,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (state is AuthStateLoading)
                                const Padding(
                                  padding: EdgeInsets.only(right: 8),
                                  child: SizedBox.square(
                                    dimension: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              Text(_isRegistering ? 'REGISTER' : 'SIGN IN'),
                            ],
                          ),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
