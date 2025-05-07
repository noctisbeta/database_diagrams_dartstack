import 'dart:convert';
import 'dart:typed_data';

import 'package:client/common/my_snackbar.dart';
import 'package:client/diagrams/controllers/diagram_cubit.dart';
import 'package:client/routing/router_path.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

final class DiagramImporter {
  const DiagramImporter._();

  static Future<void> importJson(BuildContext context) async {
    try {
      final DiagramCubit diagramCubit = context.read<DiagramCubit>();

      // 1. Pick a JSON file
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true, // Important to get file bytes
      );

      if (result == null || result.files.single.bytes == null) {
        MySnackBar.show(
          context: context,
          message: 'No file selected or file is empty.',
        );
        return;
      }

      MySnackBar.show(context: context, message: 'Importing diagram...');

      final PlatformFile file = result.files.single;
      final Uint8List fileBytes = file.bytes!;

      // 2. Read and parse JSON
      final String jsonString = utf8.decode(fileBytes);
      final Map<String, dynamic> diagramMap =
          jsonDecode(jsonString) as Map<String, dynamic>;

      // 3. Load into DiagramCubit
      diagramCubit.importDiagramFromMap(diagramMap);

      MySnackBar.show(
        context: context,
        message: 'Diagram imported successfully!',
        type: SnackBarType.success,
      );

      // 4. Navigate to the diagram view
      // Assuming '/diagram' is the route to your diagram editing/viewing screen
      if (context.mounted) {
        GoRouter.of(context).goNamed(RouterPath.editor.name);
      }
    } on Exception catch (e) {
      MySnackBar.show(
        context: context,
        message: 'Import failed: $e',
        type: SnackBarType.error,
      );
    }
  }
}
