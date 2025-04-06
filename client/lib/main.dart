import 'dart:async';

import 'package:client/authentication/auth_provider_wrapper.dart';
import 'package:client/authentication/controllers/auth_bloc.dart';
import 'package:client/authentication/models/auth_state.dart';
import 'package:client/common/widgets/my_snackbar.dart';
import 'package:client/diagrams/controllers/diagram_cubit.dart';
import 'package:client/diagrams/diagram_provider_wrapper.dart';
import 'package:client/dio_wrapper/jwt_interceptor.dart';
import 'package:client/main_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const ProviderWrapper());
}

class ProviderWrapper extends StatelessWidget {
  const ProviderWrapper({super.key});

  @override
  Widget build(BuildContext context) =>
      const AuthProviderWrapper(child: DiagramProviderWrapper(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    context.read<JwtInterceptor>().onRefreshFailedCallback = () async {
      await context.read<AuthCubit>().logout();
    };

    unawaited(context.read<AuthCubit>().checkAuth());
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    home: BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthStateUnauthenticated) {
          context.read<DiagramCubit>().resetDiagram();
        }

        if (state is AuthStateError) {
          MySnackBar.show(
            context: context,
            message: state.message,
            type: SnackBarType.error,
          );
        }
      },
      child: const MainView(),
    ),
  );
}
