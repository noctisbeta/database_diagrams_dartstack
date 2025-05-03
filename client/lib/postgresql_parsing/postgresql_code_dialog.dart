import 'dart:async';

import 'package:client/diagrams/controllers/diagram_cubit.dart';
import 'package:client/postgresql_parsing/postgresql_parser.dart';
import 'package:common/er/entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostgresqlCodeDialog extends StatefulWidget {
  const PostgresqlCodeDialog({super.key});

  @override
  State<PostgresqlCodeDialog> createState() => _PostgresqlCodeDialogState();
}

class _PostgresqlCodeDialogState extends State<PostgresqlCodeDialog> {
  late String postgresqlCode = '';
  late TextSpan highlightedTextSpan; // To store the result

  // Styles will be initialized in initState based on Theme
  late TextStyle _defaultStyle;
  late TextStyle _keywordStyle;
  late TextStyle _typeStyle; // Added back for potential differentiation
  late TextStyle _identifierStyle;
  late TextStyle _operatorStyle;
  late TextStyle _commentStyle;
  late Color _codeBackgroundColor;

  @override
  void initState() {
    super.initState();

    // --- Initialize Styles based on Theme ---
    // We need a context to get the theme, but initState doesn't have
    // one readily.
    // We use a post-frame callback or grab it from the widget's context
    // if available immediately (less reliable). A safer way is often
    // to initialize in didChangeDependencies or build, but since the
    // TextSpan is built here, we'll use a common pattern.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      } // Check if the widget is still in the tree
      final ThemeData theme = Theme.of(context);
      final ColorScheme colorScheme = theme.colorScheme;
      final TextTheme textTheme = theme.textTheme;
      const String fontFamily = 'monospace';
      const double fontSize = 14;

      // Define styles using theme colors
      _defaultStyle = textTheme.bodyMedium!.copyWith(
        color: colorScheme.onSurfaceVariant, // Good default text color
        fontFamily: fontFamily,
        fontSize: fontSize,
      );
      _keywordStyle = TextStyle(
        color: colorScheme.primary, // Use primary color for keywords
        fontWeight: FontWeight.bold,
        fontFamily: fontFamily,
        fontSize: fontSize,
      );
      _typeStyle = TextStyle(
        color: colorScheme.secondary, // Use secondary for types
        fontFamily: fontFamily,
        fontSize: fontSize,
      );
      _identifierStyle = TextStyle(
        color: colorScheme.tertiary, // Use tertiary for identifiers
        fontFamily: fontFamily,
        fontSize: fontSize,
      );
      _operatorStyle = TextStyle(
        color: colorScheme.onSurface.withValues(
          alpha: 0.6,
        ), // Dimmer text for operators
        fontFamily: fontFamily,
        fontSize: fontSize,
      );
      _commentStyle = TextStyle(
        color: Colors.green.shade700, // Keep green for comments, often standard
        fontStyle: FontStyle.italic,
        fontFamily: fontFamily,
        fontSize: fontSize,
      );
      // Define background based on theme surface/background
      _codeBackgroundColor =
          theme.brightness == Brightness.light
              ? colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ) // Lighter background variant
              : colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.6,
              ); // Darker background variant

      // --- Generate Code and Highlight ---
      final PostgreSQLParser parser = PostgreSQLParser();
      // Access cubit safely within the callback context
      final List<Entity> entities = context.read<DiagramCubit>().state.entities;
      postgresqlCode = parser.parseDiagram(entities);

      // Generate the highlighted TextSpan using the now initialized styles
      setState(() {
        highlightedTextSpan = _buildHighlightedSqlSpan(postgresqlCode);
      });
    });

    // Initialize with placeholder styles until theme is available
    _defaultStyle = const TextStyle(fontFamily: 'monospace', fontSize: 14);
    highlightedTextSpan = TextSpan(text: 'Loading...', style: _defaultStyle);
    _codeBackgroundColor = Colors.transparent; // Placeholder background
  }

  // --- Highlighting Logic (Uses initialized styles) ---
  TextSpan _buildHighlightedSqlSpan(String sql) {
    final List<TextSpan> spans = [];
    // Regex remains the same, but uses the theme-based styles defined above
    final RegExp pattern = RegExp(
      '(--.*)|' // 1: SQL Comment
      // Separate Keywords and Types for different styling
      r'(\b(?:CREATE|TABLE|PRIMARY|KEY|FOREIGN|REFERENCES|NOT|NULL|CONSTRAINT|DEFAULT|GENERATED|ALWAYS|AS|IDENTITY|BEFORE|UPDATE|ON|FOR|EACH|ROW|EXECUTE|FUNCTION|INDEX|UNIQUE|SET)\b)|' // 2: Keywords
      r'(\b(?:VARCHAR|INTEGER|TEXT|TIMESTAMP|BOOLEAN|WITH|TIME|ZONE)\b)|' // 3: Types (adjust list)
      '("[^"]+")|' // 4: Quoted Identifiers
      r'([\(\),;])|' // 5: Simple Operators/Separators
      r'(\s+)', // 6: Whitespace
      caseSensitive: false,
      multiLine: true,
    );

    int currentPosition = 0;
    for (final Match match in pattern.allMatches(sql)) {
      if (match.start > currentPosition) {
        spans.add(
          TextSpan(
            text: sql.substring(currentPosition, match.start),
            style: _defaultStyle,
          ),
        );
      }

      if (match.group(1) != null) {
        // Comment
        spans.add(TextSpan(text: match.group(1), style: _commentStyle));
      } else if (match.group(2) != null) {
        // Keyword
        spans.add(TextSpan(text: match.group(2), style: _keywordStyle));
      } else if (match.group(3) != null) {
        // Type
        spans.add(
          TextSpan(text: match.group(3), style: _typeStyle),
        ); // Use _typeStyle
      } else if (match.group(4) != null) {
        // Quoted Identifier
        spans.add(TextSpan(text: match.group(4), style: _identifierStyle));
      } else if (match.group(5) != null) {
        // Operator
        spans.add(TextSpan(text: match.group(5), style: _operatorStyle));
      } else if (match.group(6) != null) {
        // Whitespace
        spans.add(TextSpan(text: match.group(6), style: _defaultStyle));
      } else {
        spans.add(TextSpan(text: match.group(0), style: _defaultStyle));
      }
      currentPosition = match.end;
    }

    if (currentPosition < sql.length) {
      spans.add(
        TextSpan(text: sql.substring(currentPosition), style: _defaultStyle),
      );
    }

    // Apply the base default style to the root span
    return TextSpan(children: spans, style: _defaultStyle);
  }
  // --- End Highlighting Logic ---

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('PostgreSQL Code'),
    insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
    contentPadding: EdgeInsets.zero,
    backgroundColor:
        Theme.of(context).dialogTheme.backgroundColor, // Use dialog background
    surfaceTintColor: Colors.transparent,

    content: ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.4, // Adjusted width
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Container(
        color: _codeBackgroundColor, // Use theme-derived background
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: SelectableText.rich(
            highlightedTextSpan, // Display the generated TextSpan
          ),
        ),
      ),
    ),
    actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    actions: [
      ElevatedButton.icon(
        icon: const Icon(Icons.copy),
        label: const Text('Copy All'),
        onPressed: () {
          // Avoid copying if code hasn't loaded yet
          if (postgresqlCode.isNotEmpty) {
            unawaited(Clipboard.setData(ClipboardData(text: postgresqlCode)));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('PostgreSQL code copied to clipboard'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
      ),
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Close'),
      ),
    ],
  );
}
