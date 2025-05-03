import 'package:client/authentication/components/auth_button.dart';
import 'package:client/authentication/controllers/auth_bloc.dart'; // Import the AuthCubit
import 'package:client/authentication/models/auth_state.dart';
import 'package:client/landing/components/action_section.dart';
import 'package:client/landing/components/diagrams_list.dart';
import 'package:client/landing/components/sign_in_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LandingView extends StatelessWidget {
  const LandingView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Database Diagrams'),
      actions: const [AuthButton(isOnLandingView: true)],
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16),
    ),
    body: Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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

                const SizedBox(height: 48),
                const ActionSection(),
                const SizedBox(height: 40),
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
    ),
  );
}
