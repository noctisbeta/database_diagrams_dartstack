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

  /// From map.
  factory Collection.fromMap(Map<String, dynamic> data) => Collection(
        name: data['name'] as String,
        schema: data['schema'] as Schema,
      );

  /// Name.
  final String name;

  /// Schema.
  final Schema schema;

  /// To compile string.
  String toCompileString() {
    final schemaString =
        schema.entries.map((e) => '${e.key}:${e.value}').join(',');
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

  /// To map.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'schema': schema,
    };
  }
}
