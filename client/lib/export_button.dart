import 'dart:async';

import 'package:client/exporter.dart';
import 'package:flutter/material.dart';

class ExportButton extends StatelessWidget {
  const ExportButton({super.key});

  @override
  Widget build(BuildContext context) => PopupMenuButton<String>(
    tooltip: 'Export Diagram',
    icon: const Icon(Icons.file_download),
    // Add offset to move the menu down by 16 logical pixels
    offset: const Offset(0, 45),
    onSelected: (format) => _handleExportFormat(context, format),
    itemBuilder:
        (context) => [
          const PopupMenuItem<String>(
            value: 'png',
            child: Row(
              children: [
                Icon(Icons.image),
                SizedBox(width: 8),
                Text('Export as PNG'),
              ],
            ),
          ),
          const PopupMenuItem<String>(
            value: 'pdf',
            child: Row(
              children: [
                Icon(Icons.picture_as_pdf),
                SizedBox(width: 8),
                Text('Export as PDF'),
              ],
            ),
          ),
          const PopupMenuItem<String>(
            value: 'json',
            child: Row(
              children: [
                Icon(Icons.data_object),
                SizedBox(width: 8),
                Text('Export as JSON'),
              ],
            ),
          ),
        ],
  );

  void _handleExportFormat(BuildContext context, String format) {
    switch (format) {
      case 'png':
        unawaited(Exporter.exportAsPNG(context));
      case 'pdf':
        unawaited(Exporter.exportAsPDF(context));
      case 'json':
        unawaited(Exporter.exportAsJSON(context));
    }
  }
}
