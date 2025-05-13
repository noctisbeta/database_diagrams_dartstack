import 'package:client/diagrams/controllers/diagram_cubit.dart';
import 'package:client/routing/router_path.dart';
import 'package:common/er/diagram.dart';
import 'package:common/er/diagrams/diagram_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class TabletCreateDiagramDialog extends StatefulWidget {
  const TabletCreateDiagramDialog({required this.onCreateDiagram, super.key});
  final Function(String name, DiagramType type) onCreateDiagram;

  static Future<void> showCreateDiagramDialog(BuildContext context) =>
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => TabletCreateDiagramDialog(
              onCreateDiagram: (name, diagramType) {
                final diagram = Diagram.initial(name, diagramType);
                context.read<DiagramCubit>().loadDiagram(diagram);

                Navigator.of(context).pop();

                context.goNamed(RouterPath.editor.name);
              },
            ),
      );

  @override
  State<TabletCreateDiagramDialog> createState() =>
      _TabletCreateDiagramDialogState();
}

class _TabletCreateDiagramDialogState extends State<TabletCreateDiagramDialog> {
  final _nameController = TextEditingController();
  DiagramType _selectedType = DiagramType.postgresql;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _nameController.text.trim().isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Create New Diagram'),
    content: SizedBox(
      width: 500,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Diagram Name',
              hintText: 'Enter a name for your diagram',
              prefixIcon: Icon(Icons.edit_document),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 24),
          const Row(
            children: [
              Text(
                'Select Database Type',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 8),
              Tooltip(
                message:
                    'The database type determines available data types'
                    ' and modeling features',
                child: Icon(Icons.info_outline, size: 16, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.warning_amber, size: 14, color: Colors.amber),
              SizedBox(width: 4),
              Text(
                'This cannot be changed after diagram creation',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTypeSelection(),
          const SizedBox(height: 24),
          _buildTypeDescription(),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('CANCEL'),
      ),
      FilledButton(
        onPressed:
            _isFormValid
                ? () {
                  widget.onCreateDiagram(
                    _nameController.text.trim(),
                    _selectedType,
                  );
                }
                : null,
        child: const Text('CREATE'),
      ),
    ],
  );

  Widget _buildTypeSelection() => Column(
    children: [
      Row(
        children: [
          Expanded(
            child: _TypeSelectionCard(
              title: DiagramType.postgresql.name,
              icon: Icons.table_chart,
              description: 'SQL relational database',
              isSelected: _selectedType == DiagramType.postgresql,
              onTap:
                  () => setState(() => _selectedType = DiagramType.postgresql),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _TypeSelectionCard(
              title: DiagramType.firestore.name,
              icon: Icons.article,
              description: 'NoSQL document database',
              isSelected: _selectedType == DiagramType.firestore,
              onTap:
                  () => setState(() => _selectedType = DiagramType.firestore),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      _TypeSelectionCard(
        title: DiagramType.custom.name,
        icon: Icons.settings,
        description: 'Define your own types and schema rules',
        isSelected: _selectedType == DiagramType.custom,
        onTap: () => setState(() => _selectedType = DiagramType.custom),
      ),
    ],
  );

  Widget _buildTypeDescription() {
    late final Color baseColor;
    late final String title;
    late final String description;

    switch (_selectedType) {
      case DiagramType.postgresql:
        baseColor = Colors.blue;
        title = 'PostgreSQL Database';
        description =
            'Create tables with relationships, constraints, primary and'
            ' foreign keys. '
            'Includes PostgreSQL data types and powerful indexing options.';
      case DiagramType.firestore:
        baseColor = Colors.orange;
        title = 'Firestore Database';
        description =
            'Design Firestore collections with documents, nested objects,'
            ' and arrays. '
            'Supports Firestore-specific data types and security rules '
            'recommendations.';
      case DiagramType.custom:
        baseColor = Colors.green;
        title = 'Custom Schema';
        description =
            'Define your own custom data types and schema rules. '
            'Perfect for specialized databases, custom implementations,'
            ' or hybrid solutions.';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: baseColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: baseColor.withValues(alpha: 800),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              color: baseColor.withValues(alpha: 700),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeSelectionCard extends StatelessWidget {
  const _TypeSelectionCard({
    required this.title,
    required this.icon,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });
  final String title;
  final IconData icon;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? Colors.grey[200] : Colors.white,
        border: Border.all(
          color:
              isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color:
                isSelected ? Theme.of(context).primaryColor : Colors.grey[600],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color:
                  isSelected ? Theme.of(context).primaryColor : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
        ],
      ),
    ),
  );
}
