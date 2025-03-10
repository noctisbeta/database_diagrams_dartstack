import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:client/authentication/controllers/auth_bloc.dart';
import 'package:client/authentication/models/auth_event.dart';
import 'package:client/authentication/models/auth_state.dart';
import 'package:client/state/diagram_cubit.dart';
import 'package:client/widgets/sign_in_dialog.dart';
import 'package:common/auth/user.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class Toolbar extends StatelessWidget {
  const Toolbar({super.key});

  Future<void> _handleSavePressed(BuildContext context) async {
    final AuthState authState = context.read<AuthBloc>().state;

    if (authState is AuthStateAuthenticated) {
      // User is logged in, proceed with saving
      _saveDiagram(context);
    } else {
      // User is not logged in, show sign in prompt
      await _showSignInPrompt(context);
    }
  }

  void _saveDiagram(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Saving diagram...')));
  }

  Future<void> _showSignInPrompt(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Sign In Required'),
            content: const Text(
              'You need to be signed in to save your diagram. '
              'Would you like to sign in now?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  unawaited(
                    showDialog<void>(
                      context: context,
                      builder:
                          (signInContext) => BlocProvider.value(
                            value: context.read<AuthBloc>(),
                            child: const SignInDialog(),
                          ),
                    ),
                  );
                },
                child: const Text('Sign In'),
              ),
            ],
          ),
    );
  }

  Future<void> _handleExportPressed(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder:
          (dialogContext) => BlocProvider.value(
            value: context.read<DiagramCubit>(),
            child: Builder(
              builder:
                  (builderContext) => AlertDialog(
                    title: const Text('Export Diagram'),
                    content: const Text('Choose export format:'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(builderContext).pop();
                          _exportAsPNG(builderContext);
                        },
                        child: const Text('PNG'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(builderContext).pop();
                          _exportAsPDF(builderContext);
                        },
                        child: const Text('PDF'),
                      ),
                    ],
                  ),
            ),
          ),
    );
  }

  Future<void> _exportAsPNG(BuildContext context) async {
    final DiagramCubit diagramCubit = context.read<DiagramCubit>();

    void exportFailed(e) => ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Export failed: $e')));

    void exportComplete() => ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Export complete!')));

    void savedTo(path) => ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Saved to gallery: ${path ?? ''}')));

    try {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Exporting as PNG...')));

      // Get the boundary using GlobalKey
      final boundary =
          diagramCubit.canvasBoundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary == null) {
        throw Exception('Could not find diagram canvas');
      }

      // Convert render object to image
      final ui.Image image = await boundary.toImage(pixelRatio: 3);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final Uint8List? bytes = byteData?.buffer.asUint8List();

      if (bytes == null) {
        throw Exception('Failed to generate image');
      }

      // Save to device
      if (kIsWeb) {
        await FileSaver.instance.saveFile(
          name: 'diagram_${DateTime.now().millisecondsSinceEpoch}.png',
          bytes: bytes,
          mimeType: MimeType.png,
        );
      } else {
        final Map<String, dynamic> result = await ImageGallerySaver.saveImage(
          bytes,
        );
        if (result['isSuccess']) {
          savedTo(result['filePath']);
        } else {
          throw Exception('Failed to save image');
        }
      }

      exportComplete();
    } on Exception catch (e) {
      exportFailed(e);
    }
  }

  Future<void> _exportAsPDF(BuildContext context) async {
    final DiagramCubit diagramCubit = context.read<DiagramCubit>();

    void exportComplete() => ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Export complete!')));

    void exportFailed(e) => ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Export failed: $e')));

    try {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Exporting as PDF...')));

      // Get the boundary using GlobalKey
      final boundary =
          diagramCubit.canvasBoundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary == null) {
        throw Exception('Could not find diagram canvas');
      }

      // Convert render object to image
      final ui.Image image = await boundary.toImage(pixelRatio: 3);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final Uint8List? imageBytes = byteData?.buffer.asUint8List();

      if (imageBytes == null) {
        throw Exception('Failed to generate image');
      }

      // Create PDF document
      final pdf = pw.Document();
      final pdfImage = pw.MemoryImage(imageBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) => pw.Center(child: pw.Image(pdfImage)),
        ),
      );

      // Save PDF
      final Uint8List bytes = await pdf.save();

      if (kIsWeb) {
        await FileSaver.instance.saveFile(
          name: 'diagram_${DateTime.now().millisecondsSinceEpoch}.pdf',
          bytes: bytes,
          mimeType: MimeType.pdf,
        );
      } else {
        final Directory dir = await getApplicationDocumentsDirectory();
        final file = File(
          '${dir.path}/diagram_${DateTime.now().millisecondsSinceEpoch}.pdf',
        );
        await file.writeAsBytes(bytes);

        // Preview and share PDF
        await Printing.sharePdf(bytes: bytes, filename: 'diagram.pdf');
      }

      exportComplete();
    } on Exception catch (e) {
      exportFailed(e);
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    height: 60,
    color: Colors.grey[200],
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        IconButton(
          icon: const Icon(Icons.save),
          onPressed: () => unawaited(_handleSavePressed(context)),
          tooltip: 'Save Diagram',
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.file_download),
          onPressed: () => unawaited(_handleExportPressed(context)),
          tooltip: 'Export Diagram',
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
