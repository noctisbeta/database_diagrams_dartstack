CREATE TABLE shared_diagrams (
    shortcode VARCHAR(12) PRIMARY KEY,
    diagram_id INTEGER NOT NULL REFERENCES diagrams(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_diagram_share UNIQUE (diagram_id)
);