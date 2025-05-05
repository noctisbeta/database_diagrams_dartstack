import 'dart:async';

import 'package:client/authentication/components/auth_button.dart';
import 'package:client/authentication/controllers/auth_bloc.dart';
import 'package:client/authentication/models/auth_state.dart';
import 'package:client/diagrams/components/diagram_title.dart';
import 'package:client/diagrams/components/diagram_type_indicator.dart';
import 'package:client/diagrams/components/reset_button.dart';
import 'package:client/diagrams/components/save_button.dart';
import 'package:client/diagrams/controllers/diagram_cubit.dart';
import 'package:client/export/components/export_button.dart';
import 'package:client/landing/views/landing_view.dart';
import 'package:client/postgresql_parsing/postgresql_code_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Toolbar extends StatelessWidget {
  const Toolbar({super.key});

  @override
  Widget build(BuildContext context) => Container(
    height: 60,
    color: Colors.grey[200],
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        const SaveButton(),
        const SizedBox(width: 8),
        const ExportButton(),
        const SizedBox(width: 8),
        const ResetButton(),
        const SizedBox(width: 16),
        const DiagramTypeIndicator(),
        const SizedBox(width: 16),
        IconButton(
          icon: const Icon(Icons.code),
          tooltip: 'PostgreSQL Code',
          onPressed:
              () => unawaited(
                showDialog(
                  context: context,
                  builder:
                      (dialogContext) => BlocProvider.value(
                        value: context.read<DiagramCubit>(),
                        child: const PostgresqlCodeDialog(),
                      ),
                ),
              ),
        ),
        const Spacer(),
        const DiagramTitle(),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.share),
          tooltip: 'Share Diagram',
          onPressed: () async {
            final String? shortcode =
                await context.read<DiagramCubit>().shareDiagram();

            if (shortcode != null && context.mounted) {
              await Clipboard.setData(ClipboardData(text: shortcode));
              if (!context.mounted) {
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Shareable shortcode copied to clipboard!'),
                ),
              );
            } else if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to generate shareable shortcode.'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
        const SizedBox(width: 12),
        BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is AuthStateUnauthenticated) {
              return IconButton(
                icon: const Icon(Icons.home),
                tooltip: 'Go to Landing Page',
                onPressed:
                    () => unawaited(
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LandingView(),
                        ),
                      ),
                    ),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
        const SizedBox(width: 12),
        const AuthButton(isOnLandingView: false),
      ],
    ),
  );
}
