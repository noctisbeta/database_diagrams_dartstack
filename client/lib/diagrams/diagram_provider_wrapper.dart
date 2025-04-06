import 'package:client/diagrams/controllers/diagram_cubit.dart';
import 'package:client/diagrams/repositories/diagram_data_provider.dart';
import 'package:client/diagrams/repositories/diagram_repository.dart';
import 'package:client/dio_wrapper/jwt_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DiagramProviderWrapper extends StatelessWidget {
  const DiagramProviderWrapper({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => MultiRepositoryProvider(
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
      child: child,
    ),
  );
}
