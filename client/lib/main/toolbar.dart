import 'package:database_diagrams/authentication/controllers/auth_store.dart';
import 'package:database_diagrams/authentication/sign_in_button.dart';
import 'package:database_diagrams/collections/controllers/compiler.dart';
import 'package:database_diagrams/common/toolbar_button.dart';
import 'package:database_diagrams/profile/components/profile_avatar.dart';
import 'package:database_diagrams/profile/controllers/profile_controller.dart';
import 'package:database_diagrams/projects/components/create_project_dialog.dart';
import 'package:database_diagrams/projects/controllers/project_controller.dart';
import 'package:database_diagrams/utilities/iterable_extension.dart';
import 'package:flutter/material.dart';
import 'package:functional/functional.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Toolbar.
class Toolbar extends HookConsumerWidget {
  /// Default constructor.
  const Toolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(AuthStore.provider);

    final profileStream = ref.watch(ProfileController.profileStreamProvider);

    final projectCtl = ref.watch(ProjectController.provider.notifier);
    final projectState = ref.watch(ProjectController.provider);

    void handleSaveTapped() => projectCtl.handleSave().then(
          (result) => result.peekLeft(
            (err) => showDialog(
              context: context,
              builder: (_) {
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(err.toString()),
                      behavior: SnackBarBehavior.floating,
                      shape: const StadiumBorder(),
                      width: 309,
                    ),
                  ),
                );

                return Scaffold(
                  backgroundColor: Colors.transparent,
                  body: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).pop(),
                    child: GestureDetector(
                      onTap: () {},
                      child: CreateProjectDialog(
                        onCreatePressed: (title) =>
                            projectCtl.createOpenSave(title).run().then(
                                  (result) => Navigator.of(context).pop(),
                                ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );

    return Container(
      height: 40,
      color: Colors.orange.shade700,
      child: Row(
        children: [
          const SizedBox(
            width: 16,
          ),
          Expanded(
            child: Row(
              children: <Widget>[
                if (user is Some)
                  ToolbarButton(
                    label: 'Save',
                    onTap: handleSaveTapped,
                  ),
                ToolbarButton(
                  label: 'Export',
                  onTap: () {},
                ),
                ToolbarButton(
                  label: 'Code editor',
                  onTapUp: (details) => ref
                      .read(Compiler.provider.notifier)
                      .toggleOverlay(details, context),
                ),
              ].separatedByToList(
                const SizedBox(
                  width: 16,
                ),
              ),
            ),
          ),
          Text(
            projectState.project.match(
              none: () => 'untitled',
              some: (some) => some.title,
            ),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: user.match(
                none: () => const SignInButton(),
                some: (user) => Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(
                      Icons.notifications,
                      color: Colors.white,
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    profileStream.when(
                      data: (profile) => ProfileAvatar(
                        child: Text(
                          profile.initials,
                          style: TextStyle(
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (error, stack) => const Text('Error'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 16,
          ),
        ],
      ),
    );
  }
}
