import 'dart:async';

import 'package:client/authentication/components/sign_in_dialog.dart'; // Import the dialog
import 'package:client/authentication/controllers/auth_bloc.dart'; // Import the AuthCubit
import 'package:client/authentication/models/auth_state.dart';
import 'package:client/common/main_view.dart';
import 'package:client/diagrams/controllers/diagram_cubit.dart';
import 'package:client/landing/components/create_diagram_dialog.dart';
import 'package:client/landing/components/diagrams_list.dart';
import 'package:common/er/diagram.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LandingView extends StatefulWidget {
  const LandingView({super.key});

  @override
  State<LandingView> createState() => _LandingViewState();
}

class _LandingViewState extends State<LandingView> {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Database Diagrams')),
    body: Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: BlocBuilder<AuthCubit, AuthState>(
              builder:
                  (context, state) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // App icon/logo and intro
                      _buildIntroSection(),
                      const SizedBox(height: 48),

                      // Quick actions
                      _buildQuickActionsSection(),
                      const SizedBox(height: 40),

                      switch (state) {
                        AuthStateAuthenticated() =>
                          _buildRecentDiagramsSection(),
                        AuthStateUnauthenticated() => _buildSignInSection(),
                        AuthStateError() => _buildSignInSection(),
                        AuthStateLoading() => const Center(
                          child: CircularProgressIndicator(),
                        ),
                      },
                    ],
                  ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _buildIntroSection() => Center(
    child: Column(
      children: [
        // App icon/logo
        const Icon(Icons.schema, size: 64, color: Colors.blue),
        const SizedBox(height: 24),

        // Title
        const Text(
          'Database Diagrams',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Brief description
        SizedBox(
          width: 500,
          child: Text(
            'Design, visualize, and document your database schemas',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
        ),
      ],
    ),
  );

  Future<void> _showCreateDiagramDialog() => showDialog(
    context: context,
    barrierDismissible: false,
    builder:
        (context) => CreateDiagramDialog(
          onCreateDiagram: (name, type) {
            final diagram = Diagram(
              id: null,
              name: name,
              entities: const [],
              entityPositions: const [],
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              diagramType: type,
            );
            context.read<DiagramCubit>().loadDiagram(diagram);

            Navigator.of(context).pop();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const MainView()),
            );
          },
        ),
  );

  Widget _buildQuickActionsSection() => Row(
    children: [
      Expanded(
        child: _actionCard(
          title: 'Create New',
          description: 'Start a new diagram from scratch',
          icon: Icons.add_circle_outline,
          iconColor: Colors.green,
          isPrimary: true,
          onTap: () {
            unawaited(_showCreateDiagramDialog());
          },
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: _actionCard(
          title: 'Use Template',
          description: 'Start with a pre-built schema',
          icon: Icons.content_copy,
          iconColor: Colors.orange,
          isPrimary: false,
          onTap: () {
            // Show template options
          },
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: _actionCard(
          title: 'Import',
          description: 'Import from SQL or JSON',
          icon: Icons.upload_file,
          iconColor: Colors.purple,
          isPrimary: false,
          onTap: () {
            // Show import options
          },
        ),
      ),
    ],
  );

  Widget _actionCard({
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required bool isPrimary,
    required VoidCallback onTap,
  }) => Card(
    elevation: isPrimary ? 3 : 1,
    shadowColor: isPrimary ? Colors.blue.withValues(alpha: 0.3) : null,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: iconColor),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildSignInSection() => Card(
    elevation: 1,
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Text(
            'Access Your Diagrams',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'Sign in to save and access your diagrams across devices',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              // Show the SignInDialog when the button is pressed
              unawaited(
                showDialog<void>(
                  context: context,
                  barrierDismissible:
                      false, // Prevent closing by tapping outside
                  builder:
                      (dialogContext) =>
                      // Provide the AuthCubit from the main context
                      BlocProvider.value(
                        value: context.read<AuthCubit>(),
                        child: const SignInDialog(),
                      ),
                ),
              );
            },
            icon: const Icon(Icons.login),
            label: const Text('Sign In or Create Account'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildRecentDiagramsSection() => const DiagramsList();
}
