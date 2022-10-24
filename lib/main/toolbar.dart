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
          SizedBox(
            width: 16,
          ),
          Text(
            'Save',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          SizedBox(
            width: 16,
          ),
          Text(
            'Export',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          Spacer(),
          GestureDetector(
            onTap: () async {
              final _auth = FirebaseAuth.instance;
              User? user;

              // The `GoogleAuthProvider` can only be used while running on the web
              GoogleAuthProvider authProvider = GoogleAuthProvider();

              try {
                final UserCredential userCredential = await _auth.signInWithPopup(authProvider);

                user = userCredential.user;
              } catch (e) {
                print(e);
              }
            },
            child: Text(
              'Login',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
          SizedBox(
            width: 16,
          ),
        ],
      ),
    );
  }
}
