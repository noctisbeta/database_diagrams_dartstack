import 'dart:developer';

import 'package:database_diagrams/profile/profile_menu_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Profile avata.
class ProfileAvatar extends HookWidget {
  /// Default constructor.
  const ProfileAvatar({
    required this.child,
    super.key,
  });

  /// The child widget.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final avatarKey = useState(GlobalKey());

    return GestureDetector(
      onTap: () {
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

            log('avatarOffset: $avatarOffset');

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
        Overlay.of(context)?.insert(entry);
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
