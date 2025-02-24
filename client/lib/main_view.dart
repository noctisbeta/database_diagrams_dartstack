import 'package:flutter/material.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Database Diagrams')),
    body: InteractiveViewer(
      boundaryMargin: const EdgeInsets.all(400),

      child: Container(
        width: double.infinity, 
        height: double.infinity,
        color: Colors.grey[200],
        child: const Stack(),
      ),
    ),
  );
}
