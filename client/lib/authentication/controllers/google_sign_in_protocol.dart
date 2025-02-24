import 'package:database_diagrams/authentication/models/google_sign_in_exception.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:functional/functional.dart';

/// Google sign in protocol.
// ignore: one_member_abstracts
abstract class GoogleSignInProtocol {
  /// Sign in with google and return the account or user credential if
  /// successful.
  Future<Either<GoogleSignInException, UserCredential>> signInWithGoogle();
}
