import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:database_diagrams/projects/models/project.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:functional/functional.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';

/// Project controller.
class ProjectController extends StateNotifier<Option<Project>> {
  /// Default constructor.
  ProjectController(
    this.auth,
    this.db,
  ) : super(const None());

  /// Firebase auth.
  final FirebaseAuth auth;

  /// Firestore database.
  final FirebaseFirestore db;

  /// Provider.
  static final provider =
      StateNotifierProvider<ProjectController, Option<Project>>(
    (ref) => ProjectController(
      FirebaseAuth.instance,
      FirebaseFirestore.instance,
    ),
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
  Future<bool> createProject(String title) async => Task(
        () => db.collection('projects').add(
          {
            'title': title,
            'userIds': [auth.currentUser!.uid],
            'createdAt': FieldValue.serverTimestamp(),
          },
        ),
      ).attempt().run().then(
            (either) => either.match(
              (exception) => withEffect(
                false,
                () => Logger().e(
                  'Error creating project.',
                  exception,
                  StackTrace.current,
                ),
              ),
              (_) => withEffect(
                true,
                () => Logger().i('Created project $title.'),
              ),
            ),
          );
}
