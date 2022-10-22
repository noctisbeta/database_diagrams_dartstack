import 'package:database_diagrams/collections/smartline_type.dart';
import 'package:flutter/material.dart';

/// Smartline anchor.
class SmartlineAnchor {
  /// Default constructor.
  const SmartlineAnchor({
    required this.key,
    required this.type,
  });

  /// Key.
  final GlobalObjectKey key;

  /// Type.
  final SmartlineType type;
}
