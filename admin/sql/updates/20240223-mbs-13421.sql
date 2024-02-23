\set ON_ERROR_STOP 1
BEGIN;

CREATE TABLE editor_collection_genre (
    collection INTEGER NOT NULL,
    genre INTEGER NOT NULL,
    added TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    position INTEGER NOT NULL DEFAULT 0 CHECK (position >= 0),
    comment TEXT DEFAULT '' NOT NULL
);

ALTER TABLE editor_collection_genre ADD CONSTRAINT editor_collection_genre_pkey PRIMARY KEY (collection, genre);

ALTER TABLE editor_collection_type
      DROP CONSTRAINT IF EXISTS allowed_collection_entity_type;

INSERT INTO editor_collection_type (id, name, entity_type, parent, child_order, gid)
     VALUES (16, 'Genre', 'genre', NULL, 2, generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'editor_collection_type' || 16));

COMMIT;
