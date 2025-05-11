import 'package:client/landing/views/landing_view/desktop_landing_view.dart';
import 'package:client/landing/views/landing_view/mobile_landing_view.dart';
import 'package:client/landing/views/landing_view/tablet_landing_view.dart';
import 'package:client/responsive/responsive_builder.dart';
import 'package:flutter/material.dart';

class LandingView extends StatelessWidget {
  const LandingView({super.key});

  @override
  Widget build(BuildContext context) => const ResponsiveBuilder(
    mobile: MobileLandingView.new,
    tablet: TabletLandingView.new,
    desktop: DesktopLandingView.new,
  );
}
