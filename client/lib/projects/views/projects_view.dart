import 'dart:async';

import 'package:client/projects/controllers/projects_bloc.dart';
import 'package:client/projects/models/projects_event.dart';
import 'package:client/projects/models/projects_state.dart';
import 'package:common/er/projects/create_project_request.dart';
import 'package:common/er/projects/project.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProjectsView extends StatelessWidget {
  const ProjectsView({super.key});

  void _showCreateProjectDialog(BuildContext context) {
    unawaited(
      showDialog(
        context: context,
        builder:
            (dialogContext) => BlocProvider.value(
              value: context.read<ProjectsBloc>(),
              child: const CreateProjectDialog(),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ProjectsBloc, ProjectsState>(
        builder:
            (context, state) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppBar(
                  title: const Text('Projects'),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _showCreateProjectDialog(context),
                    ),
                  ],
                ),
                switch (state) {
                  ProjectsStateInitial() || ProjectsStateLoading() =>
                    const Center(child: CircularProgressIndicator()),
                  ProjectsStateLoaded(:final List<Project> projects) =>
                    ListView.builder(
                      itemCount: projects.length,
                      itemBuilder:
                          (context, index) => ListTile(
                            title: Text(projects[index].name),
                            subtitle: Text(projects[index].description),
                            onTap: () {},
                          ),
                    ),
                  ProjectsStateError(:final String message) => Center(
                    child: Text('Error: $message'),
                  ),
                },
              ],
            ),
      );
}

class CreateProjectDialog extends StatefulWidget {
  const CreateProjectDialog({super.key});

  @override
  State<CreateProjectDialog> createState() => _CreateProjectDialogState();
}

class _CreateProjectDialogState extends State<CreateProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Create Project'),
    content: Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              hintText: 'Enter project name',
            ),
            validator:
                (value) => value?.isEmpty ?? true ? 'Name is required' : null,
          ),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Enter project description',
            ),
            maxLines: 3,
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: () {
          if (_formKey.currentState?.validate() ?? false) {
            context.read<ProjectsBloc>().add(
              ProjectsEventCreate(
                request: CreateProjectRequest(
                  name: _nameController.text,
                  description: _descriptionController.text,
                ),
              ),
            );
            Navigator.pop(context);
          }
        },
        child: const Text('Create'),
      ),
    ],
  );
}
