import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:database_diagrams/projects/project.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Project controller.
class ProjectController extends StateNotifier<Project?> {
  /// Default constructor.
  ProjectController({
    required this.ref,
    required this.auth,
    required this.db,
  }) : super(null);

  /// Riverpod reference.
  final Ref ref;

  /// Firebase auth.
  final FirebaseAuth auth;

  /// Firestore database.
  final FirebaseFirestore db;

  /// Provider.
  static final provider = StateNotifierProvider<ProjectController, Project?>(
    (ref) {
      return ProjectController(
        ref: ref,
        auth: FirebaseAuth.instance,
        db: FirebaseFirestore.instance,
      );
    },
  );

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

  /// Creates a new project.
  Future<bool> createProject(String title) async {
    final project = Project(
      title: title,
      userIds: [auth.currentUser!.uid],
      createdAt: Timestamp.now(),
    );
    try {
      await db.collection('projects').add(
            project.toMap(),
          );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Set the current project.
}
