import 'package:client/diagrams/components/diagram_type_indicator.dart';
import 'package:client/diagrams/components/toolbar/components/postgres_code_button.dart';
import 'package:client/diagrams/components/toolbar/components/reset_button.dart';
import 'package:client/diagrams/components/toolbar/components/save_button.dart';
import 'package:client/diagrams/components/toolbar/components/share_button.dart';
import 'package:client/diagrams/controllers/diagram_cubit.dart';
import 'package:client/diagrams/models/diagram_state.dart';
import 'package:client/export/components/export_button.dart';
import 'package:common/er/diagrams/diagram_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// If you use go_router for navigation, you might import it here:
// import 'package:go_router/go_router.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) => Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
          ),
          child: Text(
            'Diagram Menu',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 24,
            ),
          ),
        ),
        Wrap(
          alignment: WrapAlignment.center,
          children: [
            const SaveButton(),
            const SizedBox(width: 8),
            const ExportButton(),
            const SizedBox(width: 8),
            const ResetButton(),
            const SizedBox(width: 8),
            const ShareButton(),
            const SizedBox(width: 8),

            BlocBuilder<DiagramCubit, DiagramState>(
              builder: (context, state) {
                if (state.diagramType == DiagramType.postgresql) {
                  return const PostgresCodeButton();
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(width: 8),
            const DiagramTypeIndicator(),
          ],
        ),
        const SizedBox(width: 12),

        ListTile(
          leading: const Icon(Icons.home_outlined),
          title: const Text('Landing Page'),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.folder_open_outlined),
          title: const Text('Open Diagram...'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.settings_outlined),
          title: const Text('Settings'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('About'),
          onTap: () {
            Navigator.pop(context);
            showAboutDialog(
              context: context,
              applicationName: 'Database Diagrams',
              applicationVersion: '1.0.0',
            );
          },
        ),
      ],
    ),
  );
}
