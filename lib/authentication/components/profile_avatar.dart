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
    return GestureDetector(
      onTap: () {},
      child: CircleAvatar(
        backgroundColor: Colors.white,
        radius: 15,
        child: child,
      ),
    );
  }
}
