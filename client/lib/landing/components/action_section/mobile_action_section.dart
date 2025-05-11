import 'dart:async';

import 'package:client/diagrams/controllers/diagram_cubit.dart';
import 'package:client/diagrams/controllers/diagram_importer.dart';
import 'package:client/landing/components/action_card.dart';
import 'package:client/landing/components/create_diagram_dialog.dart';
import 'package:client/routing/router_path.dart';
import 'package:common/er/diagram.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class MobileActionSection extends StatefulWidget {
  const MobileActionSection({super.key});

  @override
  State<MobileActionSection> createState() => _MobileActionSectionState();
}

class _MobileActionSectionState extends State<MobileActionSection> {
  late PageController _pageController;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: _currentPage,
      viewportFraction: 0.5,
    );

    _pageController.addListener(() {
      final int newPage = _pageController.page?.round() ?? _currentPage;
      if (_currentPage != newPage) {
        setState(() {
          _currentPage = newPage;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _showCreateDiagramDialog(BuildContext context) => showDialog(
    context: context,
    barrierDismissible: false,
    builder:
        (context) => CreateDiagramDialog(
          onCreateDiagram: (name, diagramType) {
            final diagram = Diagram.initial(name, diagramType);
            context.read<DiagramCubit>().loadDiagram(diagram);

            Navigator.of(context).pop();

            context.goNamed(RouterPath.editor.name);
          },
        ),
  );

  late final List<Widget> cards = [
    ActionCard(
      title: 'Use Template',
      description: 'Start with a pre-built schema',
      icon: Icons.content_copy,
      iconColor: Colors.orange,
      onTap: () {},
    ),
    ActionCard(
      title: 'Create New',
      description: 'Start a new diagram from scratch',
      icon: Icons.add_circle_outline,
      iconColor: Colors.green,
      onTap: () {
        unawaited(_showCreateDiagramDialog(context));
      },
    ),
    ActionCard(
      title: 'Import',
      description: 'Import from JSON',
      icon: Icons.upload_file,
      iconColor: Colors.purple,
      onTap: () async {
        await DiagramImporter.importJson(context);
      },
    ),
  ];

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 220,
    child: PageView.builder(
      controller: _pageController,
      itemCount: cards.length,
      clipBehavior: Clip.none,
      itemBuilder: (context, index) {
        double scale = 1;
        if (index == _currentPage) {
          scale = 1;
        } else if (index == _currentPage - 1 || index == _currentPage + 1) {
          scale = 0.8;
        }

        return Transform.scale(scale: scale, child: cards[index]);
      },
    ),
  );
}
