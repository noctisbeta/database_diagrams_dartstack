/// Common PostgreSQL Data Types
const Set<String> kPostgresDataTypes = {
  // Numeric Types
  'SMALLINT', // int2
  'INTEGER', // int, int4
  'BIGINT', // int8
  'DECIMAL', // numeric
  'NUMERIC', // decimal
  'REAL', // float4
  'DOUBLE PRECISION', // float8
  'SMALLSERIAL', // serial2
  'SERIAL', // serial4
  'BIGSERIAL', // serial8
  // Monetary Types
  'MONEY',

  // Character Types
  'CHARACTER VARYING', // varchar(n)
  'VARCHAR', // varchar(n)
  'CHARACTER', // char(n)
  'CHAR', // char(n)
  'TEXT',

  // Binary Data Types
  'BYTEA',

  // Date/Time Types
  'TIMESTAMP', // without time zone
  'TIMESTAMP WITH TIME ZONE', // timestamptz
  'DATE',
  'TIME', // without time zone
  'TIME WITH TIME ZONE', // timetz
  'INTERVAL',

  // Boolean Type
  'BOOLEAN', // bool
  // Enumerated Type (User-defined, but common concept)
  // 'ENUM', // Placeholder - actual name varies

  // Geometric Types
  'POINT',
  'LINE',
  'LSEG',
  'BOX',
  'PATH',
  'POLYGON',
  'CIRCLE',

  // Network Address Types
  'CIDR',
  'INET',
  'MACADDR',
  'MACADDR8',

  // Bit String Types
  'BIT', // bit(n)
  'BIT VARYING', // varbit(n)
  // Text Search Types
  'TSVECTOR',
  'TSQUERY',

  // UUID Type
  'UUID',

  // XML Type
  'XML',

  // JSON Types
  'JSON',
  'JSONB',

  // Array Type (Applies to others, e.g., INTEGER[])
  // 'ARRAY', // Placeholder - used as modifier

  // Composite Types (User-defined)
  // 'COMPOSITE', // Placeholder - actual name varies

  // Range Types
  'INT4RANGE',
  'INT8RANGE',
  'NUMRANGE',
  'TSRANGE',
  'TSTZRANGE',
  'DATERANGE',

  // Object Identifier Types
  'OID',
};

/// Firestore Data Types (Fundamental Types)
const Set<String> kFirestoreDataTypes = {
  'String',
  'Number', // Represents both integers and doubles
  'Boolean',
  'Map', // Nested object
  'Array', // List of values
  'Null',
  'Timestamp', // Specific Firestore timestamp
  'GeoPoint', // Latitude/longitude pair
  'Reference', // Pointer to another document
  // 'Bytes' // For binary data - less common in diagrams?
};
