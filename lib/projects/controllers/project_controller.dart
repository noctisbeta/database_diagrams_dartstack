import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:database_diagrams/authentication/controllers/auth_store.dart';
import 'package:database_diagrams/projects/components/add_project_dialog.dart';
import 'package:database_diagrams/projects/models/project.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
              (exception) => tap(
                false,
                () => Logger().e(
                  'Error creating project.',
                  exception,
                  StackTrace.current,
                ),
              ),
              (_) => tap(
                true,
                () => Logger().i('Created project $title.'),
              ),
            ),
          );

  /// Save project.
  Future<bool> saveProject(BuildContext context) async => Task(
        () => state.match(
          () => openAddProjectDialog(context).then((value) => true),
          (project) => Future.value(true),
        ),
      ).run();

  Future<void> openAddProjectDialog(BuildContext context) => showDialog(
        context: context,
        builder: (context) => const Center(child: AddProjectDialog()),
      );
}
