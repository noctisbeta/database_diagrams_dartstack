import 'package:client/routing/router_path.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LandingViewButton extends StatelessWidget {
  const LandingViewButton({super.key});

  @override
  Widget build(BuildContext context) => IconButton(
    icon: const Icon(Icons.home),
    tooltip: 'Go to Landing Page',
    onPressed: () => context.goNamed(RouterPath.landing.name),
  );
}
