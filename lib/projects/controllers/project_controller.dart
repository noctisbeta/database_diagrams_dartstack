import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:database_diagrams/authentication/controllers/auth_store.dart';
import 'package:database_diagrams/logging/log_profile.dart';
import 'package:database_diagrams/projects/components/create_project_dialog.dart';
import 'package:database_diagrams/projects/models/project.dart';
import 'package:database_diagrams/projects/models/project_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:functional/functional.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Project controller.
class ProjectController extends StateNotifier<ProjectState> {
  /// Default constructor.
  ProjectController(
    this._auth,
    this._db,
  ) : super(const ProjectState.initial());

  /// Firebase auth.
  final FirebaseAuth _auth;

  /// Firestore database.
  final FirebaseFirestore _db;

  /// Provider.
  static final provider =
      StateNotifierProvider<ProjectController, ProjectState>(
    (ref) => ProjectController(
      FirebaseAuth.instance,
      FirebaseFirestore.instance,
    ),
  );

  /// Provides the project stream.
  static final projectStreamProvider =
      StreamProvider.autoDispose<List<Project>>(
    (ref) => ref.watch(AuthStore.provider).match(
          () => Stream.value([]),
          (user) => FirebaseFirestore.instance
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

  /// Creates a new project.
  Future<Either<Object, DocumentReference>> createProject(String title) async =>
      Task(
        () => _db.collection('projects').add(
              Project.forCreation(
                title: title,
                userIds: [_auth.currentUser!.uid],
                createdAt: FieldValue.serverTimestamp(),
              ),
            ),
      ).attempt().run().then(
            (either) => either.match(
              (exception) => tap(
                Left(exception),
                () => myLog.e(
                  'Error creating project.',
                  exception,
                  StackTrace.current,
                ),
              ),
              (reference) => tap(
                Right(reference),
                () => myLog.i('Created project $title.'),
              ),
            ),
          );

  /// Save project.
  Future<bool> saveProject(BuildContext context) async => Task(
        () => state.project.match(
          () => promptNewProject(context).then(
            (value) => value
                ? tap(
                    false,
                    () => saveProject(context),
                  )
                : false,
          ),
          _saveRaw,
        ),
      ).run();

  Future<bool> _saveRaw(Project project) => Task.fromVoid(
        () => _db.collection('projects').doc(project.id).set(
              project.toMap(),
              SetOptions(merge: true),
            ),
      ).attempt().run().then(
            (either) => either.match(
              (exception) => tap(
                false,
                () => myLog.e(
                  'Error saving project.',
                  exception,
                  StackTrace.current,
                ),
              ),
              (_) => tap(
                true,
                () => myLog.i('Saved project ${project.title}.'),
              ),
            ),
          );

  /// Prompts the user to create a new project and then opens it.
  Future<bool> promptNewProject(BuildContext context) async => showDialog<bool>(
        context: context,
        builder: (context) => Center(
          child: CreateProjectDialog(
            onCreate: (name) => createProject(name)
                .then(
                  (createEither) => createEither.match<Future<bool>>(
                    (exception) => tap(
                      Future.value(false),
                      () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Error creating project.',
                          ),
                        ),
                      ),
                    ),
                    (docref) => Task(() => docref.get())
                        .attempt()
                        .map<Either<Object, Project>>(
                          (getEither) => getEither.match(
                            (exception) => tap(
                              Left(exception),
                              () => myLog.e(
                                'Error getting project.',
                                exception,
                                StackTrace.current,
                              ),
                            ),
                            (snapshot) => tap(
                              Right(Project.fromSnapshot(snapshot)),
                              () => myLog.i(
                                'Got project ${snapshot.id}.',
                              ),
                            ),
                          ),
                        )
                        .run()
                        .then(
                          (projectEither) => projectEither.match(
                            (left) => false,
                            (right) => tap(
                              true,
                              () =>
                                  state = state.copyWith(project: Some(right)),
                            ),
                          ),
                        ),
                  ),
                )
                .then(
                  (value) => Navigator.of(context).pop(value),
                ),
          ),
        ),
      ).then((value) => value ?? false);

  /// Sets the project.
  Unit openProject(Project project) {
    state = state.copyWith(project: Some(project));
    return unit;
  }
}
