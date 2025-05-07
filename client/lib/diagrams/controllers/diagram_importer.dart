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
    // Show an initial "Importing..." message
    MySnackBar.show(
      context: context,
      message: 'Preparing to import diagram...',
    );

    try {
      // 1. Pick a JSON file
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true, // Important to get file bytes
      );

      if (!context.mounted) {
        return;
      }
      // Check context after await

      if (result == null || result.files.single.bytes == null) {
        MySnackBar.show(
          context: context,
          message: 'No file selected or file is empty.',
        );
        return;
      }

      MySnackBar.show(context: context, message: 'Importing diagram...');

      final Uint8List fileBytes = result.files.single.bytes!;
      final DiagramCubit diagramCubit = context.read<DiagramCubit>();

      // 2. Delegate processing to DiagramCubit
      await diagramCubit.processImportedFile(fileBytes);

      if (!context.mounted) {
        return; // Check context after await
      }

      // 3. Handle success UI feedback and navigation
      MySnackBar.show(
        context: context,
        message: 'Diagram imported successfully!',
        type: SnackBarType.success,
      );
      GoRouter.of(context).goNamed(RouterPath.editor.name);
    } on Exception catch (e) {
      // Catches exceptions from file picking or Cubit processing
      if (!context.mounted) {
        return;
      }

      MySnackBar.show(
        context: context,
        // Remove "Exception: " prefix for cleaner UI message
        message:
            'Import failed: ${e.toString().replaceFirst("Exception: ", "")}',
        type: SnackBarType.error,
      );

      // LOG.e('Error during importJson in DiagramImporter: $e');
    }
  }
}
