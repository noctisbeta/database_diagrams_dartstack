import 'package:client/authentication/components/auth_button/desktop_auth_button.dart';
import 'package:client/authentication/components/auth_button/mobile_auth_button.dart';
import 'package:client/authentication/components/auth_button/tablet_auth_button.dart';
import 'package:client/responsive/responsive_builder.dart';
import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  const AuthButton({required this.isOnLandingView, super.key});

  final bool isOnLandingView;

  @override
  Widget build(BuildContext context) => ResponsiveBuilder(
    desktop: () => DesktopAuthButton(isOnLandingView: isOnLandingView),
    tablet: () => TabletAuthButton(isOnLandingView: isOnLandingView),
    mobile: () => MobileAuthButton(isOnLandingView: isOnLandingView),
  );
}
