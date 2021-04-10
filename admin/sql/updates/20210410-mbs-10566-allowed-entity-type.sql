\set ON_ERROR_STOP 1

SET search_path = musicbrainz;

BEGIN;

-----------------------
-- CREATE NEW TABLES --
-----------------------

CREATE TABLE editor_collection_type_allowed_entity_type (
    entity_type         VARCHAR(50) NOT NULL -- PK
);

CREATE TABLE series_type_allowed_entity_type (
    entity_type         VARCHAR(50) NOT NULL -- PK
);

----------------------
-- ADD PRIMARY KEYS --
----------------------

ALTER TABLE editor_collection_type_allowed_entity_type ADD CONSTRAINT editor_collection_type_allowed_entity_type_pkey PRIMARY KEY (entity_type);
ALTER TABLE series_type_allowed_entity_type ADD CONSTRAINT series_type_allowed_entity_type_pkey PRIMARY KEY (entity_type);

-------------------------
-- POPULATE NEW TABLES --
-------------------------

INSERT INTO editor_collection_type_allowed_entity_type (entity_type) VALUES
    ('area'),
    ('artist'),
    ('event'),
    ('instrument'),
    ('label'),
    ('place'),
    ('recording'),
    ('release'),
    ('release_group'),
    ('series'),
    ('work');

INSERT INTO series_type_allowed_entity_type (entity_type) VALUES
    ('event'),
    ('recording'),
    ('release'),
    ('release_group'),
    ('work');

----------------------
-- ADD FOREIGN KEYS --
----------------------

ALTER TABLE editor_collection_type
   ADD CONSTRAINT editor_collection_type_fk_entity_type
   FOREIGN KEY (entity_type)
   REFERENCES editor_collection_type_allowed_entity_type(entity_type);

ALTER TABLE series_type
   ADD CONSTRAINT series_type_fk_entity_type
   FOREIGN KEY (entity_type)
   REFERENCES series_type_allowed_entity_type(entity_type);

--------------------------
-- DROP OLD CONSTRAINTS --
--------------------------

ALTER TABLE editor_collection_type_allowed_entity_type DROP CONSTRAINT IF EXISTS editor_collection_type_allowed_entity_type_pkey;
ALTER TABLE series_type DROP CONSTRAINT IF EXISTS allowed_series_entity_type;

COMMIT;
