import 'package:client/authentication/components/auth_button.dart';
import 'package:client/authentication/controllers/auth_bloc.dart';
import 'package:client/authentication/models/auth_state.dart';
import 'package:client/landing/components/action_section/action_section.dart';
import 'package:client/landing/components/diagrams_list/diagrams_list.dart';
import 'package:client/landing/components/sign_in_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MobileLandingView extends StatelessWidget {
  const MobileLandingView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Database Diagrams'),
      actions: const [AuthButton(isOnLandingView: true)],
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16),
    ),
    body: Center(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(12),
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              const Icon(Icons.schema, size: 64, color: Colors.blue),
              const SizedBox(height: 24),
              const Text(
                'Database Diagrams',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 500,
                child: Text(
                  'Design, visualize, and document your'
                  ' database schemas',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ),
              const SizedBox(height: 16),
              const ActionSection(),
              const SizedBox(height: 16),
              BlocBuilder<AuthCubit, AuthState>(
                builder:
                    (context, state) => switch (state) {
                      AuthStateAuthenticated() => const DiagramsList(),
                      AuthStateUnauthenticated() ||
                      AuthStateError() => const SignInSection(),
                      AuthStateLoading() => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
