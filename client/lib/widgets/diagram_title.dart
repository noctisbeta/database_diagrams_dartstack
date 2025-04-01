import 'dart:async';

import 'package:client/diagrams/diagram_cubit.dart';
import 'package:client/diagrams/diagram_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DiagramTitle extends StatefulWidget {
  const DiagramTitle({super.key});

  @override
  State<DiagramTitle> createState() => _DiagramTitleState();
}

class _DiagramTitleState extends State<DiagramTitle> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && _isEditing) {
      _submitTitle();
    }
  }

  void _startEditing(String initialValue) {
    setState(() {
      _controller.text = initialValue;
      _isEditing = true;
    });
    // Schedule focus for the next frame
    Future.delayed(Duration.zero, _focusNode.requestFocus);
  }

  void _submitTitle() {
    if (_isEditing) {
      final String newTitle = _controller.text.trim();
      if (newTitle.isNotEmpty) {
        unawaited(context.read<DiagramCubit>().updateDiagramTitle(newTitle));
      }
      setState(() {
        _isEditing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<DiagramCubit, DiagramState>(
    builder: (context, state) {
      final String currentTitle = state.name;

      if (_isEditing) {
        return SizedBox(
          width: 240,
          height: 40,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.check),
                onPressed: _submitTitle,
                tooltip: 'Save Title',
              ),
            ),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            onSubmitted: (_) => _submitTitle(),
          ),
        );
      } else {
        return InkWell(
          onTap: () => _startEditing(currentTitle),
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Text(
                  currentTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(width: 8),
                const Icon(Icons.edit, size: 16, color: Colors.grey),
              ],
            ),
          ),
        );
      }
    },
  );
}
