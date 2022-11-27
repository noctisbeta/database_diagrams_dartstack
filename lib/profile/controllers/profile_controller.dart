import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:database_diagrams/authentication/controllers/auth_store.dart';
import 'package:database_diagrams/logging/log_profile.dart';
import 'package:database_diagrams/profile/models/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:functional/functional.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Profile controller.
class ProfileController {
  /// Default constructor.
  ProfileController(
    this._auth,
    this._db,
    this._authStore,
  );

  /// Provides the controller.
  static final provider = Provider.autoDispose<ProfileController>(
    (ref) => ProfileController(
      FirebaseAuth.instance,
      FirebaseFirestore.instance,
      ref.watch(AuthStore.provider.notifier),
    ),
  );

  /// Firebase auth.
  final FirebaseAuth _auth;

  /// Firestore database.
  final FirebaseFirestore _db;

  /// Auth store.
  final AuthStore _authStore;

  /// Provides the profile stream.
  static final profileStreamProvider = StreamProvider.autoDispose(
    (ref) => ref.watch(AuthStore.provider).match(
          none: () => Stream.value(Profile.empty()),
          some: (user) => FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots()
              .map(
                Profile.fromSnapshot,
              ),
        ),
  );

  /// Creates a new profile.
  Future<Either<Exception, Unit>> createProfileFromUserCredential(
    UserCredential userCredential,
  ) async =>
      Task.fromVoid(
        () => _db.collection('users').doc(userCredential.user!.uid).set(
          {
            'firstName': userCredential.user!.displayName!.split(' ')[0],
            'lastName': userCredential.user!.displayName!.split(' ')[1],
            'email': userCredential.user!.email,
            'createdAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        ),
      ).attempt<Exception>().run().then(
            (either) => either.match(
              (exception) => withEffect(
                left(exception),
                () => myLog.e(
                  'Error creating profile.',
                  exception,
                  StackTrace.current,
                ),
              ),
              (unit) => withEffect(
                right(unit),
                () => myLog.i('Created profile.'),
              ),
            ),
          );

  /// Creates a user document in firestore.
  Future<bool> createProfileFromMap(Map<String, dynamic> map) async {
    final user = {
      'firstName': map['firstName'],
      'lastName': map['lastName'],
      'email': map['email'],
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      await _db.collection('users').doc(map['uid']).set(
            user,
            SetOptions(merge: true),
          );

      myLog.i('Profile created: $user');
      return true;
    } on FirebaseException catch (e) {
      myLog.e('Error creating profile: ${e.message}', e, StackTrace.current);
      return false;
    }
  }

  /// Signs the user out.
  Future<void> signOut() async {
    await _auth.signOut();
    myLog.i('Signed out the user.');
  }

  OverlayEntry? _profileMenuEntry;

  /// Is profile menu open.
  bool get isProfileMenuOpen => _profileMenuEntry != null;

  /// Show overlay.
  void showProfileMenu(BuildContext context, OverlayEntry entry) {
    _profileMenuEntry = entry;
    Overlay.of(context)!.insert(_profileMenuEntry!);
  }

  /// Hide overlay.
  void closeProfileMenu() {
    _profileMenuEntry?.remove();
    _profileMenuEntry = null;
  }

  /// Returns true if the user already has a profile.
  Future<bool> userHasProfile() async {
    return _authStore.user.match(
      none: () => withEffect(false, () => myLog.e('User is not logged in')),
      some: (user) => _db.collection('users').doc(user.uid).get().then(
            (value) => value.exists.match(
              ifFalse: () => withEffect(
                false,
                () => myLog.i('User does not have a profile'),
              ),
              ifTrue: () =>
                  withEffect(true, () => myLog.i('User has a profile')),
            ),
          ),
    );
  }
}
