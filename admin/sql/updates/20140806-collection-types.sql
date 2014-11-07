\set ON_ERROR_STOP 1
BEGIN;

CREATE TABLE editor_collection_type ( -- replicate
    id                  SERIAL,
    name                VARCHAR(255) NOT NULL,
    entity_type         VARCHAR(50) NOT NULL,
    parent              INTEGER, -- references editor_collection_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT
);

ALTER TABLE editor_collection_type ADD CONSTRAINT editor_collection_type_pkey PRIMARY KEY (id);

INSERT INTO editor_collection_type (id, name, entity_type, parent, child_order) VALUES
    (1, 'Release', 'release', NULL, 1),
    (2, 'Owned music', 'release', 1, 1),
    (3, 'Wishlist', 'release', 1, 2);

SELECT setval('editor_collection_type_id_seq', (SELECT MAX(id) FROM editor_collection_type));

ALTER TABLE editor_collection
    ADD COLUMN type INTEGER;

UPDATE editor_collection SET type = 1;

ALTER TABLE editor_collection
    ALTER COLUMN type SET NOT NULL;

COMMIT;
