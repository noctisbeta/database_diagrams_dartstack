import 'package:flutter/material.dart';

/// My dropdown button.
class MyDropdownButton extends StatelessWidget {
  /// Default constructor.
  const MyDropdownButton({
    this.enabled,
    this.onChanged,
    this.value,
    super.key,
  });

  /// Enabled.
  final bool? enabled;

  /// On changed.
  final void Function(String?)? onChanged;

  /// Value.
  final String? value;

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: enabled != null && !enabled!,
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            fillColor: Colors.black.withOpacity(0.1),
            filled: enabled != null && !enabled!,
            enabled: enabled ?? true,
            isDense: true,
            labelText: 'Field type',
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
          focusColor: Colors.white,
          menuMaxHeight: 300,
          items: const [
            'string',
            'number',
            'boolean',
            'map',
            'array',
            'null',
            'timestamp',
            'geopoint',
            'reference',
          ]
              .map(
                (e) => DropdownMenuItem<String>(
                  value: e,
                  child: Text(e),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
