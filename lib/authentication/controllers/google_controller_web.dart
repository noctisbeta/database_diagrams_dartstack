import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Google sign in controller.
class GoogleControllerWeb {
  /// Default constructor.
  const GoogleControllerWeb(this.auth);

  /// Auth.
  final FirebaseAuth auth;

  /// Provides the controller.
  static final provider = Provider.autoDispose<GoogleControllerWeb>(
    (ref) => GoogleControllerWeb(FirebaseAuth.instance),
  );

  /// Sign in with google and return the account if successful.
  Future<Either<Exception, UserCredential>> signInWithGoogle() async {
    final GoogleAuthProvider authProvider = GoogleAuthProvider();

    try {
      final UserCredential userCredential = await auth.signInWithPopup(authProvider);

      return Right(userCredential);
    } on Exception catch (e) {
      log('Exception $e');
      return Left(e);
    }
  }
}
