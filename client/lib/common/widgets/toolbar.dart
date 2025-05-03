import 'dart:async';

import 'package:client/authentication/components/auth_button.dart';
import 'package:client/authentication/controllers/auth_bloc.dart';
import 'package:client/authentication/models/auth_state.dart';
import 'package:client/diagrams/components/diagram_title.dart';
import 'package:client/diagrams/components/diagram_type_indicator.dart';
import 'package:client/diagrams/components/reset_button.dart';
import 'package:client/diagrams/components/save_button.dart';
import 'package:client/export/components/export_button.dart';
import 'package:client/landing/views/landing_view.dart';
import 'package:flutter/material.dart';
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
        const Spacer(),
        const DiagramTitle(),
        const Spacer(),
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
