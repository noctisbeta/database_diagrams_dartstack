import 'dart:async';

import 'package:client/common/main_view.dart';
import 'package:client/diagrams/controllers/diagram_cubit.dart';
import 'package:client/landing/components/create_diagram_dialog.dart';
import 'package:common/er/diagram.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LandingView extends StatefulWidget {
  const LandingView({super.key});

  @override
  State<LandingView> createState() => _LandingViewState();
}

class _LandingViewState extends State<LandingView> {
  // In a real app, you'd get this from your auth provider
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Database Diagrams')),
    body: Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App icon/logo and intro
                _buildIntroSection(),
                const SizedBox(height: 48),

                // Quick actions
                _buildQuickActionsSection(),
                const SizedBox(height: 40),

                if (false)
                  _buildRecentDiagramsSection()
                else
                  _buildSignInSection(),
              ],
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
              id: -1,
              name: name,
              entities: const [],
              entityPositions: const [],
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              type: type,
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
              // Handle authentication
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

  Widget _buildRecentDiagramsSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Text(
            'Your Recent Diagrams',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () {
              // View all diagrams
            },
            icon: const Icon(Icons.chevron_right),
            label: const Text('View All'),
          ),
        ],
      ),
      const SizedBox(height: 16),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        itemCount: 0, // Replace with actual diagram list length
        itemBuilder:
            (context, index) =>
                const Card(child: Placeholder(fallbackHeight: 100)),
      ),
      // Show a placeholder when no diagrams exist
      if (true) // Replace with actual empty check
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'No diagrams yet',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your first diagram to see it here',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
    ],
  );
}
