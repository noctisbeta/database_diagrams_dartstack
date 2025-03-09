import 'package:client/authentication/controllers/auth_bloc.dart';
import 'package:client/authentication/models/auth_event.dart';
import 'package:client/authentication/models/auth_state.dart';
import 'package:client/authentication/repositories/auth_repository.dart';
import 'package:client/dio_wrapper/dio_wrapper.dart';
import 'package:client/main_view.dart';
import 'package:client/projects/controllers/projects_bloc.dart';
import 'package:client/projects/models/projects_event.dart';
import 'package:client/projects/repositories/projects_repository.dart';
import 'package:client/state/diagram_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => DioWrapper.unauthorized()),
        RepositoryProvider(create: (context) => const FlutterSecureStorage()),
        RepositoryProvider(
          create:
              (context) => AuthRepository(
                dio: context.read<DioWrapper>(),
                storage: context.read<FlutterSecureStorage>(),
              ),
        ),
        RepositoryProvider(
          create:
              (context) => ProjectsRepository(dio: context.read<DioWrapper>()),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create:
                (context) =>
                    AuthBloc(authRepository: context.read<AuthRepository>())
                      ..add(const AuthEventCheckAuth()), // Add this line
          ),
          BlocProvider(create: (context) => DiagramCubit()),
          BlocProvider(
            create:
                (context) => ProjectsBloc(
                  projectsRepository: context.read<ProjectsRepository>(),
                )..add(ProjectsEventLoad()),
          ),
        ],
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            final DioWrapper dio = context.read<DioWrapper>();
            final FlutterSecureStorage storage =
                context.read<FlutterSecureStorage>();

            if (state is AuthStateAuthenticated) {
              dio.addAuthInterceptor(storage);
            } else {
              dio.removeAuthInterceptor();
            }
          },
          child: const MainView(),
        ),
      ),
    ),
  );
}
