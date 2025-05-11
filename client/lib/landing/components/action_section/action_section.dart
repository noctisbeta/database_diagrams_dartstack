import 'package:client/landing/components/action_section/desktop_action_section.dart';
import 'package:client/landing/components/action_section/mobile_action_section.dart';
import 'package:client/landing/components/action_section/tablet_action_section.dart';
import 'package:client/responsive/responsive_builder.dart';
import 'package:flutter/material.dart';

class ActionSection extends StatelessWidget {
  const ActionSection({super.key});

  @override
  Widget build(BuildContext context) => const ResponsiveBuilder(
    desktop: DesktopActionSection.new,
    tablet: TabletActionSection.new,
    mobile: MobileActionSection.new,
  );
}
