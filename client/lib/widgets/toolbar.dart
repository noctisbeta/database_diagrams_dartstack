import 'package:client/auth_button.dart';
import 'package:client/export_button.dart';
import 'package:client/reset_button.dart';
import 'package:client/save_button.dart';
import 'package:client/widgets/diagram_title.dart';
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
