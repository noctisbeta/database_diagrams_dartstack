import 'package:database_diagrams_client/main_view.dart';
import 'package:database_diagrams_client/state/diagram_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    home: BlocProvider(
      create: (context) => DiagramCubit(),
      child: const MainView(),
    ),
  );
}
