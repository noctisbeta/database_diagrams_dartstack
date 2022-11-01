import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Google sign in controller.
class GoogleControllerWeb {
  /// Provides the controller.
  static final provider = Provider.autoDispose<GoogleControllerWeb>(
    (ref) => GoogleControllerWeb(),
  );

  /// Sign in with google and return the account if successful.
  Future<void> signInWithGoogle() async {
    final auth = FirebaseAuth.instance;
    final User? user;

    // The `GoogleAuthProvider` can only be used while running on the web
    final GoogleAuthProvider authProvider = GoogleAuthProvider();

    try {
      final UserCredential userCredential = await auth.signInWithPopup(authProvider);

      user = userCredential.user;
    } catch (e) {
      log('Error $e');
    }
  }
}
