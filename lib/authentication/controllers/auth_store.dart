import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Auth store.
class AuthStore extends StateNotifier<User?> {
  /// Default constructor.
  AuthStore(
    this.ref,
    this.auth,
  ) : super(null) {
    auth.authStateChanges().listen((user) {
      state = user;
    });
  }

  /// Riverpod reference.
  final Ref ref;

  /// Auth.
  FirebaseAuth auth;

  /// Provider.
  static final provider = StateNotifierProvider<AuthStore, User?>(
    (ref) {
      return AuthStore(
        ref,
        FirebaseAuth.instance,
      );
    },
  );

  /// Is logged in.
  bool get isLoggedIn => state != null;
}
