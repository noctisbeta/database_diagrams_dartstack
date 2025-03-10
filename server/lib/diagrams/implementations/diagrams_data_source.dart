import 'package:common/er/attribute.dart';
import 'package:common/er/diagram.dart';
import 'package:common/er/diagrams/save_diagram_request.dart';
import 'package:common/er/entity.dart';
import 'package:common/er/entity_position.dart';
import 'package:meta/meta.dart';
import 'package:postgres/postgres.dart';
import 'package:server/diagrams/abstractions/i_diagrams_data_source.dart';
import 'package:server/diagrams/diagram_db.dart';
import 'package:server/postgres/implementations/postgres_service.dart';

@immutable
final class DiagramsDataSource implements IDiagramsDataSource {
  const DiagramsDataSource({required PostgresService db}) : _db = db;

  final PostgresService _db;

  @override
  Future<List<Diagram>> getDiagrams(int userId) async {
    final Result result = await _db.execute(
      Sql.named('''
      SELECT 
        d.id AS diagram_id, 
        d.name AS diagram_name,
        d.created_at AS diagram_created_at,
        d.updated_at AS diagram_updated_at,
        
        e.id AS entity_id, 
        e.name AS entity_name,
        e.created_at AS entity_created_at,
        e.updated_at AS entity_updated_at,
        
        a.id AS attribute_id,
        a.name AS attribute_name,
        a.data_type,
        a.is_primary_key,
        a.is_foreign_key,
        a.is_nullable,
        a.referenced_entity_id,
        a."order",
        a.created_at AS attribute_created_at,
        a.updated_at AS attribute_updated_at,
        
        ep.entity_id,
        ep.x,
        ep.y
      FROM diagrams d
      LEFT JOIN entities e ON d.id = e.diagram_id
      LEFT JOIN attributes a ON e.id = a.entity_id
      LEFT JOIN entity_positions ep ON e.id = ep.entity_id
      WHERE d.user_id = @user_id
      ORDER BY d.id, e.id, a."order"
      '''),
      parameters: {'user_id': userId},
    );

    final diagrams = <Diagram>[];
    final Map<int, Map<String, dynamic>> diagramsMap = {};
    final Map<int, Map<int, Map<String, dynamic>>> entitiesMap = {};
    final Map<int, Map<int, List<Map<String, dynamic>>>> attributesMap = {};
    final Map<int, Map<int, Map<String, dynamic>>> positionsMap = {};

    // Process rows to build the maps
    for (final ResultRow roww in result) {
      final Map<String, dynamic> row = roww.toColumnMap();
      final diagramId = row['diagram_id']! as int;
      final entityId = row['entity_id'] as int?;

      // Create diagram entry if it doesn't exist
      if (!diagramsMap.containsKey(diagramId)) {
        diagramsMap[diagramId] = {
          'id': diagramId.toString(),
          'name': row['diagram_name']! as String,
          'created_at': row['diagram_created_at']! as String,
          'updated_at': row['diagram_updated_at']! as String,
        };
        entitiesMap[diagramId] = {};
        attributesMap[diagramId] = {};
        positionsMap[diagramId] = {};
      }

      // Skip if no entity
      if (entityId == null) {
        continue;
      }

      // Create entity entry if it doesn't exist
      if (!entitiesMap[diagramId]!.containsKey(entityId)) {
        entitiesMap[diagramId]![entityId] = {
          'id': entityId.toString(),
          'name': row['entity_name']! as String,
          'created_at': row['entity_created_at']! as String,
          'updated_at': row['entity_updated_at']! as String,
        };
        attributesMap[diagramId]![entityId] = [];
      }

      // Create position entry if it doesn't exist and position data exists
      if (row['x'] != null &&
          row['y'] != null &&
          !positionsMap[diagramId]!.containsKey(entityId)) {
        positionsMap[diagramId]![entityId] = {
          'entity_id': entityId.toString(),
          'x': row['x']! as double,
          'y': row['y']! as double,
        };
      }

      // Add attribute if it exists
      final attributeId = row['attribute_id'] as int?;
      if (attributeId != null) {
        attributesMap[diagramId]![entityId]!.add({
          'id': attributeId.toString(),
          'name': row['attribute_name']! as String,
          'data_type': row['data_type']! as String,
          'is_primary_key': row['is_primary_key']! as bool,
          'is_foreign_key': row['is_foreign_key']! as bool,
          'is_nullable': row['is_nullable']! as bool,
          'referenced_entity_id': row['referenced_entity_id']?.toString(),
          'order': row['order']! as int,
          'created_at': row['attribute_created_at']! as String,
          'updated_at': row['attribute_updated_at']! as String,
        });
      }
    }

    // Build Diagram objects
    for (final int diagramId in diagramsMap.keys) {
      final entities = <Map<String, dynamic>>[];
      final entityPositions = <Map<String, dynamic>>[];
      final relations =
          <Map<String, dynamic>>[]; // Relations will be empty for now

      for (final int entityId in entitiesMap[diagramId]!.keys) {
        final Map<String, dynamic> entity = entitiesMap[diagramId]![entityId]!;
        entity['attributes'] = attributesMap[diagramId]![entityId];
        entities.add(entity);

        if (positionsMap[diagramId]!.containsKey(entityId)) {
          entityPositions.add(positionsMap[diagramId]![entityId]!);
        }
      }

      diagrams.add(
        Diagram.validatedFromMap({
          'id': diagramsMap[diagramId]!['id'],
          'name': diagramsMap[diagramId]!['name'],
          'entities': entities,
          'relations': relations,
          'entity_positions': entityPositions,
          'created_at': diagramsMap[diagramId]!['created_at'],
          'updated_at': diagramsMap[diagramId]!['updated_at'],
        }),
      );
    }

    return diagrams;
  }

  @override
  Future<DiagramDB> saveDiagram(SaveDiagramRequest request, int userId) async {
    final Result result = await _db.execute(
      Sql.named('''
      INSERT INTO diagrams (user_id, name)
      VALUES (@user_id, @name)
      RETURNING *;
      '''),
      parameters: {'user_id': userId, 'name': request.name},
    );

    final Map<String, dynamic> rowMap = result.first.toColumnMap();
    final diagramDB = DiagramDB.validatedFromMap(rowMap);

    for (final Entity entity in request.entities) {
      final Result entityResult = await _db.execute(
        Sql.named('''
        INSERT INTO entities (name, diagram_id)
        VALUES (@name, @diagram_id)
        RETURNING *;
        '''),
        parameters: {'name': entity.name, 'diagram_id': diagramDB.id},
      );

      final Map<String, dynamic> entityMap = entityResult.first.toColumnMap();
      final entityId = entityMap['id'] as int;

      // Insert attributes
      for (int i = 0; i < entity.attributes.length; i++) {
        final Attribute attribute = entity.attributes[i];
        await _db.execute(
          Sql.named('''
          INSERT INTO attributes (
            entity_id,
            name,
            data_type,
            is_primary_key,
            is_foreign_key,
            is_nullable,
            referenced_entity_id,
            "order"
          )
          VALUES (
            @entity_id,
            @name,
            @data_type,
            @is_primary_key,
            @is_foreign_key,
            @is_nullable,
            @referenced_entity_id,
            @order
          );
          '''),
          parameters: {
            'entity_id': entityId,
            'name': attribute.name,
            'data_type': attribute.dataType,
            'is_primary_key': attribute.isPrimaryKey,
            'is_foreign_key': attribute.isForeignKey,
            'is_nullable': attribute.isNullable,
            'referenced_entity_id': attribute.referencedEntityId,
            'order': attribute.order,
          },
        );
      }
    }

    for (final EntityPosition entityPosition in request.entityPositions) {
      await _db.execute(
        Sql.named('''
        INSERT INTO entity_positions (entity_id, x, y)
        VALUES (@entity_id, @x, @y);
        '''),
        parameters: {
          'entity_id': entityPosition.entityId,
          'x': entityPosition.x,
          'y': entityPosition.y,
        },
      );
    }

    return diagramDB;
  }
}
