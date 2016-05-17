\set ON_ERROR_STOP 1
BEGIN;

DROP INDEX IF EXISTS edit_add_relationship_link_type;
DROP INDEX IF EXISTS edit_edit_relationship_link_type_link;
DROP INDEX IF EXISTS edit_edit_relationship_link_type_new;
DROP INDEX IF EXISTS edit_edit_relationship_link_type_old;
DROP INDEX IF EXISTS edit_remove_relationship_link_type;

DROP FUNCTION IF EXISTS extract_path_value(text, text);

CREATE TABLE edit_data (
  edit INTEGER NOT NULL,
  data JSONB NOT NULL
);

INSERT INTO edit_data
  SELECT id, data::jsonb
    FROM edit
   ORDER BY id;

ALTER TABLE edit_data
  ADD CONSTRAINT edit_data_pkey PRIMARY KEY (edit);

ALTER TABLE edit
  DROP COLUMN data;

CREATE INDEX edit_data_idx_link_type ON edit_data USING GIN (
    array_remove(ARRAY[
                     (data#>>'{link_type,id}')::int,
                     (data#>>'{link,link_type,id}')::int,
                     (data#>>'{old,link_type,id}')::int,
                     (data#>>'{new,link_type,id}')::int,
                     (data#>>'{relationship,link_type,id}')::int
                 ], NULL)
);

COMMIT;
