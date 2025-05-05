import 'dart:async';

import 'package:client/diagrams/controllers/diagram_cubit.dart';
import 'package:client/postgresql_parsing/postgresql_code_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostgresCodeButton extends StatelessWidget {
  const PostgresCodeButton({super.key});

  @override
  Widget build(BuildContext context) => IconButton(
    icon: const Icon(Icons.code),
    tooltip: 'PostgreSQL Code',
    onPressed:
        () => unawaited(
          showDialog(
            context: context,
            builder:
                (dialogContext) => BlocProvider.value(
                  value: context.read<DiagramCubit>(),
                  child: const PostgresqlCodeDialog(),
                ),
          ),
        ),
  );
}
