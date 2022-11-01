import 'package:flutter/material.dart';

/// Schema for the collection.
typedef Schema = Map<String, String>;

/// Collection.
@immutable
class Collection {
  /// Default constructor.
  const Collection({
    required this.name,
    required this.schema,
  });

  /// Name.
  final String name;

  /// Schema.
  final Schema schema;

  /// To compile string.
  String toCompileString() {
    final schemaString = schema.entries.map((e) => '${e.key}:${e.value}').join(',');
    return 'Collection $name { $schemaString }';
  }

  /// Copy with.
  Collection copyWith({
    String? name,
    Schema? schema,
  }) {
    return Collection(
      name: name ?? this.name,
      schema: schema ?? this.schema,
    );
  }
}
