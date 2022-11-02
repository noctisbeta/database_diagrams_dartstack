import 'package:database_diagrams/profile/profile_menu_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Profile menu dropdown.
class ProfileMenuDropdown extends HookWidget {
  /// Default constructor.
  const ProfileMenuDropdown({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
            label: 'Sign out',
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
