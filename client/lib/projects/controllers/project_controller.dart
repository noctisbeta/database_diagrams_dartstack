import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:database_diagrams/authentication/controllers/auth_store.dart';
import 'package:database_diagrams/collections/controllers/collection_store.dart';
import 'package:database_diagrams/firebase/firebase_paths.dart';
import 'package:database_diagrams/logging/log_profile.dart';
import 'package:database_diagrams/projects/models/project.dart';
import 'package:database_diagrams/projects/models/project_state.dart';
import 'package:database_diagrams/smartline/smartline_controller.dart';
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
    this._smartlineController,
  ) : super(const ProjectState.initial());

  /// Firebase auth.
  final FirebaseAuth _auth;

  /// Firestore database.
  final FirebaseFirestore _db;

  /// Collection store.
  final CollectionStore _collectionStore;

  /// Smartline controller.
  final SmartlineController _smartlineController;

  /// Provider.
  static final provider =
      StateNotifierProvider<ProjectController, ProjectState>(
    (ref) => ProjectController(
      FirebaseAuth.instance,
      FirebaseFirestore.instance,
      ref.watch(CollectionStore.provider.notifier),
      ref.watch(SmartlineController.provider.notifier),
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

  /// Creates a new project, opens it, and saves it.
  Task<Result<Object, Unit>> createOpenSave(String title) =>
      _createOpen(title).peekEitherRight((_) => handleSave());

  /// Creates a new project and opens it.
  Task<Result<Object, Unit>> _createOpen(String title) => createProject(title)
      .bindEither(_getProjectFromReference)
      .peekEitherRight(openProject)
      .mapEitherRight((project) => unit);

  /// Fetches a project from a reference.
  Task<Result<Object, Project>> _getProjectFromReference(
    DocumentReference docref,
  ) =>
      Task(() => docref.get())
          .attempt()
          .peekEitherLeft(
            (exception) => myLog.e(
              'Error getting project from reference: $exception',
            ),
          )
          .mapEitherRight(Project.fromSnapshot);

  /// Creates a new project.
  Task<Result<Object, DocumentReference>> createProject(String title) => Task(
        () => _db.collection('projects').add(
              Project.forCreation(
                title: title,
                userIds: [_auth.currentUser!.uid],
                createdAt: FieldValue.serverTimestamp(),
              ),
            ),
      ).attempt().peekEither(
            (exception) => myLog.e(
              'Error creating project.',
              exception,
              StackTrace.current,
            ),
            (docref) => myLog.i('Created project $title.'),
          );

  AsyncResult deleteProject(String projectId) => Task.fromVoid(
        () =>
            _db.collection(FirebasePaths.projects.path).doc(projectId).delete(),
      ).attemptAll();

  /// Attempts to save the currently opened project.
  Task<Result<Object, Unit>> handleSave() => Task(
        () => state.project.match(
          none: () => Future.value(
            const Err('No project is currently open. Create one first.'),
          ),
          some: (project) => _saveSaveables(project).run(),
        ),
      );

  /// Saves all of the saveable data in the currently opened project.
  Task<Result<Object, Unit>> _saveSaveables(Project project) =>
      _saveCollections(project.id).bind((_) => _saveSmartlines(project.id));

  /// Saves all of the collections in the currently opened project.
  Task<Result<Object, Unit>> _saveCollections(String projectId) =>
      Task.fromVoid(
        () => _db
            .collection('projects')
            .doc(projectId)
            .collection('saveData')
            .doc('collections')
            .set({'data': _collectionStore.serialize()}),
      ).attempt().peek(
            (either) => either.match(
              (exception) => myLog.e(
                'Error saving collections.',
                exception,
                StackTrace.current,
              ),
              (_) => myLog.i('Saved collections.'),
            ),
          );

  /// Saves all of the smartlines in the currently opened project.
  Task<Result<Object, Unit>> _saveSmartlines(String projectId) => Task.fromVoid(
        () => _db
            .collection('projects')
            .doc(projectId)
            .collection('saveData')
            .doc('smartlines')
            .set({'data': _smartlineController.serialize()}),
      ).attempt().peek(
            (either) => either.match(
              (exception) => myLog.e(
                'Error saving smartlines.',
                exception,
                StackTrace.current,
              ),
              (_) => myLog.i('Saved smartlines.'),
            ),
          );

  /// Opens a project and loads its data.
  Task<Either<Object, Unit>> openProject(Project project) => tap(
        tapped: _loadCollections(project)
            .bind((_) => _loadSmartlines(project))
            .mapEitherRight((_) => unit),
        effect: () => _openProjectRaw(project),
      );

  /// Sets the project.
  Unit _openProjectRaw(Project project) => effect(() {
        state = state.copyWith(project: Some(project));
        myLog.d('Opened project ${project.title}.');
      });

  Task<Either<Object, DocumentSnapshot>> _loadCollections(Project project) =>
      Task(
        () => _db
            .collection('projects')
            .doc(project.id)
            .collection('saveData')
            .doc('collections')
            .get(),
      )
          .attempt()
          .peekEitherLeft(
            (exception) => myLog.e(
              'Error fetching save data.',
              exception,
              StackTrace.current,
            ),
          )
          .map<Either<Object, DocumentSnapshot>>(
            (either) => either.match(
              Left.new,
              (docsnap) => docsnap.exists
                  ? Right(docsnap)
                  : const Left('No save data found.'),
            ),
          )
          .peekEitherRight(
            (docsnap) => _collectionStore.deserialize(
              List.castFrom(docsnap.get('data')),
            ),
          );

  Task<Either<Object, DocumentSnapshot>> _loadSmartlines(Project project) =>
      Task(
        () => _db
            .collection('projects')
            .doc(project.id)
            .collection('saveData')
            .doc('smartlines')
            .get(),
      )
          .attempt()
          .peekEitherLeft(
            (exception) => myLog.e(
              'Error fetching save data.',
              exception,
              StackTrace.current,
            ),
          )
          .map<Either<Object, DocumentSnapshot>>(
            (either) => either.match(
              Left.new,
              (docsnap) => docsnap.exists
                  ? Right(docsnap)
                  : const Left('No save data found.'),
            ),
          )
          .peekEitherRight(
            (docsnap) => _smartlineController.deserialize(
              Map.castFrom(docsnap.get('data')),
            ),
          );
}
