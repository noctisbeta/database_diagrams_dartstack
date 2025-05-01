import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:client/diagrams/controllers/diagram_cubit.dart';
import 'package:client/diagrams/models/diagram_state.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

final class Exporter {
  const Exporter._();

  static Future<void> exportAsPDF(BuildContext context) async {
    final DiagramCubit diagramCubit = context.read<DiagramCubit>();

    void exportComplete() => ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Export complete!')));

    void exportFailed(e) => ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Export failed: $e')));

    try {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Exporting as PDF...')));

      // Get the boundary using GlobalKey
      final boundary =
          diagramCubit.canvasBoundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary == null) {
        throw Exception('Could not find diagram canvas');
      }

      // Convert render object to image
      final ui.Image image = await boundary.toImage();
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final Uint8List? imageBytes = byteData?.buffer.asUint8List();

      if (imageBytes == null) {
        throw Exception('Failed to generate image');
      }

      // Create PDF document
      final pdf = pw.Document();
      final pdfImage = pw.MemoryImage(imageBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) => pw.Center(child: pw.Image(pdfImage)),
        ),
      );

      // Save PDF
      final Uint8List bytes = await pdf.save();

      if (kIsWeb) {
        await FileSaver.instance.saveFile(
          name: 'diagram_${DateTime.now().millisecondsSinceEpoch}.pdf',
          bytes: bytes,
          mimeType: MimeType.pdf,
        );
      } else {
        final Directory dir = await getApplicationDocumentsDirectory();
        final file = File(
          '${dir.path}/diagram_${DateTime.now().millisecondsSinceEpoch}.pdf',
        );
        await file.writeAsBytes(bytes);

        // Preview and share PDF
        await Printing.sharePdf(bytes: bytes, filename: 'diagram.pdf');
      }

      exportComplete();
    } on Exception catch (e) {
      exportFailed(e);
    }
  }

  static Future<void> exportAsPNG(BuildContext context) async {
    final DiagramCubit diagramCubit = context.read<DiagramCubit>();

    void exportFailed(e) => ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Export failed: $e')));

    void exportComplete() => ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Export complete!')));

    void savedTo(path) => ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Saved to gallery: ${path ?? ''}')));

    try {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Exporting as PNG...')));

      // Get the boundary using GlobalKey
      final boundary =
          diagramCubit.canvasBoundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary == null) {
        throw Exception('Could not find diagram canvas');
      }

      // Convert render object to image
      final ui.Image image = await boundary.toImage();
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final Uint8List? bytes = byteData?.buffer.asUint8List();

      if (bytes == null) {
        throw Exception('Failed to generate image');
      }

      // Save to device
      if (kIsWeb) {
        await FileSaver.instance.saveFile(
          name: 'diagram_${DateTime.now().millisecondsSinceEpoch}.png',
          bytes: bytes,
          mimeType: MimeType.png,
        );
      } else {
        final Map<String, dynamic> result = await ImageGallerySaver.saveImage(
          bytes,
        );
        if (result['isSuccess']) {
          savedTo(result['filePath']);
        } else {
          throw Exception('Failed to save image');
        }
      }

      exportComplete();
    } on Exception catch (e) {
      exportFailed(e);
    }
  }

  static Future<void> exportAsJSON(BuildContext context) async {
    final DiagramCubit diagramCubit = context.read<DiagramCubit>();

    void exportComplete() => ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('JSON export complete!')));

    void exportFailed(e) => ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('JSON export failed: $e')));

    try {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Exporting as JSON...')));

      // Access the state data correctly
      final DiagramState diagramState = diagramCubit.state;

      // Create a JSON representation with the data we have
      final Map<String, dynamic> diagramJson = {
        'entities': diagramState.entities.map((e) => e.toMap()).toList(),
        'entityPositions':
            diagramState.entityPositions.map((e) => e.toMap()).toList(),
        'metadata': {
          'name': 'Untitled Diagram',
          'exportedAt': DateTime.now().toIso8601String(),
        },
      };

      // Pretty print with indentation for better readability
      final String prettyJson = const JsonEncoder.withIndent(
        '  ',
      ).convert(diagramJson);

      // Convert to bytes for saving
      final Uint8List bytes = Uint8List.fromList(utf8.encode(prettyJson));

      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      const String diagramName = 'untitled';
      final String fileName =
          '${diagramName.replaceAll(' ', '_')}_$timestamp.json';

      if (kIsWeb) {
        await FileSaver.instance.saveFile(
          name: fileName,
          bytes: bytes,
          mimeType: MimeType.json,
        );
      } else {
        final Directory dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(bytes);

        // Share the file
        await shareFile(file.path);
      }

      exportComplete();
    } on Exception catch (e) {
      exportFailed(e);
    }
  }

  static Future<void> shareFile(String filePath) async {
    try {
      debugPrint('File ready for sharing at: $filePath');
    } on Exception catch (e) {
      debugPrint('Error sharing file: $e');
    }
  }
}
