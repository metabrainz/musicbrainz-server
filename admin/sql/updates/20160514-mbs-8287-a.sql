\set ON_ERROR_STOP 1
BEGIN;

CREATE TABLE deleted_entity (
    gid UUID NOT NULL,
    data JSONB NOT NULL,
    deleted_at timestamptz NOT NULL DEFAULT now()
);


INSERT INTO deleted_entity (gid, deleted_at, data)
SELECT gid, deleted_at,
       jsonb_object('{last_known_name, last_known_comment, entity_gid, entity_type}',
                ARRAY[last_known_name, last_known_comment, gid::text, 'artist']) AS data
  FROM artist_deletion;

ALTER TABLE editor_subscribe_artist_deleted DROP CONSTRAINT IF EXISTS editor_subscribe_artist_deleted_fk_gid;

DROP TABLE artist_deletion;


INSERT INTO deleted_entity (gid, deleted_at, data)
SELECT gid, deleted_at,
       jsonb_object('{last_known_name, last_known_comment, entity_gid, entity_type}',
                ARRAY[last_known_name, last_known_comment, gid::text, 'label']) AS data
  FROM label_deletion;

ALTER TABLE editor_subscribe_label_deleted DROP CONSTRAINT IF EXISTS editor_subscribe_label_deleted_fk_gid;

DROP TABLE label_deletion;


INSERT INTO deleted_entity (gid, deleted_at, data)
SELECT gid, deleted_at,
       jsonb_object('{last_known_name, last_known_comment, entity_gid, entity_type}',
                ARRAY[last_known_name, last_known_comment, gid::text, 'series']) AS data
  FROM series_deletion;

ALTER TABLE editor_subscribe_series_deleted DROP CONSTRAINT IF EXISTS editor_subscribe_series_deleted_fk_gid;

DROP TABLE series_deletion;


ALTER TABLE deleted_entity ADD CONSTRAINT deleted_entity_pkey PRIMARY KEY (gid);

COMMIT;
