import 'package:client/authentication/components/sign_in_dialog/desktop_sign_in_dialog.dart';
import 'package:client/authentication/components/sign_in_dialog/mobile_sign_in_dialog.dart';
import 'package:client/authentication/components/sign_in_dialog/tablet_sign_in_dialog.dart';
import 'package:client/responsive/responsive_builder.dart';
import 'package:flutter/material.dart';

class SignInDialog extends StatelessWidget {
  const SignInDialog({super.key});

  @override
  Widget build(BuildContext context) => ResponsiveBuilder(
    desktop: () => const DesktopSignInDialog(),
    tablet: () => const TabletSignInDialog(),
    mobile: () => const MobileSignInDialog(),
  );
}
