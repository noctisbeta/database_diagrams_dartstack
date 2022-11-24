import 'package:database_diagrams/profile/controllers/profile_controller.dart';
import 'package:database_diagrams/profile/components/profile_menu_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Profile avata.
class ProfileAvatar extends HookConsumerWidget {
  /// Default constructor.
  const ProfileAvatar({
    required this.child,
    super.key,
  });

  /// The child widget.
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarKey = useState(GlobalKey());

    final profileCtl = ref.watch(ProfileController.provider);

    return GestureDetector(
      onTap: () {
        if (!profileCtl.isProfileMenuOpen) {
          final entry = OverlayEntry(
            builder: (context) {
              final avatarRect = avatarKey.value.currentContext?.findRenderObject() as RenderBox?;
              final avatarSize = avatarRect?.size;
              final avatarOffset = avatarRect?.localToGlobal(
                Offset.zero.translate(
                  avatarSize!.width / 2,
                  avatarSize.height / 2,
                ),
              );

              return Positioned(
                left: avatarOffset!.dx - 200,
                top: avatarOffset.dy + 25,
                child: const Material(
                  type: MaterialType.transparency,
                  child: ProfileMenuDropdown(),
                ),
              );
            },
          );

          profileCtl.showProfileMenu(context, entry);
        } else {
          profileCtl.closeProfileMenu();
        }
      },
      child: CircleAvatar(
        key: avatarKey.value,
        backgroundColor: Colors.white,
        radius: 15,
        child: child,
      ),
    );
  }
}
