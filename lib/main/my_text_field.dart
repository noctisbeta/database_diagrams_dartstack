import 'package:flutter/material.dart';

/// My text field.
class MyTextField extends StatelessWidget {
  /// Default constructor.
  const MyTextField({
    required this.label,
    this.enabled,
    this.onChanged,
    this.textInputAction,
    this.controller,
    super.key,
  });

  /// Label.
  final String label;

  /// Enabled.
  final bool? enabled;

  /// On changed.
  final void Function(String)? onChanged;

  /// TextInputaction;
  final TextInputAction? textInputAction;

  /// Controller.
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: textInputAction,
      onChanged: onChanged,
      enabled: enabled,
      cursorColor: Colors.orange.shade700,
      decoration: InputDecoration(
        fillColor: Colors.black.withOpacity(0.1),
        filled: enabled != null && !enabled!,
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.black.withOpacity(0.3),
        ),
        floatingLabelStyle: TextStyle(
          color: Colors.orange.shade700,
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black.withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.orange.shade700,
          ),
        ),
      ),
    );
  }
}
