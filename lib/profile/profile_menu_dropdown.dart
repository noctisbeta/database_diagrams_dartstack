import 'package:database_diagrams/authentication/controllers/login_controller.dart';
import 'package:database_diagrams/profile/profile_controller.dart';
import 'package:database_diagrams/profile/profile_menu_button.dart';
import 'package:database_diagrams/projects/project_dialog.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Profile menu dropdown.
class ProfileMenuDropdown extends HookConsumerWidget {
  /// Default constructor.
  const ProfileMenuDropdown({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileCtl = ref.watch(ProfileController.provider);

    return Container(
      width: 200,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ProfileMenuButton(
            label: 'Projects',
            onPressed: () {
              profileCtl.closeProfileMenu();

              showDialog(
                context: context,
                builder: (context) => const Center(child: ProjectDialog()),
              );
            },
            icon: Icon(
              Icons.work,
              color: Colors.orange.shade700,
            ),
          ),
          ProfileMenuButton(
            label: 'Sign out',
            onPressed: () async {
              profileCtl.closeProfileMenu();
              await ref.read(LoginController.provider).logout();
            },
            icon: Icon(
              Icons.logout,
              color: Colors.orange.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
