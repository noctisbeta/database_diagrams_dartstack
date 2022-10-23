import 'package:flutter/material.dart';

/// Toolbar.
class Toolbar extends StatelessWidget {
  /// Default constructor.
  const Toolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      color: Colors.orange.shade700,
      child: Row(
        children: const [
          SizedBox(
            width: 16,
          ),
          Text(
            'Save',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          SizedBox(
            width: 16,
          ),
          Text(
            'Export',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          Spacer(),
          Text(
            'Login',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          SizedBox(
            width: 16,
          ),
        ],
      ),
    );
  }
}
