import 'dart:async';

import 'package:client/authentication/controllers/auth_bloc.dart';
import 'package:client/authentication/models/auth_event.dart';
import 'package:client/authentication/models/auth_state.dart';
import 'package:client/widgets/sign_in_dialog.dart';
import 'package:common/auth/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Toolbar extends StatelessWidget {
  const Toolbar({super.key});

  @override
  Widget build(BuildContext context) => Container(
    height: 60,
    color: Colors.grey[200],
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        IconButton(
          icon: const Icon(Icons.save),
          onPressed: () {},
          tooltip: 'Save Diagram',
        ),
        const Spacer(),
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthStateLoading) {
              return const LoadingButton();
            } else if (state is AuthStateAuthenticated) {
              return ProfileMenu(user: state.user);
            } else {
              return const SignInButton();
            }
          },
        ),
      ],
    ),
  );
}

class LoadingButton extends StatelessWidget {
  const LoadingButton({super.key});

  @override
  Widget build(BuildContext context) => FilledButton.icon(
    onPressed: null,
    icon: const SizedBox.square(
      dimension: 16,
      child: CircularProgressIndicator(strokeWidth: 2),
    ),
    label: const Text('Please wait...'),
  );
}

class SignInButton extends StatelessWidget {
  const SignInButton({super.key});

  @override
  Widget build(BuildContext context) => FilledButton.icon(
    onPressed:
        () => unawaited(
          showDialog<void>(
            context: context,
            builder:
                (dialogContext) => BlocProvider.value(
                  value: context.read<AuthBloc>(),
                  child: const SignInDialog(),
                ),
          ),
        ),
    icon: const Icon(Icons.login),
    label: const Text('Sign In'),
  );
}

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({required this.user, super.key});

  final User user; // Replace with your actual User type

  @override
  Widget build(BuildContext context) => PopupMenuButton<String>(
    offset: const Offset(0, 40),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: Colors.blueGrey,
            child: Icon(Icons.person, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Text(
            user.username,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
    ),
    onSelected: (value) {
      if (value == 'signout') {
        context.read<AuthBloc>().add(const AuthEventLogout());
      }
      // Add more options handling here in the future
    },
    itemBuilder:
        (context) => [
          const ProfileMenuItem(
            value: 'profile',
            icon: Icons.account_circle,
            text: 'My Profile',
          ),
          const PopupMenuDivider(),
          const ProfileMenuItem(
            value: 'signout',
            icon: Icons.logout,
            text: 'Sign Out',
          ),
        ],
  );
}

class ProfileMenuItem extends PopupMenuEntry<String> {
  const ProfileMenuItem({
    required this.value,
    required this.icon,
    required this.text,
    super.key,
  });
  final String value;
  final IconData icon;
  final String text;

  @override
  double get height => 48; // Standard height for menu items

  @override
  bool represents(String? value) => this.value == value;

  @override
  State<ProfileMenuItem> createState() => _ProfileMenuItemState();
}

class _ProfileMenuItemState extends State<ProfileMenuItem> {
  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(widget.icon),
    title: Text(widget.text),
    onTap: () {
      Navigator.pop(context, widget.value);
    },
  );
}
