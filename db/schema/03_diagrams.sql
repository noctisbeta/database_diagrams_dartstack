CREATE TABLE diagrams (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    project_id INTEGER REFERENCES projects(id) ON DELETE CASCADE,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER update_diagrams_updated_at BEFORE
UPDATE ON diagrams FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE INDEX idx_diagrams_project_id ON diagrams(project_id);