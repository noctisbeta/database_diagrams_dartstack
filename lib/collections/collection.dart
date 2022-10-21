import 'package:database_diagrams/collections/schema.dart';

/// Collection.
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
}
