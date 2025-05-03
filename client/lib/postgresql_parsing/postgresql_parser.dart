// import 'package:collection/collection.dart';
import 'package:common/er/attribute.dart';
import 'package:common/er/entity.dart';

final class PostgreSQLParser {
  String parseDiagram(List<Entity> entities) {
    final StringBuffer buffer = StringBuffer();
    final Map<int, Entity> entityMap = {
      // Use null assertion if ID is guaranteed non-null
      for (final e in entities) e.id: e,
    }; // Cache entities by ID

    for (final Entity entity in entities) {
      buffer.writeln('CREATE TABLE "${entity.name}" (');

      final List<String> columnDefinitions = [];
      final List<String> constraints = [];
      final List<String> primaryKeyColumns = [];

      for (final Attribute attribute in entity.attributes) {
        columnDefinitions.add(_buildColumnDefinition(attribute, entityMap));
        if (attribute.isPrimaryKey) {
          primaryKeyColumns.add('"${attribute.name}"');
        }
        // Pass the current entity's name as the source table name
        final String? fkConstraint = _buildForeignKeyConstraint(
          attribute,
          entityMap,
          entity.name, // Pass source table name here
        );
        if (fkConstraint != null) {
          constraints.add(fkConstraint);
        }
      }

      buffer.write(columnDefinitions.map((def) => '  $def').join(',\n'));

      if (primaryKeyColumns.isNotEmpty) {
        buffer.write(',\n  PRIMARY KEY (${primaryKeyColumns.join(', ')})');
      }

      if (constraints.isNotEmpty) {
        buffer
          ..write(',\n')
          ..write(constraints.map((def) => '  $def').join(',\n'));
      }

      buffer.writeln('\n);\n');
    }
    return buffer.toString();
  }

  String _buildColumnDefinition(
    Attribute attribute,
    Map<int, Entity> entityMap,
  ) {
    final StringBuffer colBuffer =
        StringBuffer()
          ..write('"${attribute.name}"')
          ..write(
            ' ${attribute.dataType}',
          ); // Ensure dataType is SQL compatible

    if (!attribute.isNullable) {
      colBuffer.write(' NOT NULL');
    }

    return colBuffer.toString();
  }

  // Add sourceTableName parameter
  String? _buildForeignKeyConstraint(
    Attribute attribute,
    Map<int, Entity> entityMap,
    String sourceTableName, // Added parameter
  ) {
    if (!attribute.isForeignKey || attribute.referencedEntityId == null) {
      return null;
    }

    final Entity? referencedEntity = entityMap[attribute.referencedEntityId];
    if (referencedEntity == null) {
      return null; // Referenced entity not found
    }

    // Find the primary key attribute(s) in the referenced table

    final Attribute referencedPkAttribute = referencedEntity.attributes
        .firstWhere((a) => a.isPrimaryKey);

    // New naming convention: fk_{source_table}_{column_name}
    final String constraintName = 'fk_${sourceTableName}_${attribute.name}';
    final String localColumn = '"${attribute.name}"';
    final String foreignTable = '"${referencedEntity.name}"';
    final String foreignColumn = '"${referencedPkAttribute.name}"';

    // Ensure constraint name is also quoted for safety
    return 'CONSTRAINT "$constraintName" FOREIGN KEY ($localColumn) '
        'REFERENCES $foreignTable ($foreignColumn)';
    // Add ON DELETE / ON UPDATE clauses if needed, e.g.:
    // 'REFERENCES $foreignTable ($foreignColumn) ON DELETE SET NULL';
  }
}
