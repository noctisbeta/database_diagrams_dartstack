import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Login button.
class LoginButton extends StatelessWidget {
  /// Default constructor.
  const LoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final auth = FirebaseAuth.instance;
        final User? user;

        // The `GoogleAuthProvider` can only be used while running on the web
        final GoogleAuthProvider authProvider = GoogleAuthProvider();

        try {
          final UserCredential userCredential = await auth.signInWithPopup(authProvider);

          user = userCredential.user;
        } catch (e) {
          print(e);
        }
      },
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
