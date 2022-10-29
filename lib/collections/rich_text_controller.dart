import 'package:flutter/material.dart';

/// Rich text controller.
class RichTextController extends TextEditingController {
  /// Default constructor.
  RichTextController({
    required this.onMatch,
    super.text,
    this.patternMatchMap,
    this.stringMatchMap,
    this.deleteOnBack = false,
  }) : assert(
          (patternMatchMap != null && stringMatchMap == null) || (patternMatchMap == null && stringMatchMap != null),
          'Cannot have both patternMatchMap and stringMatchMap',
        );

  /// The pattern match map.
  final Map<RegExp, TextStyle>? patternMatchMap;

  /// The string match map.
  final Map<String, TextStyle>? stringMatchMap;

  /// The on match callback.
  final Function(List<String> match) onMatch;

  /// Whether to delete on back.
  final bool? deleteOnBack;

  String _lastValue = '';

  /// is back.
  bool isBack(String current, String last) {
    return current.length < last.length;
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    required bool withComposing,
    TextStyle? style,
  }) {
    final List<TextSpan> children = [];
    final List<String> matches = [];

    // Validating with REGEX
    RegExp? allRegex;
    allRegex = patternMatchMap != null ? RegExp(patternMatchMap?.keys.map((e) => e.pattern).join('|') ?? '') : null;
    // Validating with Strings
    RegExp? stringRegex;
    stringRegex = stringMatchMap != null ? RegExp(r'\b' + stringMatchMap!.keys.join('|') + r'+\b') : null;

    text.splitMapJoin(
      stringMatchMap == null ? allRegex! : stringRegex!,
      onNonMatch: (String span) {
        children.add(TextSpan(text: span, style: style));
        return span;
      },
      onMatch: (Match m) {
        if (!matches.contains(m[0])) {
          matches.add(m[0]!);
        }
        final RegExp? k = patternMatchMap?.entries.firstWhere((element) {
          return element.key.allMatches(m[0]!).isNotEmpty;
        }).key;
        final String? ks = stringMatchMap?.entries.firstWhere((element) {
          return element.key.allMatches(m[0]!).isNotEmpty;
        }).key;
        if (deleteOnBack!) {
          if (isBack(text, _lastValue) && m.end == selection.baseOffset) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              children.removeWhere((element) => element.text! == text);
              text = text.replaceRange(m.start, m.end, '');
              selection = selection.copyWith(
                baseOffset: m.end - (m.end - m.start),
                extentOffset: m.end - (m.end - m.start),
              );
            });
          } else {
            children.add(
              TextSpan(
                text: m[0],
                style: stringMatchMap == null ? patternMatchMap![k] : stringMatchMap![ks],
              ),
            );
          }
        } else {
          children.add(
            TextSpan(
              text: m[0],
              style: stringMatchMap == null ? patternMatchMap![k] : stringMatchMap![ks],
            ),
          );
        }

        return onMatch(matches) ?? '';
      },
    );

    _lastValue = text;
    return TextSpan(style: style, children: children);
  }
}
