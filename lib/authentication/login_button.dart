import 'package:flutter/material.dart';

/// Login button.
class LoginButton extends StatelessWidget {
  /// Default constructor.
  const LoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {},
      child: const Text(
        'Login',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
    );
  }
}
