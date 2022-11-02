import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Profile controller.
class ProfileController {
  /// Provider.
  static final provider = Provider(
    (ref) => ProfileController(),
  );

  OverlayEntry? _profileMenuEntry;

  /// Is profile menu open.
  bool get isProfileMenuOpen => _profileMenuEntry != null;

  /// Show overlay.
  void showProfileMenu(BuildContext context, OverlayEntry entry) {
    _profileMenuEntry = entry;
    Overlay.of(context)!.insert(_profileMenuEntry!);
  }

  /// Hide overlay.
  void closeProfileMenu() {
    _profileMenuEntry?.remove();
    _profileMenuEntry = null;
  }
}
