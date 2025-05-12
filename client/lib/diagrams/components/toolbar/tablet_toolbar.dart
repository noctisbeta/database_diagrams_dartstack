import 'package:client/authentication/components/auth_button/auth_button.dart';
import 'package:client/authentication/controllers/auth_bloc.dart';
import 'package:client/authentication/models/auth_state.dart';
import 'package:client/diagrams/components/diagram_title.dart';
import 'package:client/diagrams/components/diagram_type_indicator.dart';
import 'package:client/diagrams/components/toolbar/components/landing_view_button.dart';
import 'package:client/diagrams/components/toolbar/components/postgres_code_button.dart';
import 'package:client/diagrams/components/toolbar/components/reset_button.dart';
import 'package:client/diagrams/components/toolbar/components/save_button.dart';
import 'package:client/diagrams/components/toolbar/components/share_button.dart';
import 'package:client/diagrams/controllers/diagram_cubit.dart';
import 'package:client/diagrams/models/diagram_state.dart';
import 'package:client/export/components/export_button.dart';
import 'package:common/er/diagrams/diagram_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TabletToolbar extends StatelessWidget {
  const TabletToolbar({super.key});

  @override
  Widget build(BuildContext context) => Container(
    height: 60,
    color: Colors.grey[200],
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        Expanded(
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
              BlocBuilder<DiagramCubit, DiagramState>(
                builder: (context, state) {
                  if (state.diagramType == DiagramType.postgresql) {
                    return const PostgresCodeButton();
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
        const DiagramTitle(),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const ShareButton(),
              const SizedBox(width: 12),
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  if (state is AuthStateUnauthenticated) {
                    return const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [LandingViewButton(), SizedBox(width: 12)],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const AuthButton(isOnLandingView: false),
            ],
          ),
        ),
      ],
    ),
  );
}
