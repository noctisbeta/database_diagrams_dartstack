import 'package:client/authentication/components/auth_button.dart';
import 'package:client/diagrams/components/diagram_title.dart';
import 'package:client/diagrams/components/reset_button.dart';
import 'package:client/diagrams/components/save_button.dart';
import 'package:client/export/components/export_button.dart';
import 'package:flutter/material.dart';

class Toolbar extends StatelessWidget {
  const Toolbar({super.key});

  @override
  Widget build(BuildContext context) => Container(
    height: 60,
    color: Colors.grey[200],
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: const Row(
      children: [
        SaveButton(),
        SizedBox(width: 8),
        ExportButton(),
        SizedBox(width: 8),
        ResetButton(),
        Spacer(),
        DiagramTitle(),
        Spacer(),
        AuthButton(),
      ],
    ),
  );
}
