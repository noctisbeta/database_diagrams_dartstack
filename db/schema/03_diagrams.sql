CREATE TYPE diagram_type_enum AS ENUM ('postgresql', 'firestore', 'custom');

CREATE TABLE diagrams (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    diagram_type diagram_type_enum NOT NULL DEFAULT 'postgresql',
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER update_diagrams_updated_at BEFORE
UPDATE ON diagrams FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE INDEX idx_diagrams_user_id ON diagrams(user_id);