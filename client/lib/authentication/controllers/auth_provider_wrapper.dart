import 'package:client/authentication/controllers/auth_bloc.dart';
import 'package:client/authentication/repositories/auth_data_provider.dart';
import 'package:client/authentication/repositories/auth_repository.dart';
import 'package:client/authentication/storage/auth_secure_storage.dart';
import 'package:client/dio_wrapper/jwt_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProviderWrapper extends StatelessWidget {
  const AuthProviderWrapper({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => MultiRepositoryProvider(
    providers: [
      RepositoryProvider(
        create:
            (context) =>
                JwtInterceptor(secureStorage: const FlutterSecureStorage()),
      ),
      RepositoryProvider(create: (context) => const AuthDataProvider()),
      RepositoryProvider(create: (context) => const AuthSecureStorage()),
      RepositoryProvider(
        create:
            (context) => AuthRepository(
              authDataProvider: context.read<AuthDataProvider>(),
              authSecureStorage: context.read<AuthSecureStorage>(),
            ),
      ),
    ],
    child: BlocProvider(
      create:
          (context) => AuthBloc(authRepository: context.read<AuthRepository>()),
      child: child,
    ),
  );
}
