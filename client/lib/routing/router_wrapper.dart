import 'package:client/diagrams/views/editor_view.dart';
import 'package:client/diagrams/views/shared_diagram_view.dart';
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
      GoRoute(
        path: RouterPath.shared.path, // Use '/s/:shortcode'
        name: RouterPath.shared.name,
        builder: (context, state) {
          // Extract the 'shortcode' parameter from the path
          final String? shortcode = state.pathParameters['shortcode'];

          // Handle cases where shortcode might be missing or invalid (optional)
          if (shortcode == null || shortcode.isEmpty) {
            // Redirect to landing or show an error page
            // For simplicity, redirecting to landing:
            // Note: Direct navigation inside builder is discouraged,
            // consider using redirect or errorBuilder for cleaner handling.
            // This is a basic example:
            return const LandingView(); // Or an ErrorView
          }

          // Return the view responsible for fetching and displaying
          // the shared diagram, passing the shortcode to it.
          return SharedDiagramView(shortcode: shortcode);
        },
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
