import 'package:flutter/material.dart';

class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    required this.desktop,
    required this.tablet,
    required this.mobile,
    super.key,
  });

  final Widget Function() desktop;
  final Widget Function() tablet;
  final Widget Function() mobile;

  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < mobileBreakpoint) {
      return mobile();
    } else if (screenWidth < desktopBreakpoint) {
      return tablet();
    } else {
      return desktop();
    }
  }
}
