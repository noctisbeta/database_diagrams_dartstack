CREATE TYPE attribute_type AS ENUM ('simple', 'composite', 'multiValued', 'derived');

CREATE TABLE entities (
    id GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    diagram_id INTEGER NOT NULL REFERENCES diagrams(id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER update_entities_updated_at BEFORE
UPDATE ON entities FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TABLE attributes (
    id GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    entity_id VARCHAR(255) NOT NULL REFERENCES entities(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    data_type VARCHAR(255) NOT NULL,
    type attribute_type NOT NULL DEFAULT 'simple',
    is_primary_key BOOLEAN NOT NULL DEFAULT FALSE,
    is_foreign_key BOOLEAN NOT NULL DEFAULT FALSE,
    is_nullable BOOLEAN NOT NULL DEFAULT FALSE,
    referenced_entity_id VARCHAR(255) REFERENCES entities(id) ON DELETE
    SET NULL,
        order INTEGER NOT NULL,
        created_at TIMESTAMP NOT NULL DEFAULT NOW(),
        updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE entity_positions (
    entity_id VARCHAR(255) PRIMARY KEY REFERENCES entities(id) ON DELETE CASCADE,
    x DOUBLE PRECISION NOT NULL,
    y DOUBLE PRECISION NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER update_entity_positions_updated_at BEFORE
UPDATE ON entity_positions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE INDEX idx_entities_diagram_id ON entities(diagram_id);