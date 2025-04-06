import 'dart:async';

import 'package:client/export_format.dart';
import 'package:client/exporter.dart';
import 'package:flutter/material.dart';

class ExportButton extends StatelessWidget {
  const ExportButton({super.key});

  @override
  Widget build(BuildContext context) => PopupMenuButton<ExportFormat>(
    tooltip: 'Export Diagram',
    icon: const Icon(Icons.file_download),
    // Add offset to move the menu down by 16 logical pixels
    offset: const Offset(0, 45),
    onSelected: (format) => unawaited(_handleExportFormat(context, format)),
    itemBuilder:
        (context) => [
          const PopupMenuItem<ExportFormat>(
            value: ExportFormat.png,
            child: Row(
              children: [
                Icon(Icons.image),
                SizedBox(width: 8),
                Text('Export as PNG'),
              ],
            ),
          ),
          const PopupMenuItem<ExportFormat>(
            value: ExportFormat.pdf,
            child: Row(
              children: [
                Icon(Icons.picture_as_pdf),
                SizedBox(width: 8),
                Text('Export as PDF'),
              ],
            ),
          ),
          const PopupMenuItem<ExportFormat>(
            value: ExportFormat.json,
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

  Future<void> _handleExportFormat(BuildContext context, ExportFormat format) =>
      switch (format) {
        ExportFormat.png => Exporter.exportAsPNG(context),
        ExportFormat.pdf => Exporter.exportAsPDF(context),
        ExportFormat.json => Exporter.exportAsJSON(context),
      };
}
