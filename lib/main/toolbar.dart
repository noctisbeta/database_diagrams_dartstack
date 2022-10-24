import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Toolbar.
class Toolbar extends StatelessWidget {
  /// Default constructor.
  const Toolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      color: Colors.orange.shade700,
      child: Row(
        children: [
          const SizedBox(
            width: 16,
          ),
          const Text(
            'Save',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          const SizedBox(
            width: 16,
          ),
          const Text(
            'Export',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () async {
              final _auth = FirebaseAuth.instance;
              final User? user;

              // The `GoogleAuthProvider` can only be used while running on the web
              final GoogleAuthProvider authProvider = GoogleAuthProvider();

              try {
                final UserCredential userCredential = await _auth.signInWithPopup(authProvider);

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
          ),
          const SizedBox(
            width: 16,
          ),
        ],
      ),
    );
  }
}
