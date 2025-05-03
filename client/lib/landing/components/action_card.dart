import 'package:flutter/material.dart';

class ActionCard extends StatelessWidget {
  const ActionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.isPrimary,
    required this.onTap,
    super.key,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final bool isPrimary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    elevation: isPrimary ? 3 : 1,
    shadowColor: isPrimary ? Colors.blue.withValues(alpha: 0.3) : null,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: iconColor),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    ),
  );
}
