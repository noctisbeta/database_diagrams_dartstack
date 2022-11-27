import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:database_diagrams/authentication/controllers/auth_store.dart';
import 'package:database_diagrams/collections/controllers/collection_store.dart';
import 'package:database_diagrams/logging/log_profile.dart';
import 'package:database_diagrams/projects/models/project.dart';
import 'package:database_diagrams/projects/models/project_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:functional/functional.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Project controller.
class ProjectController extends StateNotifier<ProjectState> {
  /// Default constructor.
  ProjectController(
    this._auth,
    this._db,
    this._collectionStore,
  ) : super(const ProjectState.initial());

  /// Firebase auth.
  final FirebaseAuth _auth;

  /// Firestore database.
  final FirebaseFirestore _db;

  /// Collection store.
  final CollectionStore _collectionStore;

  /// Provider.
  static final provider =
      StateNotifierProvider<ProjectController, ProjectState>(
    (ref) => ProjectController(
      FirebaseAuth.instance,
      FirebaseFirestore.instance,
      ref.watch(CollectionStore.provider.notifier),
    ),
  );

  /// Provides the project stream.
  static final projectStreamProvider =
      StreamProvider.autoDispose<List<Project>>(
    (ref) => ref.watch(AuthStore.provider).match(
          none: () => Stream.value([]),
          some: (user) => FirebaseFirestore.instance
              .collection('projects')
              .where(
                'userIds',
                arrayContains: user.uid,
              )
              .snapshots()
              .map(
                (snapshot) => snapshot.docs.map(Project.fromSnapshot).toList(),
              ),
        ),
  );

  // Future<Result<Object, Unit>> createOpenSave(String title) async =>
  //     createProject(title).then(
  //       (createEither) => createEither.map(
  //         (docref) => Task.fromVoid(() => docref.get()).attempt(),
  //       ),
  //     );

  Future<Result<Object, Unit>> createOpen(String title) =>
      createProject(title).then(
        (createEither) => createEither.bind(_getProjectFromReference),
      );

  Future<Result<Object, Project>> _getProjectFromReference(
    DocumentReference docref,
  ) async =>
      Task(() => docref.get())
          .attempt()
          .peekEitherLeft(
            (left) => myLog.e(
              'Error getting project from reference: $left',
            ),
          )
          .mapEitherRight(Project.fromSnapshot)
          .run();

  /// Creates a new project.
  Future<Result<Object, DocumentReference>> createProject(String title) async =>
      Task(
        () => _db.collection('projects').add(
              Project.forCreation(
                title: title,
                userIds: [_auth.currentUser!.uid],
                createdAt: FieldValue.serverTimestamp(),
              ),
            ),
      )
          .attempt()
          .peekEither(
            (exception) => () => myLog.e(
                  'Error creating project.',
                  exception,
                  StackTrace.current,
                ),
            (docref) => () => myLog.i('Created project $title.'),
          )
          .run();

  /// Attempts to save the currently opened project.
  Future<Result<Object, Unit>> handleSave() async => state.project.match(
        none: () => const Err('No project is currently open.'),
        some: _saveSaveables,
      );

  /// Saves all of the saveable data in the currently opened project.
  Future<Result<Object, Unit>> _saveSaveables(Project project) =>
      _saveCollections(project.id);

  /// Saves all of the collections in the currently opened project.
  Future<Result<Object, Unit>> _saveCollections(String projectId) =>
      Task.fromVoid(
        () => _db
            .collection('projects')
            .doc(projectId)
            .collection('saveData')
            .doc('collections')
            .set({'data': _collectionStore.serialize()}),
      )
          .attempt()
          .peek(
            (either) => either.match(
              (exception) => myLog.e(
                'Error saving collections.',
                exception,
                StackTrace.current,
              ),
              (_) => myLog.i('Saved collections.'),
            ),
          )
          .run();

  /// Sets the project.
  Unit openProject(Project project) {
    state = state.copyWith(project: Some(project));
    myLog.d('Opened project ${project.title}.');

    return unit;
  }
}
