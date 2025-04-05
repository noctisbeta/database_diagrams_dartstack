import 'package:client/authentication/controllers/auth_bloc.dart';
import 'package:client/authentication/controllers/auth_provider_wrapper.dart';
import 'package:client/authentication/models/auth_event.dart';
import 'package:client/authentication/models/auth_state.dart';
import 'package:client/common/widgets/my_snackbar.dart';
import 'package:client/diagrams/diagram_cubit.dart';
import 'package:client/diagrams/diagram_data_provider.dart';
import 'package:client/diagrams/diagram_repository.dart';
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
  Widget build(BuildContext context) => AuthProviderWrapper(
    child: MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create:
              (context) => DiagramDataProvider(
                jwtInterceptor: context.read<JwtInterceptor>(),
              ),
        ),
        RepositoryProvider(
          create:
              (context) => DiagramRepository(
                dataProvider: context.read<DiagramDataProvider>(),
              ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create:
                (context) => DiagramCubit(
                  diagramRepository: context.read<DiagramRepository>(),
                ),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
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

    context.read<JwtInterceptor>().onRefreshFailedCallback = () {
      context.read<AuthBloc>().add(const AuthEventTokenExpired());
    };

    context.read<AuthBloc>().add(const AuthEventCheckAuth());
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    home: BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthStateSessionExpired) {
          MySnackBar.show(
            context: context,
            message: state.message,
            type: SnackBarType.warning,
          );

          Navigator.of(context).popUntil((route) => route.isFirst);
        } else if (state is AuthStateError) {
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
