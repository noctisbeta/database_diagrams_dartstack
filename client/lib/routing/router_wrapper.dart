import 'package:client/diagrams/views/editor_view.dart';
import 'package:client/landing/views/landing_view.dart';
import 'package:client/routing/router_path.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RouterWrapper extends StatefulWidget {
  const RouterWrapper({this.builder, super.key});

  final Widget Function(BuildContext, Widget?)? builder;

  @override
  State<RouterWrapper> createState() => _RouterWrapperState();
}

class _RouterWrapperState extends State<RouterWrapper> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createRouter();
  }

  GoRouter createRouter() => GoRouter(
    routes: [
      GoRoute(
        path: RouterPath.landing.path,
        name: RouterPath.landing.name,
        builder: (context, state) => const LandingView(),
      ),
      GoRoute(
        path: RouterPath.editor.path,
        name: RouterPath.editor.name,
        builder: (context, state) => const EditorView(),
      ),
    ],
    initialLocation: RouterPath.landing.path,
    debugLogDiagnostics: kDebugMode,
  );

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    routerConfig: _router,
    title: 'ER Diagram',
    debugShowCheckedModeBanner: false,
    builder: widget.builder,
  );
}
