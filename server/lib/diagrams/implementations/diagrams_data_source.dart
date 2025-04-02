import 'package:common/er/attribute.dart';
import 'package:common/er/diagram.dart';
import 'package:common/er/diagrams/save_diagram_request.dart';
import 'package:common/er/entity.dart';
import 'package:common/er/entity_position.dart';
import 'package:meta/meta.dart';
import 'package:postgres/postgres.dart';
import 'package:server/diagrams/abstractions/i_diagrams_data_source.dart';
import 'package:server/diagrams/models/diagram_db.dart';
import 'package:server/diagrams/models/entity_db.dart';
import 'package:server/postgres/postgres_service.dart';

@immutable
final class DiagramsDataSource implements IDiagramsDataSource {
  const DiagramsDataSource({required PostgresService postgresService})
    : _ps = postgresService;

  final PostgresService _ps;

  @override
  Future<List<Diagram>> getDiagrams(int userId) async {
    final Result result = await _ps.execute(
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
          'id': diagramId,
          'name': row['diagram_name']! as String,
          'created_at': row['diagram_created_at']! as DateTime,
          'updated_at': row['diagram_updated_at']! as DateTime,
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
          'id': entityId,
          'name': row['entity_name']! as String,
          'created_at': row['entity_created_at']! as DateTime,
          'updated_at': row['entity_updated_at']! as DateTime,
        };
        attributesMap[diagramId]![entityId] = [];
      }

      // Create position entry if it doesn't exist and position data exists
      if (row['x'] != null &&
          row['y'] != null &&
          !positionsMap[diagramId]!.containsKey(entityId)) {
        positionsMap[diagramId]![entityId] = {
          'entity_id': entityId,
          'x': row['x']! as double,
          'y': row['y']! as double,
        };
      }

      // Add attribute if it exists
      final attributeId = row['attribute_id'] as int?;
      if (attributeId != null) {
        attributesMap[diagramId]![entityId]!.add({
          'id': attributeId,
          'name': row['attribute_name']! as String,
          'data_type': row['data_type']! as String,
          'is_primary_key': row['is_primary_key']! as bool,
          'is_foreign_key': row['is_foreign_key']! as bool,
          'is_nullable': row['is_nullable']! as bool,
          'referenced_entity_id': row['referenced_entity_id'],
          'order': row['order']! as int,
          'created_at': row['attribute_created_at']! as DateTime,
          'updated_at': row['attribute_updated_at']! as DateTime,
        });
      }
    }

    // Build Diagram objects
    for (final int diagramId in diagramsMap.keys) {
      final entities = <Map<String, dynamic>>[];
      final entityPositions = <Map<String, dynamic>>[];

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
          'entity_positions': entityPositions,
          'created_at': diagramsMap[diagramId]!['created_at'],
          'updated_at': diagramsMap[diagramId]!['updated_at'],
        }),
      );
    }

    return diagrams;
  }

  @override
  Future<DiagramDB> createDiagram(
    SaveDiagramRequest request,
    int userId,
  ) async {
    final DiagramDB diagramDB = await _ps.executeAndMap(
      query: Sql.named('''
      INSERT INTO diagrams (user_id, name)
      VALUES (@user_id, @name)
      RETURNING *;
      '''),
      parameters: {'user_id': userId, 'name': request.name},
      mapper: DiagramDB.validatedFromMap,
      emptyResultMessage: 'Failed to create diagram',
    );

    final List<({int idFromRequest, EntityDB dbEntity})> insertedEntities = [];
    for (final Entity entity in request.entities) {
      final EntityDB entityDB = await _ps.executeAndMap(
        query: Sql.named('''
        INSERT INTO entities (name, diagram_id)
        VALUES (@name, @diagram_id)
        RETURNING *;
        '''),
        parameters: {'name': entity.name, 'diagram_id': diagramDB.id},
        mapper: EntityDB.validatedFromMap,
        emptyResultMessage: 'Failed to create entity',
      );

      insertedEntities.add((idFromRequest: entity.id, dbEntity: entityDB));

      final EntityPosition entityPosition = request.entityPositions.firstWhere(
        (position) => position.entityId == entity.id,
      );

      final int dbEntityId = entityDB.id;

      await _ps.execute(
        Sql.named('''
        INSERT INTO entity_positions (entity_id, x, y)
        VALUES (@entity_id, @x, @y);
        '''),
        parameters: {
          'entity_id': dbEntityId,
          'x': entityPosition.x,
          'y': entityPosition.y,
        },
      );

      for (final Attribute attribute in entity.attributes) {
        await _ps.execute(
          Sql.named('''
          INSERT INTO attributes (
            entity_id,
            name,
            data_type,
            is_primary_key,
            is_foreign_key,
            is_nullable,
            "order"
          )
          VALUES (
            @entity_id,
            @name,
            @data_type,
            @is_primary_key,
            @is_foreign_key,
            @is_nullable,
            @order
          );
          '''),
          parameters: {
            'entity_id': dbEntityId,
            'name': attribute.name,
            'data_type': attribute.dataType,
            'is_primary_key': attribute.isPrimaryKey,
            'is_foreign_key': attribute.isForeignKey,
            'is_nullable': attribute.isNullable,
            'order': attribute.order,
          },
        );
      }
    }

    for (final Entity entity in request.entities) {
      for (final Attribute attribute in entity.attributes.where(
        (a) => a.referencedEntityId != null,
      )) {
        final int attributeOwnerEntityDbId =
            insertedEntities
                .firstWhere((e) => e.idFromRequest == entity.id)
                .dbEntity
                .id;

        final int referencedEntityDbId =
            insertedEntities
                .firstWhere(
                  (e) => e.idFromRequest == attribute.referencedEntityId!,
                )
                .dbEntity
                .id;

        await _ps.execute(
          Sql.named('''
          UPDATE attributes 
          SET
            referenced_entity_id = @referenced_entity_id
          WHERE (
            entity_id = @entity_id
          );
          '''),
          parameters: {
            'entity_id': attributeOwnerEntityDbId,
            'referenced_entity_id': referencedEntityDbId,
          },
        );
      }
    }

    return diagramDB;
  }

  @override
  Future<DiagramDB> updateDiagram(
    SaveDiagramRequest request,
    int userId,
  ) async {
    // 1. Update the diagram and verify ownership
    final DiagramDB diagramDB = await _ps.executeAndMap(
      query: Sql.named('''
      UPDATE diagrams
      SET name = @name, updated_at = NOW()
      WHERE id = @diagram_id AND user_id = @user_id
      RETURNING *;
      '''),
      parameters: {
        'name': request.name,
        'diagram_id': request.id,
        'user_id': userId,
      },
      mapper: DiagramDB.validatedFromMap,
      emptyResultMessage: 'Failed to update diagram or access denied',
    );

    await _ps.execute(
      Sql.named('DELETE FROM entities WHERE diagram_id = @diagram_id'),
      parameters: {'diagram_id': diagramDB.id},
    );

    final List<({int idFromRequest, EntityDB dbEntity})> insertedEntities = [];
    for (final Entity entity in request.entities) {
      final EntityDB entityDB = await _ps.executeAndMap(
        query: Sql.named('''
        INSERT INTO entities (name, diagram_id)
        VALUES (@name, @diagram_id)
        RETURNING *;
        '''),
        parameters: {'name': entity.name, 'diagram_id': diagramDB.id},
        mapper: EntityDB.validatedFromMap,
        emptyResultMessage: 'Failed to create entity',
      );

      insertedEntities.add((idFromRequest: entity.id, dbEntity: entityDB));

      final EntityPosition entityPosition = request.entityPositions.firstWhere(
        (position) => position.entityId == entity.id,
      );

      final int dbEntityId = entityDB.id;

      await _ps.execute(
        Sql.named('''
        INSERT INTO entity_positions (entity_id, x, y)
        VALUES (@entity_id, @x, @y);
        '''),
        parameters: {
          'entity_id': dbEntityId,
          'x': entityPosition.x,
          'y': entityPosition.y,
        },
      );

      for (final Attribute attribute in entity.attributes) {
        await _ps.execute(
          Sql.named('''
          INSERT INTO attributes (
            entity_id,
            name,
            data_type,
            is_primary_key,
            is_foreign_key,
            is_nullable,
            "order"
          )
          VALUES (
            @entity_id,
            @name,
            @data_type,
            @is_primary_key,
            @is_foreign_key,
            @is_nullable,
            @order
          );
          '''),
          parameters: {
            'entity_id': dbEntityId,
            'name': attribute.name,
            'data_type': attribute.dataType,
            'is_primary_key': attribute.isPrimaryKey,
            'is_foreign_key': attribute.isForeignKey,
            'is_nullable': attribute.isNullable,
            'order': attribute.order,
          },
        );
      }
    }

    for (final Entity entity in request.entities) {
      for (final Attribute attribute in entity.attributes.where(
        (a) => a.referencedEntityId != null,
      )) {
        final int attributeOwnerEntityDbId =
            insertedEntities
                .firstWhere((e) => e.idFromRequest == entity.id)
                .dbEntity
                .id;

        final int referencedEntityDbId =
            insertedEntities
                .firstWhere(
                  (e) => e.idFromRequest == attribute.referencedEntityId!,
                )
                .dbEntity
                .id;

        await _ps.execute(
          Sql.named('''
          UPDATE attributes 
          SET
            referenced_entity_id = @referenced_entity_id
          WHERE (
            entity_id = @entity_id
          );
          '''),
          parameters: {
            'entity_id': attributeOwnerEntityDbId,
            'referenced_entity_id': referencedEntityDbId,
          },
        );
      }
    }

    return diagramDB;
  }

  @override
  Future<void> deleteDiagram(int diagramId, int userId) async {
    // First verify ownership
    final Result ownershipCheck = await _ps.execute(
      Sql.named('''
      SELECT id FROM diagrams 
      WHERE id = @diagram_id AND user_id = @user_id
      '''),
      parameters: {'diagram_id': diagramId, 'user_id': userId},
    );

    if (ownershipCheck.isEmpty) {
      throw Exception('Diagram not found or access denied');
    }

    // Delete the diagram (cascade will handle entities, attributes, positions)
    await _ps.execute(
      Sql.named('DELETE FROM diagrams WHERE id = @diagram_id'),
      parameters: {'diagram_id': diagramId},
    );
  }
}
