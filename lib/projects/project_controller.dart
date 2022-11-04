import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:database_diagrams/projects/project.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Project controller.
class ProjectController {
  /// Default constructor.
  const ProjectController({
    required this.ref,
    required this.auth,
    required this.db,
  });

  /// Riverpod reference.
  final Ref ref;

  /// Firebase auth.
  final FirebaseAuth auth;

  /// Firestore database.
  final FirebaseFirestore db;

  /// Provides the project stream.
  static final projectStreamProvider = StreamProvider.autoDispose((ref) {
    final db = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;

    return db
        .collection('projects')
        .where(
          'userIds',
          arrayContains: auth.currentUser!.uid,
        )
        .snapshots()
        .map(
      (snapshot) {
        return snapshot.docs.map(Project.fromSnapshot).toList();
      },
    );
  });
}
