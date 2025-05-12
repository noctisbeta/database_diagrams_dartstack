import 'package:client/authentication/components/auth_button/auth_button.dart';
import 'package:client/authentication/controllers/auth_bloc.dart';
import 'package:client/authentication/models/auth_state.dart';
import 'package:client/diagrams/components/diagram_title.dart';
import 'package:client/diagrams/components/toolbar/components/landing_view_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MobileToolbar extends StatelessWidget {
  const MobileToolbar({super.key});

  @override
  Widget build(BuildContext context) => Container(
    height: 60,
    color: Colors.grey[200],
    child: Row(
      children: [
        Expanded(
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.menu),
                tooltip: 'Open navigation menu',
                onPressed: () {
                  Scaffold.of(context).openDrawer();
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
