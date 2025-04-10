import 'dart:async';

import 'package:client/authentication/components/sign_in_dialog.dart';
import 'package:client/authentication/controllers/auth_bloc.dart';
import 'package:client/authentication/models/auth_state.dart';
import 'package:client/diagrams/components/diagrams_list_dialog.dart';
import 'package:client/diagrams/controllers/diagram_cubit.dart';
import 'package:common/auth/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthButton extends StatefulWidget {
  const AuthButton({super.key});

  @override
  State<AuthButton> createState() => _AuthButtonState();
}

class _AuthButtonState extends State<AuthButton> {
  @override
  Widget build(BuildContext context) => BlocBuilder<AuthCubit, AuthState>(
    builder: (context, state) {
      if (state is AuthStateLoading) {
        return _buildLoadingButton();
      } else if (state is AuthStateAuthenticated) {
        return ProfileMenu(user: state.user);
      } else {
        return _buildSignInButton();
      }
    },
  );

  Widget _buildSignInButton() => FilledButton.icon(
    onPressed: _showSignInDialog,
    icon: const Icon(Icons.login),
    label: const Text('Sign In'),
  );

  Widget _buildLoadingButton() => FilledButton.icon(
    onPressed: null,
    icon: const SizedBox.square(
      dimension: 16,
      child: CircularProgressIndicator(strokeWidth: 2),
    ),
    label: const Text('Please wait...'),
  );

  void _showSignInDialog() {
    unawaited(
      showDialog<void>(
        context: context,
        builder:
            (dialogContext) => BlocProvider.value(
              value: context.read<AuthCubit>(),
              child: const SignInDialog(),
            ),
      ),
    );
  }
}

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({required this.user, super.key});

  final User user;

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
    onSelected: (value) async {
      if (value == 'signout') {
        await context.read<AuthCubit>().logout();
      } else if (value == 'diagrams') {
        unawaited(
          showDialog<void>(
            context: context,
            builder:
                (dialogContext) => BlocProvider.value(
                  value: context.read<DiagramCubit>(),
                  child: const DiagramsListDialog(),
                ),
          ),
        );
      }
    },
    itemBuilder:
        (context) => [
          const ProfileMenuItem(
            value: 'diagrams',
            icon: Icons.dashboard,
            text: 'My Diagrams',
          ),
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
      // Simply return the value without direct navigation
      Navigator.of(context).pop<String>(widget.value);
      // Don't add any code after this - it won't execute reliably
    },
  );
}
