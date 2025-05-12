import 'package:client/diagrams/components/toolbar/desktop_toolbar.dart';
import 'package:client/diagrams/components/toolbar/mobile_toolbar.dart';
import 'package:client/diagrams/components/toolbar/tablet_toolbar.dart';
import 'package:client/responsive/responsive_builder.dart';
import 'package:flutter/material.dart';

class Toolbar extends StatelessWidget {
  const Toolbar({super.key});

  @override
  Widget build(BuildContext context) => const ResponsiveBuilder(
    desktop: DesktopToolbar.new,
    tablet: TabletToolbar.new,
    mobile: MobileToolbar.new,
  );
}
